package domain

import (
	"encoding/json"
	"testing"
	"time"
)

func d(s string) Date {
	v, err := ParseDate(s)
	if err != nil {
		panic(err)
	}
	return v
}

func TestRolePermissions(t *testing.T) {
	cases := []struct {
		role Role
		perm Permission
		want bool
	}{
		{RoleGymAdmin, PermUsersManage, true},
		{RoleGymAdmin, PermWhatsAppManage, true},
		{RoleGymManager, PermUsersManage, false},
		{RoleGymManager, PermWhatsAppManage, false},
		{RoleGymManager, PermCampaignsApprove, true},
		{RoleGymManager, PermReportsRead, true},
		{RoleReceptionist, PermPaymentsWrite, true},
		{RoleReceptionist, PermPlansWrite, false},
		{RoleReceptionist, PermCampaignsRead, false},
		{RoleTrainer, PermAttendanceWrite, true},
		{RoleTrainer, PermMembersWrite, false},
		{RoleTrainer, PermPaymentsRead, false},
		{RolePlatformAdmin, PermMembersRead, false},
		{RolePlatformAdmin, PermPlatformManage, true},
		{Role("HACKER"), PermMembersRead, false},
	}
	for _, c := range cases {
		if got := c.role.Can(c.perm); got != c.want {
			t.Errorf("%s.Can(%s) = %v, want %v", c.role, c.perm, got, c.want)
		}
	}
	if _, ok := ParseGymRole("PLATFORM_ADMIN"); ok {
		t.Error("PLATFORM_ADMIN must not be assignable as a gym role")
	}
}

func TestPlanEndDate(t *testing.T) {
	days := 10
	cases := []struct {
		plan  MembershipPlan
		start string
		want  string
	}{
		{MembershipPlan{DurationType: DurationMonthly}, "2026-01-15", "2026-02-14"},
		{MembershipPlan{DurationType: DurationQuarterly}, "2026-01-01", "2026-03-31"},
		{MembershipPlan{DurationType: DurationHalfYearly}, "2026-01-01", "2026-06-30"},
		{MembershipPlan{DurationType: DurationYearly}, "2026-03-01", "2027-02-28"},
		{MembershipPlan{DurationType: DurationCustom, DurationDays: &days}, "2026-01-01", "2026-01-10"},
	}
	for _, c := range cases {
		if got := c.plan.EndDate(d(c.start)).String(); got != c.want {
			t.Errorf("%s from %s: got %s want %s", c.plan.DurationType, c.start, got, c.want)
		}
	}
}

func TestValidateDuration(t *testing.T) {
	zero := 0
	if ValidateDuration(DurationCustom, nil) == nil || ValidateDuration(DurationCustom, &zero) == nil {
		t.Error("custom plan without days must be invalid")
	}
	if ValidateDuration("WEEKLY", nil) == nil {
		t.Error("unknown duration must be invalid")
	}
	if ValidateDuration(DurationMonthly, nil) != nil {
		t.Error("monthly must be valid")
	}
}

func TestRenewalStart(t *testing.T) {
	today := d("2026-05-10")
	if got := RenewalStart(d("2026-05-20"), today); got.String() != "2026-05-21" {
		t.Errorf("active renewal should continue after expiry, got %s", got)
	}
	if got := RenewalStart(d("2026-04-01"), today); got.String() != "2026-05-10" {
		t.Errorf("lapsed renewal should start today, got %s", got)
	}
}

func TestMembershipDerive(t *testing.T) {
	today := d("2026-05-10")
	m := Membership{StartDate: d("2026-05-01"), EndDate: d("2026-05-31"), TotalAmountMinor: 1000, PaidAmountMinor: 400}
	m.Derive(today)
	if m.State != MembershipActive || m.PaymentStatus != PaymentPartial || m.PendingMinor != 600 {
		t.Errorf("unexpected derive: %+v", m)
	}
	if MembershipStateOn(d("2026-06-01"), d("2026-06-30"), false, today) != MembershipUpcoming {
		t.Error("future membership should be upcoming")
	}
	if MembershipStateOn(d("2026-04-01"), d("2026-05-09"), false, today) != MembershipExpired {
		t.Error("past membership should be expired")
	}
	if MembershipStateOn(d("2026-05-01"), d("2026-05-31"), true, today) != MembershipCancelled {
		t.Error("cancelled wins")
	}
	if PaymentStatusFor(0, 0) != PaymentPaid || PaymentStatusFor(100, 0) != PaymentUnpaid || PaymentStatusFor(100, 100) != PaymentPaid {
		t.Error("payment status mismatch")
	}
}

func TestNormalizePhone(t *testing.T) {
	cases := map[string]string{
		"98765 43210":      "919876543210",
		"+91-98765-43210":  "919876543210",
		"0919876543210":    "919876543210",
		"+1 (415) 5550100": "14155550100",
	}
	for in, want := range cases {
		got, err := NormalizePhone(in, "91")
		if err != nil || got != want {
			t.Errorf("NormalizePhone(%q) = %q, %v; want %q", in, got, err, want)
		}
	}
	if _, err := NormalizePhone("123", "91"); err == nil {
		t.Error("short numbers must be rejected")
	}
}

func TestTodayAndDayBounds(t *testing.T) {
	now := time.Date(2026, 5, 10, 20, 0, 0, 0, time.UTC) // 01:30 on May 11 in Kolkata
	if got := Today(now, "Asia/Kolkata").String(); got != "2026-05-11" {
		t.Errorf("Today in Kolkata = %s", got)
	}
	start, end := DayBounds(d("2026-05-11"), "Asia/Kolkata")
	if start.Format(time.RFC3339) != "2026-05-10T18:30:00Z" || end.Sub(start) != 24*time.Hour {
		t.Errorf("DayBounds = %s .. %s", start, end)
	}
}

func TestDateJSON(t *testing.T) {
	var v struct {
		A Date     `json:"a"`
		B NullDate `json:"b"`
		C NullDate `json:"c"`
	}
	if err := json.Unmarshal([]byte(`{"a":"2026-01-02","b":null,"c":"2026-03-04"}`), &v); err != nil {
		t.Fatal(err)
	}
	if v.A.String() != "2026-01-02" || v.B.Valid || !v.C.Valid {
		t.Errorf("unexpected %+v", v)
	}
	out, _ := json.Marshal(v)
	if string(out) != `{"a":"2026-01-02","b":null,"c":"2026-03-04"}` {
		t.Errorf("marshal = %s", out)
	}
	if json.Unmarshal([]byte(`{"a":"02/01/2026"}`), &v) == nil {
		t.Error("invalid date format must fail")
	}
}

func TestRenderTemplateAndKeys(t *testing.T) {
	got := RenderTemplate("Hi {{name}}, {{gym}} {{unknown}}", map[string]string{"name": "Rahul", "gym": "Iron House"})
	if got != "Hi Rahul, Iron House {{unknown}}" {
		t.Errorf("render = %q", got)
	}
	if ExpiryKey("m1", 7) != "expiry:m1:7d" || BirthdayKey("x", 2026) != "birthday:x:2026" ||
		DailyReportKey(d("2026-01-02")) != "daily_report:2026-01-02" || CampaignKey("c", "r") != "campaign:c:r" ||
		HolidayKey("h", "m", 1) != "holiday:h:m:1d" {
		t.Error("dedupe key format changed")
	}
}
