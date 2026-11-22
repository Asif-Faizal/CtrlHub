//go:build integration

package tests

import (
	"strings"
	"testing"
)

// TestCrossTenantIsolation verifies that gym B can never read or modify gym
// A's members, memberships, payments, campaigns, holidays, WhatsApp session
// or reports, even when it knows the record ids.
func TestCrossTenantIsolation(t *testing.T) {
	e := setup(t)
	p := e.platform()
	a := e.onboard(p.AccessToken, "Gym A", "a@gym.test")
	b := e.onboard(p.AccessToken, "Gym B", "b@gym.test")

	// Data in gym A.
	memberA := e.createMember(a.AdminToken, "Alice A", "9811111111", true, "")
	planA := e.createPlan(a.AdminToken, "Monthly A", 0, 100000)
	msA := e.assign(a.AdminToken, memberA, planA, nil)["id"].(string)
	payA := e.expect(e.do("POST", "/api/v1/gym/payments", a.AdminToken, map[string]any{
		"member_id": memberA, "membership_id": msA, "amount_minor": 50000, "method": "CASH"}), 201).m(t)["id"].(string)
	holA := e.expect(e.do("POST", "/api/v1/gym/holidays", a.AdminToken, map[string]any{
		"title": "Onam", "holiday_date": ymd(todayIST().AddDate(0, 0, 10))}), 201).m(t)["id"].(string)
	campA := e.expect(e.do("POST", "/api/v1/gym/campaigns", a.AdminToken, map[string]any{
		"name": "Promo A", "message": "Hi {{name}}", "audience": "ACTIVE_MEMBERS"}), 201).m(t)["id"].(string)
	e.expect(e.do("POST", "/api/v1/gym/campaigns/"+campA+"/submit", a.AdminToken, nil), 200)
	leadA := e.expect(e.do("POST", "/api/v1/gym/leads", a.AdminToken, map[string]any{
		"full_name": "Lead A", "phone": "9833333333"}), 201).m(t)["id"].(string)

	// Same phone number is allowed in a different gym (uniqueness is per tenant).
	e.createMember(b.AdminToken, "Bob B", "9811111111", false, "")

	bt := b.AdminToken
	notFound := []struct {
		method, path string
		body         any
	}{
		{"GET", "/api/v1/gym/members/" + memberA, nil},
		{"PUT", "/api/v1/gym/members/" + memberA, map[string]any{"full_name": "Hacked", "phone": "9800000000"}},
		{"GET", "/api/v1/gym/members/" + memberA + "/memberships", nil},
		{"GET", "/api/v1/gym/members/" + memberA + "/payments", nil},
		{"GET", "/api/v1/gym/members/" + memberA + "/attendance", nil},
		{"GET", "/api/v1/gym/memberships/" + msA, nil},
		{"POST", "/api/v1/gym/memberships/" + msA + "/renew", map[string]any{}},
		{"POST", "/api/v1/gym/memberships/" + msA + "/cancel", nil},
		{"PUT", "/api/v1/gym/plans/" + planA, map[string]any{"name": "x", "duration_type": "MONTHLY", "price_minor": 1}},
		{"PUT", "/api/v1/gym/holidays/" + holA, map[string]any{"title": "x", "holiday_date": ymd(todayIST())}},
		{"DELETE", "/api/v1/gym/holidays/" + holA, nil},
		{"GET", "/api/v1/gym/campaigns/" + campA, nil},
		{"GET", "/api/v1/gym/campaigns/" + campA + "/recipients", nil},
		{"POST", "/api/v1/gym/campaigns/" + campA + "/approve", nil},
		{"POST", "/api/v1/gym/campaigns/" + campA + "/cancel", nil},
		{"PUT", "/api/v1/gym/leads/" + leadA, map[string]any{"full_name": "x", "phone": "9800000001"}},
		{"PATCH", "/api/v1/gym/users/" + a.AdminUserID, map[string]any{"name": "x", "role": "TRAINER", "status": "INACTIVE"}},
		{"POST", "/api/v1/gym/users/" + a.AdminUserID + "/reset-password", nil},
	}
	for _, c := range notFound {
		r := e.do(c.method, c.path, bt, c.body)
		if r.Status != 404 {
			t.Errorf("%s %s from gym B: expected 404, got %d %s", c.method, c.path, r.Status, r.Body)
		}
	}

	// Referencing gym A ids inside gym B writes is rejected.
	for _, body := range []map[string]any{
		{"member_id": memberA, "amount_minor": 100, "method": "CASH"},
		{"member_id": memberA, "membership_id": msA, "amount_minor": 100, "method": "CASH"},
	} {
		e.expect(e.do("POST", "/api/v1/gym/payments", bt, body), 400)
	}
	e.expect(e.do("POST", "/api/v1/gym/memberships", bt, map[string]any{"member_id": memberA, "plan_id": planA}), 400)
	e.expect(e.do("POST", "/api/v1/gym/attendance", bt, map[string]any{"member_id": memberA}), 400)

	// A client-supplied tenant_id is never accepted.
	e.expect(e.do("POST", "/api/v1/gym/members", bt, map[string]any{
		"full_name": "Sneaky", "phone": "9844444444", "tenant_id": a.ID}), 400)

	// Lists and reports only show gym B's own data.
	var members struct {
		Items []struct {
			ID       string
			FullName string `json:"full_name"`
		}
		Total int
	}
	e.expect(e.do("GET", "/api/v1/gym/members", bt, nil), 200).json(t, &members)
	must(t, members.Total == 1 && members.Items[0].FullName == "Bob B", "gym B members: %+v", members)

	for _, path := range []string{"/api/v1/gym/payments", "/api/v1/gym/memberships", "/api/v1/gym/messages"} {
		var page struct{ Total int }
		e.expect(e.do("GET", path, bt, nil), 200).json(t, &page)
		must(t, page.Total == 0, "%s leaked %d rows to gym B", path, page.Total)
	}
	for _, path := range []string{"/api/v1/gym/campaigns", "/api/v1/gym/holidays", "/api/v1/gym/leads", "/api/v1/gym/plans"} {
		var list []map[string]any
		e.expect(e.do("GET", path, bt, nil), 200).json(t, &list)
		must(t, len(list) == 0, "%s leaked %d rows to gym B", path, len(list))
	}
	var users []map[string]any
	e.expect(e.do("GET", "/api/v1/gym/users", bt, nil), 200).json(t, &users)
	must(t, len(users) == 1, "gym B should only see its own admin, got %d", len(users))

	var rep struct {
		ActiveMembers int   `json:"active_members"`
		RevenueMinor  int64 `json:"revenue_minor"`
	}
	e.expect(e.do("GET", "/api/v1/gym/reports/daily", bt, nil), 200).json(t, &rep)
	must(t, rep.ActiveMembers == 0 && rep.RevenueMinor == 0, "gym B report leaked: %+v", rep)
	e.expect(e.do("GET", "/api/v1/gym/reports/daily", a.AdminToken, nil), 200).json(t, &rep)
	must(t, rep.ActiveMembers == 1 && rep.RevenueMinor == 50000, "gym A report: %+v", rep)

	// Each gym only sees its own WhatsApp session.
	var ws struct {
		Session struct {
			TenantID    string `json:"tenant_id"`
			SessionName string `json:"session_name"`
		}
	}
	e.expect(e.do("GET", "/api/v1/gym/whatsapp", bt, nil), 200).json(t, &ws)
	must(t, ws.Session.TenantID == b.ID && ws.Session.SessionName == b.Code, "gym B session: %+v", ws)

	// Gym A's data is untouched.
	m := e.expect(e.do("GET", "/api/v1/gym/members/"+memberA, a.AdminToken, nil), 200).m(t)
	must(t, m["full_name"] == "Alice A", "gym A member modified: %v", m)
	var pays struct{ Items []struct{ ID string } }
	e.expect(e.do("GET", "/api/v1/gym/payments", a.AdminToken, nil), 200).json(t, &pays)
	must(t, len(pays.Items) == 1 && pays.Items[0].ID == payA, "gym A payments: %+v", pays)
	c := e.expect(e.do("GET", "/api/v1/gym/campaigns/"+campA, a.AdminToken, nil), 200).m(t)
	must(t, c["status"] == "PENDING_APPROVAL", "gym A campaign status changed: %v", c["status"])
	e.expect(e.do("GET", "/api/v1/gym/holidays", a.AdminToken, nil), 200)
	must(t, strings.Contains(string(e.do("GET", "/api/v1/gym/holidays", a.AdminToken, nil).Body), holA), "gym A holiday deleted")
}
