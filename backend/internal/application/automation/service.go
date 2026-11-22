// Package automation serves the n8n workflows: it computes which notifications
// are due across all active tenants and delivers them with duplicate
// prevention. Business rules and consent checks live here, not in n8n.
package automation

import (
	"context"
	"fmt"
	"log/slog"
	"slices"
	"strconv"
	"time"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/audit"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/messaging"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/report"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

type Repo interface {
	ListAutomationTenants(ctx context.Context) ([]domain.AutomationTenant, error)
	GetAutomationTenant(ctx context.Context, tenantID string) (domain.AutomationTenant, error)
	GetAutomationSettings(ctx context.Context, tenantID string) (domain.AutomationSettings, error)
	UpdateAutomationSettings(ctx context.Context, tenantID string, a domain.AutomationSettings) error
	GetMessagingPreferences(ctx context.Context, tenantID string) (domain.MessagingPreferences, error)
	ExpiryCandidates(ctx context.Context, tenantID string, dates []domain.Date, membershipID string) ([]domain.ExpiryCandidate, error)
	NotifiableMembers(ctx context.Context, tenantID string, today domain.Date, memberID string) ([]domain.MemberContact, error)
	BirthdayMembers(ctx context.Context, tenantID string, month, day int, memberID string) ([]domain.MemberContact, error)
	ListHolidays(ctx context.Context, tenantID string, from, to *domain.Date) ([]domain.Holiday, error)
	SettledKeys(ctx context.Context, tenantID string, keys []string) (map[string]bool, error)
	ClaimNotification(ctx context.Context, tenantID, key, typ, phone string) (string, bool, error)
	FinishNotification(ctx context.Context, id, status, errMsg string) error
	CountMessagesSince(ctx context.Context, tenantID string, since time.Time) (int, error)
}

type Reports interface {
	Daily(ctx context.Context, tenantID, tz string, date *domain.Date) (domain.DailyReport, error)
}

type Service struct {
	repo      Repo
	msg       *messaging.Service
	reports   Reports
	audit     *audit.Logger
	defaultCC string
	log       *slog.Logger
	now       func() time.Time
}

func NewService(repo Repo, msg *messaging.Service, reports Reports, a *audit.Logger, defaultCC string, log *slog.Logger) *Service {
	return &Service{repo: repo, msg: msg, reports: reports, audit: a, defaultCC: defaultCC, log: log, now: time.Now}
}

// SetClock overrides the clock (tests).
func (s *Service) SetClock(now func() time.Time) { s.now = now }

var notificationTypes = []string{domain.NotifyExpiry, domain.NotifyHoliday, domain.NotifyBirthday, domain.NotifyDailyReport}

func validType(t string) bool { return slices.Contains(notificationTypes, t) }

// item is a fully rendered notification.
type item struct {
	domain.DueNotification
	category string
	body     string
}

// tenantItems builds every currently eligible notification of typ for one
// tenant, before dedupe filtering.
func (s *Service) tenantItems(ctx context.Context, at domain.AutomationTenant, typ string) ([]item, error) {
	t := at.Tenant
	settings, err := s.repo.GetAutomationSettings(ctx, t.ID)
	if err != nil {
		return nil, err
	}
	prefs, err := s.repo.GetMessagingPreferences(ctx, t.ID)
	if err != nil {
		return nil, err
	}
	today := domain.Today(s.now(), t.Timezone)
	mk := func(key, name, phone, category, body string) item {
		return item{DueNotification: domain.DueNotification{TenantID: t.ID, TenantCode: t.Code, Type: typ, DedupeKey: key,
			RecipientName: name, RecipientPhone: phone, Preview: body}, category: category, body: body}
	}
	var out []item
	switch typ {
	case domain.NotifyExpiry:
		if !settings.ExpiryEnabled {
			return nil, nil
		}
		byDate := map[string]int{}
		var dates []domain.Date
		for _, n := range settings.ExpiryDaysBefore {
			d := today.AddDays(n)
			byDate[d.String()] = n
			dates = append(dates, d)
		}
		cands, err := s.repo.ExpiryCandidates(ctx, t.ID, dates, "")
		if err != nil {
			return nil, err
		}
		for _, c := range cands {
			n := byDate[c.EndDate.String()]
			body := domain.RenderTemplate(prefs.ExpiryTemplate, map[string]string{
				"name": c.MemberName, "gym": t.Name, "plan": c.PlanName, "date": c.EndDate.String(),
				"days": strconv.Itoa(n), "days_text": daysText(n)})
			out = append(out, mk(domain.ExpiryKey(c.MembershipID, n), c.MemberName, c.Phone, domain.CategoryExpiry, body))
		}
	case domain.NotifyHoliday:
		if !settings.HolidayEnabled {
			return nil, nil
		}
		to := today.AddDays(31)
		holidays, err := s.repo.ListHolidays(ctx, t.ID, &today, &to)
		if err != nil {
			return nil, err
		}
		var members []domain.MemberContact
		for _, h := range holidays {
			n := today.DaysUntil(h.HolidayDate)
			if !h.NotifyEnabled || !slices.Contains(h.NotifyDaysBefore, n) {
				continue
			}
			if members == nil {
				if members, err = s.repo.NotifiableMembers(ctx, t.ID, today, ""); err != nil {
					return nil, err
				}
			}
			for _, m := range members {
				body := domain.RenderTemplate(prefs.HolidayTemplate, map[string]string{
					"name": m.Name, "gym": t.Name, "holiday": h.Title, "date": h.HolidayDate.String(),
					"description": h.Description, "days": strconv.Itoa(n)})
				out = append(out, mk(domain.HolidayKey(h.ID, m.ID, n), m.Name, m.Phone, domain.CategoryHoliday, body))
			}
		}
	case domain.NotifyBirthday:
		if !settings.BirthdayEnabled {
			return nil, nil
		}
		members, err := s.repo.BirthdayMembers(ctx, t.ID, int(today.Month()), today.Day(), "")
		if err != nil {
			return nil, err
		}
		for _, m := range members {
			body := domain.RenderTemplate(prefs.BirthdayTemplate, map[string]string{"name": m.Name, "gym": t.Name})
			out = append(out, mk(domain.BirthdayKey(m.ID, today.Year()), m.Name, m.Phone, domain.CategoryBirthday, body))
		}
	case domain.NotifyDailyReport:
		if !settings.DailyReportEnabled {
			return nil, nil
		}
		phone, err := domain.NormalizePhone(firstNonEmpty(settings.DailyReportPhone, t.ContactNumber), s.defaultCC)
		if err != nil {
			return nil, nil
		}
		r, err := s.reports.Daily(ctx, t.ID, t.Timezone, &today)
		if err != nil {
			return nil, err
		}
		body := report.DailySummaryText(t.Name, t.Currency, r)
		out = append(out, mk(domain.DailyReportKey(today), t.OwnerName, phone, domain.CategoryDailyReport, body))
	}
	return out, nil
}

func daysText(n int) string {
	switch n {
	case 0:
		return "today"
	case 1:
		return "tomorrow"
	default:
		return fmt.Sprintf("in %d days", n)
	}
}

func firstNonEmpty(v ...string) string {
	for _, s := range v {
		if s != "" {
			return s
		}
	}
	return ""
}

// Due lists notifications of typ that are eligible and not yet sent, across
// all active tenants with a connected WhatsApp session.
func (s *Service) Due(ctx context.Context, typ string, limit int) ([]domain.DueNotification, error) {
	if !validType(typ) {
		return nil, domain.InvalidField("type", "must be expiry, holiday, birthday or daily_report")
	}
	if limit <= 0 || limit > 1000 {
		limit = 200
	}
	tenants, err := s.repo.ListAutomationTenants(ctx)
	if err != nil {
		return nil, err
	}
	out := []domain.DueNotification{}
	for _, at := range tenants {
		if at.SessionStatus != domain.SessionWorking {
			continue
		}
		items, err := s.tenantItems(ctx, at, typ)
		if err != nil {
			s.log.Error("automation: build items failed", "tenant", at.Tenant.Code, "type", typ, "error", err)
			continue
		}
		keys := make([]string, len(items))
		for i, it := range items {
			keys[i] = it.DedupeKey
		}
		settled, err := s.repo.SettledKeys(ctx, at.Tenant.ID, keys)
		if err != nil {
			return nil, err
		}
		for _, it := range items {
			if settled[it.DedupeKey] {
				continue
			}
			out = append(out, it.DueNotification)
			if len(out) >= limit {
				return out, nil
			}
		}
	}
	return out, nil
}

type SendInput struct {
	TenantID  string `json:"tenant_id" validate:"required,uuid"`
	Type      string `json:"type" validate:"required"`
	DedupeKey string `json:"dedupe_key" validate:"required,max=191"`
}

// Send delivers one due notification. Eligibility is recomputed server-side
// and the dedupe key is claimed atomically, so retries never double-send.
func (s *Service) Send(ctx context.Context, in SendInput) (domain.SendResult, error) {
	res := domain.SendResult{DedupeKey: in.DedupeKey, Status: "SKIPPED"}
	if !validType(in.Type) {
		return res, domain.InvalidField("type", "must be expiry, holiday, birthday or daily_report")
	}
	at, err := s.repo.GetAutomationTenant(ctx, in.TenantID)
	if err != nil {
		return res, err
	}
	if reason := tenantBlocked(at); reason != "" {
		res.Reason = reason
		return res, nil
	}
	items, err := s.tenantItems(ctx, at, in.Type)
	if err != nil {
		return res, err
	}
	idx := slices.IndexFunc(items, func(it item) bool { return it.DedupeKey == in.DedupeKey })
	if idx < 0 {
		res.Reason = "not eligible"
		return res, nil
	}
	return s.deliver(ctx, at, items[idx].DueNotification.Type, items[idx].DedupeKey, messaging.Outbound{
		TenantID: at.Tenant.ID, Phone: items[idx].RecipientPhone, Name: items[idx].RecipientName,
		Category: items[idx].category, Body: items[idx].body})
}

func tenantBlocked(at domain.AutomationTenant) string {
	switch {
	case at.Tenant.Status != domain.TenantActive:
		return "tenant inactive"
	case !at.Tenant.WhatsAppEnabled:
		return "whatsapp disabled for tenant"
	case at.SessionStatus != domain.SessionWorking:
		return "whatsapp not connected"
	}
	return ""
}

// deliver claims key, enforces the tenant's daily limit, sends and records
// the outcome.
func (s *Service) deliver(ctx context.Context, at domain.AutomationTenant, typ, key string, o messaging.Outbound) (domain.SendResult, error) {
	res := domain.SendResult{DedupeKey: key, Status: "SKIPPED"}
	prefs, err := s.repo.GetMessagingPreferences(ctx, at.Tenant.ID)
	if err != nil {
		return res, err
	}
	dayStart, _ := domain.DayBounds(domain.Today(s.now(), at.Tenant.Timezone), at.Tenant.Timezone)
	sentToday, err := s.repo.CountMessagesSince(ctx, at.Tenant.ID, dayStart)
	if err != nil {
		return res, err
	}
	if sentToday >= prefs.DailyMessageLimit {
		res.Reason = "daily message limit reached"
		return res, nil
	}
	claimID, claimed, err := s.repo.ClaimNotification(ctx, at.Tenant.ID, key, typ, o.Phone)
	if err != nil {
		return res, err
	}
	if !claimed {
		res.Reason = "already sent"
		return res, nil
	}
	o.NotificationLogID = &claimID
	log, err := s.msg.Send(ctx, o)
	if err != nil {
		_ = s.repo.FinishNotification(ctx, claimID, "FAILED", err.Error())
		return res, err
	}
	if err := s.repo.FinishNotification(ctx, claimID, log.Status, log.Error); err != nil {
		return res, err
	}
	res.Status, res.Reason, res.MessageID = log.Status, log.Error, log.ID
	return res, nil
}

// Deliver is the shared delivery path used by campaigns.
func (s *Service) Deliver(ctx context.Context, at domain.AutomationTenant, typ, key string, o messaging.Outbound) (domain.SendResult, error) {
	return s.deliver(ctx, at, typ, key, o)
}

func (s *Service) Settings(ctx context.Context, p domain.Principal) (domain.AutomationSettings, error) {
	return s.repo.GetAutomationSettings(ctx, p.TenantID)
}

type SettingsInput struct {
	ExpiryEnabled      bool   `json:"expiry_enabled"`
	ExpiryDaysBefore   []int  `json:"expiry_days_before" validate:"max=6,dive,min=0,max=60"`
	HolidayEnabled     bool   `json:"holiday_enabled"`
	BirthdayEnabled    bool   `json:"birthday_enabled"`
	CampaignsEnabled   bool   `json:"campaigns_enabled"`
	DailyReportEnabled bool   `json:"daily_report_enabled"`
	DailyReportPhone   string `json:"daily_report_phone" validate:"max=20"`
}

func (s *Service) UpdateSettings(ctx context.Context, p domain.Principal, in SettingsInput) (domain.AutomationSettings, error) {
	days := slices.Clone(in.ExpiryDaysBefore)
	if len(days) == 0 {
		days = slices.Clone(domain.DefaultExpiryDaysBefore)
	}
	slices.Sort(days)
	slices.Reverse(days)
	a := domain.AutomationSettings{ExpiryEnabled: in.ExpiryEnabled, ExpiryDaysBefore: slices.Compact(days),
		HolidayEnabled: in.HolidayEnabled, BirthdayEnabled: in.BirthdayEnabled, CampaignsEnabled: in.CampaignsEnabled,
		DailyReportEnabled: in.DailyReportEnabled}
	if in.DailyReportPhone != "" {
		phone, err := domain.NormalizePhone(in.DailyReportPhone, s.defaultCC)
		if err != nil {
			return a, err
		}
		a.DailyReportPhone = phone
	}
	if err := s.repo.UpdateAutomationSettings(ctx, p.TenantID, a); err != nil {
		return a, err
	}
	s.audit.Record(ctx, p, p.TenantID, "automation.settings_update", "tenant", p.TenantID, nil)
	return a, nil
}
