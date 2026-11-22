// Package attendance records member check-ins and manages gym holidays.
package attendance

import (
	"context"
	"slices"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

type Repo interface {
	GetMember(ctx context.Context, tenantID, id string, today domain.Date) (domain.Member, error)
	CreateAttendance(ctx context.Context, a *domain.Attendance) error
	ListAttendance(ctx context.Context, tenantID string, date *domain.Date, memberID string, limit int) ([]domain.Attendance, error)
	CreateHoliday(ctx context.Context, h *domain.Holiday, createdBy string) error
	UpdateHoliday(ctx context.Context, h domain.Holiday) error
	DeleteHoliday(ctx context.Context, tenantID, id string) error
	GetHoliday(ctx context.Context, tenantID, id string) (domain.Holiday, error)
	ListHolidays(ctx context.Context, tenantID string, from, to *domain.Date) ([]domain.Holiday, error)
}

type Service struct {
	repo Repo
	now  func() time.Time
}

func NewService(repo Repo) *Service { return &Service{repo: repo, now: time.Now} }

type CheckInInput struct {
	MemberID string `json:"member_id" validate:"required,uuid"`
	// AllowExpired records attendance even without an active membership.
	AllowExpired bool `json:"allow_expired"`
}

func (s *Service) CheckIn(ctx context.Context, p domain.Principal, in CheckInInput) (domain.Attendance, error) {
	today := p.Today(s.now())
	m, err := s.repo.GetMember(ctx, p.TenantID, in.MemberID, today)
	if err == domain.ErrNotFound {
		return domain.Attendance{}, domain.InvalidField("member_id", "member not found")
	}
	if err != nil {
		return domain.Attendance{}, err
	}
	if m.MembershipState != domain.MembershipActive && !in.AllowExpired {
		return domain.Attendance{}, domain.Invalid("member has no active membership")
	}
	a := domain.Attendance{ID: uuid.NewString(), TenantID: p.TenantID, MemberID: m.ID, MemberName: m.FullName,
		AttendanceDate: today, CheckInAt: s.now().UTC(), RecordedBy: &p.UserID}
	return a, s.repo.CreateAttendance(ctx, &a)
}

func (s *Service) List(ctx context.Context, p domain.Principal, date *domain.Date, memberID string) ([]domain.Attendance, error) {
	if date == nil && memberID == "" {
		today := p.Today(s.now())
		date = &today
	}
	return s.repo.ListAttendance(ctx, p.TenantID, date, memberID, 500)
}

type HolidayInput struct {
	Title            string      `json:"title" validate:"required,max=150"`
	Description      string      `json:"description" validate:"max=500"`
	HolidayDate      domain.Date `json:"holiday_date"`
	NotifyEnabled    *bool       `json:"notify_enabled"`
	NotifyDaysBefore []int       `json:"notify_days_before" validate:"max=5,dive,min=0,max=30"`
}

func (in HolidayInput) apply(h *domain.Holiday) {
	h.Title, h.Description, h.HolidayDate = strings.TrimSpace(in.Title), in.Description, in.HolidayDate
	h.NotifyEnabled = in.NotifyEnabled == nil || *in.NotifyEnabled
	days := slices.Clone(in.NotifyDaysBefore)
	if len(days) == 0 {
		days = []int{3, 1}
	}
	slices.Sort(days)
	h.NotifyDaysBefore = slices.Compact(days)
}

func (s *Service) CreateHoliday(ctx context.Context, p domain.Principal, in HolidayInput) (domain.Holiday, error) {
	if in.HolidayDate.IsZero() {
		return domain.Holiday{}, domain.InvalidField("holiday_date", "is required")
	}
	if in.HolidayDate.Before(p.Today(s.now())) {
		return domain.Holiday{}, domain.InvalidField("holiday_date", "cannot be in the past")
	}
	h := domain.Holiday{ID: uuid.NewString(), TenantID: p.TenantID}
	in.apply(&h)
	if err := s.repo.CreateHoliday(ctx, &h, p.UserID); err != nil {
		return h, err
	}
	return s.repo.GetHoliday(ctx, p.TenantID, h.ID)
}

func (s *Service) UpdateHoliday(ctx context.Context, p domain.Principal, id string, in HolidayInput) (domain.Holiday, error) {
	if in.HolidayDate.IsZero() {
		return domain.Holiday{}, domain.InvalidField("holiday_date", "is required")
	}
	h, err := s.repo.GetHoliday(ctx, p.TenantID, id)
	if err != nil {
		return h, err
	}
	in.apply(&h)
	if err := s.repo.UpdateHoliday(ctx, h); err != nil {
		return h, err
	}
	return s.repo.GetHoliday(ctx, p.TenantID, id)
}

func (s *Service) DeleteHoliday(ctx context.Context, p domain.Principal, id string) error {
	return s.repo.DeleteHoliday(ctx, p.TenantID, id)
}

func (s *Service) ListHolidays(ctx context.Context, p domain.Principal, upcomingOnly bool) ([]domain.Holiday, error) {
	if upcomingOnly {
		today := p.Today(s.now())
		return s.repo.ListHolidays(ctx, p.TenantID, &today, nil)
	}
	return s.repo.ListHolidays(ctx, p.TenantID, nil, nil)
}
