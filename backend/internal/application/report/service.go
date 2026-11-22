// Package report builds per-tenant operational reports.
package report

import (
	"context"
	"fmt"
	"time"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

type Repo interface {
	DailyReport(ctx context.Context, tenantID string, d domain.Date, dayStart, dayEnd time.Time) (domain.DailyReport, error)
}

type Service struct {
	repo Repo
	now  func() time.Time
}

func NewService(repo Repo) *Service { return &Service{repo: repo, now: time.Now} }

// Daily returns the report for date (today when nil) in the tenant's timezone.
func (s *Service) Daily(ctx context.Context, tenantID, tz string, date *domain.Date) (domain.DailyReport, error) {
	d := domain.Today(s.now(), tz)
	if date != nil {
		d = *date
	}
	start, end := domain.DayBounds(d, tz)
	return s.repo.DailyReport(ctx, tenantID, d, start, end)
}

// FormatMoney renders minor units, e.g. 150000 INR -> "INR 1500.00".
func FormatMoney(minor int64, currency string) string {
	return fmt.Sprintf("%s %d.%02d", currency, minor/100, abs(minor%100))
}

func abs(v int64) int64 {
	if v < 0 {
		return -v
	}
	return v
}

// DailySummaryText is the WhatsApp text sent to gym owners.
func DailySummaryText(gym, currency string, r domain.DailyReport) string {
	return fmt.Sprintf("Daily report for %s (%s)\n"+
		"Active members: %d\nNew members: %d\nRenewals: %d\nExpiring in 7 days: %d\nExpired yesterday: %d\n"+
		"Check-ins: %d\nRevenue collected: %s\nPending payments: %s",
		gym, r.Date, r.ActiveMembers, r.NewMembers, r.Renewals, r.ExpiringNext7Days, r.ExpiredToday,
		r.Attendance, FormatMoney(r.RevenueMinor, currency), FormatMoney(r.PendingPaymentsMinor, currency))
}
