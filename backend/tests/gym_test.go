//go:build integration

package tests

import "testing"

func TestMembershipLifecycle(t *testing.T) {
	e := setup(t)
	p := e.platform()
	g := e.onboard(p.AccessToken, "Iron House", "rahul@iron.test")
	tok := g.AdminToken
	today := todayIST()

	member := e.createMember(tok, "Rahul Member", "+91 98111 11111", true, "1995-06-15")
	m := e.expect(e.do("GET", "/api/v1/gym/members/"+member, tok, nil), 200).m(t)
	must(t, m["phone"] == "919811111111" && m["membership_status"] == "NONE", "member: %v", m)
	e.expect(e.do("POST", "/api/v1/gym/members", tok, map[string]any{"full_name": "Dup", "phone": "9811111111"}), 409)

	monthly := e.createPlan(tok, "Monthly", 0, 150000)
	custom := e.createPlan(tok, "10 day pass", 10, 50000)
	e.expect(e.do("POST", "/api/v1/gym/plans", tok, map[string]any{"name": "Bad", "duration_type": "CUSTOM", "price_minor": 1}), 400)

	// Assign with a partial initial payment.
	ms := e.assign(tok, member, monthly, map[string]any{"initial_payment_minor": 50000, "payment_method": "UPI"})
	must(t, ms["start_date"] == ymd(today) && ms["status"] == "ACTIVE" && ms["payment_status"] == "PARTIAL" &&
		ms["pending_amount_minor"].(float64) == 100000, "membership: %v", ms)
	msID := ms["id"].(string)

	// Overpayment is rejected; exact remaining amount is accepted.
	e.expect(e.do("POST", "/api/v1/gym/payments", tok, map[string]any{
		"member_id": member, "membership_id": msID, "amount_minor": 100001, "method": "CASH"}), 400)
	e.expect(e.do("POST", "/api/v1/gym/payments", tok, map[string]any{
		"member_id": member, "membership_id": msID, "amount_minor": 100000, "method": "CASH"}), 201)
	ms = e.expect(e.do("GET", "/api/v1/gym/memberships/"+msID, tok, nil), 200).m(t)
	must(t, ms["payment_status"] == "PAID" && ms["paid_amount_minor"].(float64) == 150000, "after payment: %v", ms)

	// Renewal appends a new period after the current one and keeps history.
	renewed := e.expect(e.do("POST", "/api/v1/gym/memberships/"+msID+"/renew", tok, map[string]any{"plan_id": custom}), 201).m(t)
	end := ms["end_date"].(string)
	must(t, renewed["renewed_from_id"] == msID && renewed["status"] == "UPCOMING" && renewed["plan_name"] == "10 day pass",
		"renewal: %v", renewed)
	must(t, renewed["start_date"].(string) > end, "renewal must start after %s: %v", end, renewed["start_date"])

	var history struct {
		Items []map[string]any
		Total int
	}
	e.expect(e.do("GET", "/api/v1/gym/members/"+member+"/memberships", tok, nil), 200).json(t, &history)
	must(t, history.Total == 2, "history should keep both memberships: %d", history.Total)
	orig := e.expect(e.do("GET", "/api/v1/gym/memberships/"+msID, tok, nil), 200).m(t)
	must(t, orig["end_date"] == end && orig["payment_status"] == "PAID", "original membership changed: %v", orig)

	// Member list filters.
	expired := e.createMember(tok, "Lapsed Member", "9822222222", false, "")
	e.assign(tok, expired, custom, map[string]any{"start_date": ymd(today.AddDate(0, 0, -30))})
	e.createMember(tok, "No Plan", "9833333333", false, "")
	for status, want := range map[string]int{"active": 1, "expired": 1, "none": 1, "": 3} {
		var page struct{ Total int }
		e.expect(e.do("GET", "/api/v1/gym/members?status="+status, tok, nil), 200).json(t, &page)
		must(t, page.Total == want, "status=%q: got %d want %d", status, page.Total, want)
	}
	var search struct{ Total int }
	e.expect(e.do("GET", "/api/v1/gym/members?search=Laps", tok, nil), 200).json(t, &search)
	must(t, search.Total == 1, "search: %d", search.Total)

	// Attendance: once per day, and only with an active membership by default.
	e.expect(e.do("POST", "/api/v1/gym/attendance", tok, map[string]any{"member_id": member}), 201)
	e.expect(e.do("POST", "/api/v1/gym/attendance", tok, map[string]any{"member_id": member}), 409)
	e.expect(e.do("POST", "/api/v1/gym/attendance", tok, map[string]any{"member_id": expired}), 400)
	e.expect(e.do("POST", "/api/v1/gym/attendance", tok, map[string]any{"member_id": expired, "allow_expired": true}), 201)

	// Expiring renewals view excludes the member who already renewed.
	var expiring struct{ Total int }
	e.expect(e.do("GET", "/api/v1/gym/memberships?view=expired&days=60", tok, nil), 200).json(t, &expiring)
	must(t, expiring.Total == 1, "expired not-renewed memberships: %d", expiring.Total)

	rep := e.expect(e.do("GET", "/api/v1/gym/reports/daily", tok, nil), 200).m(t)
	must(t, rep["active_members"].(float64) == 1 && rep["new_members"].(float64) == 3 && rep["renewals"].(float64) == 1 &&
		rep["revenue_minor"].(float64) == 150000 && rep["attendance"].(float64) == 2, "report: %v", rep)
}

func TestValidationErrorsAreConsistent(t *testing.T) {
	e := setup(t)
	p := e.platform()
	r := e.expect(e.do("POST", "/api/v1/platform/tenants", p.AccessToken, map[string]any{
		"gym": map[string]any{"name": "", "timezone": "Mars/Base"}, "admin": map[string]any{"email": "nope"}}), 400)
	body := r.m(t)["error"].(map[string]any)
	must(t, body["code"] == "VALIDATION_ERROR", "code: %v", body)
	details := body["details"].(map[string]any)
	for _, f := range []string{"gym.name", "gym.owner_name", "admin.email", "admin.name"} {
		if _, ok := details[f]; !ok {
			t.Errorf("missing validation detail for %s: %v", f, details)
		}
	}
	e.expect(e.do("POST", "/api/v1/platform/tenants", p.AccessToken, map[string]any{
		"gym":   map[string]any{"name": "G", "owner_name": "O", "contact_number": "1", "email": "g@g.test", "timezone": "Mars/Base"},
		"admin": map[string]any{"name": "A", "email": "a@g.test", "role": "GYM_ADMIN"}}), 400)
}
