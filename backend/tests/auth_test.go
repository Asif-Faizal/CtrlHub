//go:build integration

package tests

import (
	"slices"
	"testing"
)

func TestPlatformLoginAndDashboardRouting(t *testing.T) {
	e := setup(t)
	p := e.platform()
	must(t, p.User.Role == "PLATFORM_ADMIN" && p.User.Dashboard == "platform", "platform user: %+v", p.User)

	e.expect(e.do("POST", "/api/v1/auth/login", "", map[string]string{"email": adminEmail, "password": "wrong-password"}), 401)
	e.expect(e.do("GET", "/api/v1/platform/stats", "", nil), 401)
	e.expect(e.do("GET", "/api/v1/platform/stats", "not-a-jwt", nil), 401)
	e.expect(e.do("GET", "/api/v1/platform/stats", p.AccessToken, nil), 200)
	// Platform admins are not gym users.
	e.expect(e.do("GET", "/api/v1/gym/members", p.AccessToken, nil), 403)

	g := e.onboard(p.AccessToken, "Iron House Fitness", "rahul@ironhouse.test")
	must(t, g.Code == "gym_001", "first tenant code should be gym_001, got %s", g.Code)
	admin := e.login("rahul@ironhouse.test", "gym-admin-pass-1")
	must(t, admin.User.Role == "GYM_ADMIN" && admin.User.Dashboard == "gym" && admin.User.TenantID == g.ID,
		"gym admin: %+v", admin.User)
	must(t, slices.Contains(admin.User.Permissions, "users.manage"), "admin should manage users")
	// Gym users cannot reach platform routes.
	e.expect(e.do("GET", "/api/v1/platform/tenants", admin.AccessToken, nil), 403)

	g2 := e.onboard(p.AccessToken, "Second Gym", "owner2@gym.test")
	must(t, g2.Code == "gym_002", "second tenant code should be gym_002, got %s", g2.Code)

	var list struct {
		Items []struct {
			Code           string `json:"code"`
			UserCount      int    `json:"user_count"`
			WhatsAppStatus string `json:"whatsapp_status"`
		}
		Total int
	}
	e.expect(e.do("GET", "/api/v1/platform/tenants", p.AccessToken, nil), 200).json(t, &list)
	must(t, list.Total == 2 && list.Items[0].WhatsAppStatus == "NOT_CONNECTED", "tenant list: %+v", list)
}

func TestSetupLinkIsSingleUse(t *testing.T) {
	e := setup(t)
	p := e.platform()
	g := e.onboard(p.AccessToken, "Gym A", "a@gym.test")
	r := e.expect(e.do("POST", "/api/v1/gym/users/"+g.AdminUserID+"/reset-password", g.AdminToken, nil), 200)
	link := r.m(t)["setup_url"].(string)
	must(t, len(link) > 20, "reset link: %s", link)
	token := link[len("http://web.test/setup-password?token="):]
	e.expect(e.do("POST", "/api/v1/auth/setup-password", "", map[string]string{"token": token, "password": "new-pass-456"}), 200)
	e.expect(e.do("POST", "/api/v1/auth/setup-password", "", map[string]string{"token": token, "password": "other-pass-789"}), 400)
	e.login("a@gym.test", "new-pass-456")
}

func TestRefreshTokenRotationAndReuseDetection(t *testing.T) {
	e := setup(t)
	s := e.platform()
	var s2 session
	e.expect(e.do("POST", "/api/v1/auth/refresh", "", map[string]string{"refresh_token": s.RefreshToken}), 200).json(t, &s2)
	must(t, s2.RefreshToken != s.RefreshToken, "refresh token must rotate")

	// Reusing the old token is rejected and revokes the whole family.
	e.expect(e.do("POST", "/api/v1/auth/refresh", "", map[string]string{"refresh_token": s.RefreshToken}), 401)
	e.expect(e.do("POST", "/api/v1/auth/refresh", "", map[string]string{"refresh_token": s2.RefreshToken}), 401)

	s3 := e.platform()
	e.expect(e.do("POST", "/api/v1/auth/logout", "", map[string]string{"refresh_token": s3.RefreshToken}), 204)
	e.expect(e.do("POST", "/api/v1/auth/refresh", "", map[string]string{"refresh_token": s3.RefreshToken}), 401)
}

func TestRolePermissionsEnforcedByBackend(t *testing.T) {
	e := setup(t)
	p := e.platform()
	g := e.onboard(p.AccessToken, "Iron House", "rahul@iron.test")
	manager := e.addUser(g.AdminToken, "GYM_MANAGER", "akhil@iron.test")
	reception := e.addUser(g.AdminToken, "RECEPTIONIST", "arun@iron.test")
	trainer := e.addUser(g.AdminToken, "TRAINER", "vishnu@iron.test")

	for _, s := range []session{manager, reception, trainer} {
		must(t, s.User.TenantID == g.ID && s.User.Dashboard == "gym", "staff tenant: %+v", s.User)
	}

	member := e.createMember(reception.AccessToken, "Member One", "9811111111", true, "")
	plan := e.createPlan(manager.AccessToken, "Monthly", 0, 150000)

	// Trainer: read members, record attendance; nothing financial.
	e.expect(e.do("GET", "/api/v1/gym/members/"+member, trainer.AccessToken, nil), 200)
	e.expect(e.do("POST", "/api/v1/gym/members", trainer.AccessToken, map[string]any{"full_name": "x", "phone": "9822222222"}), 403)
	e.expect(e.do("GET", "/api/v1/gym/payments", trainer.AccessToken, nil), 403)
	e.expect(e.do("POST", "/api/v1/gym/payments", trainer.AccessToken, map[string]any{
		"member_id": member, "amount_minor": 100, "method": "CASH"}), 403)

	// Receptionist: memberships and payments, but no plans/campaigns/users.
	e.assign(reception.AccessToken, member, plan, nil)
	e.expect(e.do("POST", "/api/v1/gym/plans", reception.AccessToken, map[string]any{
		"name": "x", "duration_type": "MONTHLY", "price_minor": 1}), 403)
	e.expect(e.do("GET", "/api/v1/gym/campaigns", reception.AccessToken, nil), 403)
	e.expect(e.do("GET", "/api/v1/gym/users", reception.AccessToken, nil), 403)
	e.expect(e.do("POST", "/api/v1/gym/attendance", trainer.AccessToken, map[string]any{"member_id": member}), 201)

	// Manager: no user management or WhatsApp connection.
	e.expect(e.do("GET", "/api/v1/gym/users", manager.AccessToken, nil), 403)
	e.expect(e.do("POST", "/api/v1/gym/whatsapp/connect", manager.AccessToken, nil), 403)
	e.expect(e.do("GET", "/api/v1/gym/reports/daily", manager.AccessToken, nil), 200)

	// Role changes apply immediately (permissions are loaded per request).
	var users []struct{ ID, Email string }
	e.expect(e.do("GET", "/api/v1/gym/users", g.AdminToken, nil), 200).json(t, &users)
	var trainerID string
	for _, u := range users {
		if u.Email == "vishnu@iron.test" {
			trainerID = u.ID
		}
	}
	e.expect(e.do("PATCH", "/api/v1/gym/users/"+trainerID, g.AdminToken, map[string]any{
		"name": "Vishnu", "role": "RECEPTIONIST", "status": "ACTIVE"}), 200)
	e.expect(e.do("GET", "/api/v1/gym/payments", trainer.AccessToken, nil), 200)

	// Deactivated users are locked out immediately.
	e.expect(e.do("PATCH", "/api/v1/gym/users/"+trainerID, g.AdminToken, map[string]any{
		"name": "Vishnu", "role": "RECEPTIONIST", "status": "INACTIVE"}), 200)
	e.expect(e.do("GET", "/api/v1/gym/members", trainer.AccessToken, nil), 403)

	// The primary admin cannot be demoted by gym users, nor deactivate themselves.
	e.expect(e.do("PATCH", "/api/v1/gym/users/"+g.AdminUserID, g.AdminToken, map[string]any{
		"name": "Rahul", "role": "TRAINER", "status": "ACTIVE"}), 403)
}

func TestTenantDeactivationLocksOutGym(t *testing.T) {
	e := setup(t)
	p := e.platform()
	g := e.onboard(p.AccessToken, "Gym A", "a@gym.test")
	e.expect(e.do("GET", "/api/v1/gym/profile", g.AdminToken, nil), 200)
	e.expect(e.do("PATCH", "/api/v1/platform/tenants/"+g.ID+"/status", p.AccessToken, map[string]string{"status": "INACTIVE"}), 200)
	r := e.expect(e.do("GET", "/api/v1/gym/profile", g.AdminToken, nil), 403)
	must(t, r.m(t)["error"].(map[string]any)["code"] == "ACCOUNT_INACTIVE", "error code: %s", r.Body)
	e.expect(e.do("POST", "/api/v1/auth/login", "", map[string]string{"email": "a@gym.test", "password": "gym-admin-pass-1"}), 403)
	e.expect(e.do("PATCH", "/api/v1/platform/tenants/"+g.ID+"/status", p.AccessToken, map[string]string{"status": "ACTIVE"}), 200)
	e.expect(e.do("GET", "/api/v1/gym/profile", g.AdminToken, nil), 200)
}

func TestUserLimitPerTenant(t *testing.T) {
	e := setup(t)
	p := e.platform()
	g := e.onboard(p.AccessToken, "Tiny Gym", "tiny@gym.test")
	r := e.expect(e.do("GET", "/api/v1/platform/tenants/"+g.ID, p.AccessToken, nil), 200).m(t)
	r["max_users"] = 2
	delete(r, "id")
	delete(r, "code")
	delete(r, "created_at")
	delete(r, "updated_at")
	e.expect(e.do("PATCH", "/api/v1/platform/tenants/"+g.ID, p.AccessToken, r), 200)
	e.addUser(g.AdminToken, "TRAINER", "t1@gym.test")
	e.expect(e.do("POST", "/api/v1/gym/users", g.AdminToken, map[string]any{
		"name": "t2", "email": "t2@gym.test", "role": "TRAINER"}), 403)
}
