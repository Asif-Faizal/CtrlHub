//go:build integration

package tests

import (
	"testing"
)

type dueList struct {
	Items []struct {
		TenantID       string `json:"tenant_id"`
		Type           string `json:"type"`
		DedupeKey      string `json:"dedupe_key"`
		RecipientPhone string `json:"recipient_phone"`
		Preview        string `json:"preview"`
	}
	Count int
}

func (e *env) due(typ string) dueList {
	var d dueList
	e.expect(e.auto("GET", "/api/v1/automation/notifications/due?type="+typ, nil), 200).json(e.t, &d)
	return d
}

func (e *env) send(tenantID, typ, key string) map[string]any {
	return e.expect(e.auto("POST", "/api/v1/automation/notifications/send", map[string]string{
		"tenant_id": tenantID, "type": typ, "dedupe_key": key}), 200).m(e.t)
}

func TestAutomationRequiresKey(t *testing.T) {
	e := setup(t)
	e.expect(e.do("GET", "/api/v1/automation/notifications/due?type=expiry", "", nil), 401)
	e.expect(e.do("GET", "/api/v1/automation/notifications/due?type=expiry", "", nil, "X-Automation-Key", "wrong"), 401)
	// A user JWT is not an automation credential.
	e.expect(e.do("GET", "/api/v1/automation/notifications/due?type=expiry", e.platform().AccessToken, nil), 401)
}

func TestWhatsAppConnectAndTestMessage(t *testing.T) {
	e := setup(t)
	p := e.platform()
	g := e.onboard(p.AccessToken, "Gym A", "a@gym.test")
	e.expect(e.do("POST", "/api/v1/gym/whatsapp/test-message", g.AdminToken, map[string]any{"phone": "9800000000"}), 400)
	ws := e.expect(e.do("POST", "/api/v1/gym/whatsapp/connect", g.AdminToken, nil), 200).m(t)
	must(t, ws["session_name"] == g.Code && ws["status"] == "WORKING", "connect: %v", ws)
	msg := e.expect(e.do("POST", "/api/v1/gym/whatsapp/test-message", g.AdminToken, map[string]any{"phone": "9800000000"}), 200).m(t)
	must(t, msg["status"] == "SENT" && msg["provider"] == "mock" && msg["recipient_phone"] == "919800000000", "test msg: %v", msg)
	var sessions []map[string]any
	e.expect(e.do("GET", "/api/v1/platform/whatsapp-sessions", p.AccessToken, nil), 200).json(t, &sessions)
	must(t, len(sessions) == 1 && sessions[0]["status"] == "WORKING", "platform view: %v", sessions)
	e.expect(e.do("POST", "/api/v1/gym/whatsapp/disconnect", g.AdminToken, nil), 200)
	var page struct{ Total int }
	e.expect(e.do("GET", "/api/v1/gym/messages", g.AdminToken, nil), 200).json(t, &page)
	must(t, page.Total == 1, "message log: %d", page.Total)
}

func TestExpiryHolidayBirthdayAndReportAutomation(t *testing.T) {
	e := setup(t)
	p := e.platform()
	a := e.onboard(p.AccessToken, "Gym A", "a@gym.test")
	b := e.onboard(p.AccessToken, "Gym B", "b@gym.test")
	today := todayIST()

	// Nothing is due while WhatsApp is not connected.
	pass := e.createPlan(a.AdminToken, "8 day pass", 8, 10000) // ends today+7
	consenting := e.createMember(a.AdminToken, "Consenting", "9811111111", true, "1990-"+today.Format("01-02"))
	silent := e.createMember(a.AdminToken, "No Consent", "9822222222", false, "1990-"+today.Format("01-02"))
	e.assign(a.AdminToken, consenting, pass, nil)
	e.assign(a.AdminToken, silent, pass, nil)
	must(t, e.due("expiry").Count == 0, "nothing should be due before WhatsApp connects")

	e.expect(e.do("POST", "/api/v1/gym/whatsapp/connect", a.AdminToken, nil), 200)
	e.expect(e.do("POST", "/api/v1/gym/whatsapp/connect", b.AdminToken, nil), 200)
	planB := e.createPlan(b.AdminToken, "B pass", 8, 10000)
	memberB := e.createMember(b.AdminToken, "B member", "9833333333", true, "")
	e.assign(b.AdminToken, memberB, planB, nil)

	// Expiry: only consenting members, each tenant via its own session.
	d := e.due("expiry")
	must(t, d.Count == 2, "expiry due: %+v", d)
	for _, it := range d.Items {
		must(t, it.RecipientPhone != "919822222222", "non-consenting member must not be notified")
		r := e.send(it.TenantID, "expiry", it.DedupeKey)
		must(t, r["status"] == "SENT", "send: %v", r)
	}
	sent := e.provider.Sent()
	must(t, len(sent) == 2, "provider sent %d", len(sent))
	sessions := map[string]bool{sent[0].Session: true, sent[1].Session: true}
	must(t, sessions[a.Code] && sessions[b.Code], "messages must use each tenant's session: %+v", sent)

	// Duplicates are prevented.
	must(t, e.due("expiry").Count == 0, "expiry should not be due twice")
	r := e.send(d.Items[0].TenantID, "expiry", d.Items[0].DedupeKey)
	must(t, r["status"] == "SKIPPED", "resend: %v", r)
	// A forged key for another tenant's membership is not eligible.
	r = e.send(b.ID, "expiry", d.Items[0].DedupeKey)
	if d.Items[0].TenantID == b.ID {
		r = e.send(a.ID, "expiry", d.Items[0].DedupeKey)
	}
	must(t, r["status"] == "SKIPPED", "cross-tenant key: %v", r)

	// Disabling automation stops reminders.
	e.expect(e.do("PUT", "/api/v1/gym/automation-settings", a.AdminToken, map[string]any{
		"expiry_enabled": false, "holiday_enabled": true, "birthday_enabled": true, "campaigns_enabled": true,
		"daily_report_enabled": true}), 200)

	// Holiday 3 days ahead with a 3-day reminder.
	e.expect(e.do("POST", "/api/v1/gym/holidays", a.AdminToken, map[string]any{
		"title": "Vishu", "holiday_date": ymd(today.AddDate(0, 0, 3)), "notify_days_before": []int{3, 1}}), 201)
	hd := e.due("holiday")
	must(t, hd.Count == 1 && hd.Items[0].TenantID == a.ID, "holiday due: %+v", hd)
	must(t, e.send(a.ID, "holiday", hd.Items[0].DedupeKey)["status"] == "SENT", "holiday send")
	must(t, e.due("holiday").Count == 0, "holiday must not repeat")

	// Birthday: only the consenting member.
	bd := e.due("birthday")
	must(t, bd.Count == 1 && bd.Items[0].RecipientPhone == "919811111111", "birthday due: %+v", bd)
	must(t, e.send(a.ID, "birthday", bd.Items[0].DedupeKey)["status"] == "SENT", "birthday send")

	// Daily report: one per tenant per day, to the owner contact number.
	dr := e.due("daily_report")
	must(t, dr.Count == 2, "daily report due: %+v", dr)
	for _, it := range dr.Items {
		must(t, e.send(it.TenantID, "daily_report", it.DedupeKey)["status"] == "SENT", "report send")
	}
	must(t, e.due("daily_report").Count == 0, "report must not repeat")

	var logs struct {
		Items []struct{ Category, Status string }
		Total int
	}
	e.expect(e.do("GET", "/api/v1/gym/messages", a.AdminToken, nil), 200).json(t, &logs)
	must(t, logs.Total == 4, "gym A message history: %+v", logs)
}

func TestCampaignApprovalAndDelivery(t *testing.T) {
	e := setup(t)
	p := e.platform()
	g := e.onboard(p.AccessToken, "Gym A", "a@gym.test")
	manager := e.addUser(g.AdminToken, "GYM_MANAGER", "m@gym.test")
	e.expect(e.do("POST", "/api/v1/gym/whatsapp/connect", g.AdminToken, nil), 200)

	plan := e.createPlan(g.AdminToken, "Monthly", 0, 100000)
	for i, optIn := range []bool{true, true, false} {
		id := e.createMember(g.AdminToken, "M", "98100000"+string(rune('0'+i))+"0", optIn, "")
		e.assign(g.AdminToken, id, plan, nil)
	}

	c := e.expect(e.do("POST", "/api/v1/gym/campaigns", manager.AccessToken, map[string]any{
		"name": "New year offer", "message": "Hi {{name}}, 20% off at {{gym}}", "audience": "ACTIVE_MEMBERS"}), 201).m(t)
	id := c["id"].(string)

	// Not approved yet: nothing is queued and approval requires submission.
	e.expect(e.do("POST", "/api/v1/gym/campaigns/"+id+"/approve", g.AdminToken, nil), 409)
	var pending struct {
		Items []map[string]any
		Count int
	}
	e.expect(e.auto("GET", "/api/v1/automation/campaigns/pending", nil), 200).json(t, &pending)
	must(t, pending.Count == 0, "draft campaign must not be queued")

	e.expect(e.do("POST", "/api/v1/gym/campaigns/"+id+"/submit", manager.AccessToken, nil), 200)
	c = e.expect(e.do("POST", "/api/v1/gym/campaigns/"+id+"/approve", g.AdminToken, nil), 200).m(t)
	must(t, c["status"] == "APPROVED" && c["recipients_total"].(float64) == 2, "approved: %v", c)

	e.expect(e.auto("GET", "/api/v1/automation/campaigns/pending", nil), 200).json(t, &pending)
	must(t, pending.Count == 2, "pending recipients: %+v", pending)
	for _, it := range pending.Items {
		r := e.expect(e.auto("POST", "/api/v1/automation/campaigns/send", map[string]any{
			"tenant_id": it["tenant_id"], "recipient_id": it["recipient_id"]}), 200).m(t)
		must(t, r["status"] == "SENT", "campaign send: %v", r)
		r = e.expect(e.auto("POST", "/api/v1/automation/campaigns/send", map[string]any{
			"tenant_id": it["tenant_id"], "recipient_id": it["recipient_id"]}), 200).m(t)
		must(t, r["status"] == "SKIPPED", "campaign resend: %v", r)
	}
	c = e.expect(e.do("GET", "/api/v1/gym/campaigns/"+id, g.AdminToken, nil), 200).m(t)
	must(t, c["status"] == "COMPLETED" && c["sent_count"].(float64) == 2, "completed: %v", c)
	last := e.provider.Sent()[len(e.provider.Sent())-1]
	must(t, last.Text == "Hi M, 20% off at Gym A", "rendered message: %q", last.Text)
}
