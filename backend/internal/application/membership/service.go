// Package membership manages plans, memberships, renewals and payments.
package membership

import (
	"context"
	"slices"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/audit"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

type Repo interface {
	WithTx(ctx context.Context, fn func(ctx context.Context) error) error
	GetMember(ctx context.Context, tenantID, id string, today domain.Date) (domain.Member, error)
	CreatePlan(ctx context.Context, p *domain.MembershipPlan) error
	UpdatePlan(ctx context.Context, p domain.MembershipPlan) error
	GetPlan(ctx context.Context, tenantID, id string) (domain.MembershipPlan, error)
	ListPlans(ctx context.Context, tenantID string, activeOnly bool) ([]domain.MembershipPlan, error)
	CreateMembership(ctx context.Context, m *domain.Membership, createdBy string) error
	GetMembership(ctx context.Context, tenantID, id string, today domain.Date) (domain.Membership, error)
	LockMembership(ctx context.Context, tenantID, id string) error
	LatestMembershipEnd(ctx context.Context, tenantID, memberID string) (domain.NullDate, error)
	ListMemberships(ctx context.Context, tenantID string, f domain.MembershipFilter) (domain.Page[domain.Membership], error)
	CancelMembership(ctx context.Context, tenantID, id string) error
	CreatePayment(ctx context.Context, p *domain.Payment) error
	ListPayments(ctx context.Context, tenantID string, f domain.PaymentFilter) (domain.Page[domain.Payment], error)
}

type Service struct {
	repo  Repo
	audit *audit.Logger
	now   func() time.Time
}

func NewService(repo Repo, a *audit.Logger) *Service {
	return &Service{repo: repo, audit: a, now: time.Now}
}

type PlanInput struct {
	Name         string `json:"name" validate:"required,max=100"`
	Description  string `json:"description" validate:"max=500"`
	DurationType string `json:"duration_type" validate:"required"`
	DurationDays *int   `json:"duration_days"`
	PriceMinor   int64  `json:"price_minor" validate:"min=0"`
	IsActive     *bool  `json:"is_active"`
}

func (in PlanInput) apply(p *domain.MembershipPlan) error {
	dt := domain.DurationType(in.DurationType)
	if err := domain.ValidateDuration(dt, in.DurationDays); err != nil {
		return err
	}
	p.Name, p.Description, p.DurationType, p.PriceMinor = strings.TrimSpace(in.Name), in.Description, dt, in.PriceMinor
	p.DurationDays = nil
	if dt == domain.DurationCustom {
		p.DurationDays = in.DurationDays
	}
	if in.IsActive != nil {
		p.IsActive = *in.IsActive
	}
	return nil
}

func (s *Service) CreatePlan(ctx context.Context, pr domain.Principal, in PlanInput) (domain.MembershipPlan, error) {
	p := domain.MembershipPlan{ID: uuid.NewString(), TenantID: pr.TenantID, IsActive: true}
	if err := in.apply(&p); err != nil {
		return p, err
	}
	if err := s.repo.CreatePlan(ctx, &p); err != nil {
		return p, err
	}
	return s.repo.GetPlan(ctx, pr.TenantID, p.ID)
}

func (s *Service) UpdatePlan(ctx context.Context, pr domain.Principal, id string, in PlanInput) (domain.MembershipPlan, error) {
	p, err := s.repo.GetPlan(ctx, pr.TenantID, id)
	if err != nil {
		return p, err
	}
	if err := in.apply(&p); err != nil {
		return p, err
	}
	if err := s.repo.UpdatePlan(ctx, p); err != nil {
		return p, err
	}
	return s.repo.GetPlan(ctx, pr.TenantID, id)
}

func (s *Service) ListPlans(ctx context.Context, pr domain.Principal, activeOnly bool) ([]domain.MembershipPlan, error) {
	return s.repo.ListPlans(ctx, pr.TenantID, activeOnly)
}

type AssignInput struct {
	MemberID            string          `json:"member_id" validate:"required,uuid"`
	PlanID              string          `json:"plan_id" validate:"required,uuid"`
	StartDate           domain.NullDate `json:"start_date"`
	TotalAmountMinor    *int64          `json:"total_amount_minor" validate:"omitempty,min=0"`
	Notes               string          `json:"notes" validate:"max=500"`
	InitialPaymentMinor int64           `json:"initial_payment_minor" validate:"min=0"`
	PaymentMethod       string          `json:"payment_method"`
}

type RenewInput struct {
	PlanID              string `json:"plan_id" validate:"omitempty,uuid"`
	TotalAmountMinor    *int64 `json:"total_amount_minor" validate:"omitempty,min=0"`
	Notes               string `json:"notes" validate:"max=500"`
	InitialPaymentMinor int64  `json:"initial_payment_minor" validate:"min=0"`
	PaymentMethod       string `json:"payment_method"`
}

// Assign creates a new membership for a member. Existing memberships are never
// modified; when no start date is given the new period follows the latest one.
func (s *Service) Assign(ctx context.Context, pr domain.Principal, in AssignInput) (domain.Membership, error) {
	return s.create(ctx, pr, in.MemberID, in.PlanID, in.StartDate, in.TotalAmountMinor, in.Notes, nil,
		in.InitialPaymentMinor, in.PaymentMethod)
}

// Renew appends a new membership after the given one, keeping history intact.
func (s *Service) Renew(ctx context.Context, pr domain.Principal, membershipID string, in RenewInput) (domain.Membership, error) {
	prev, err := s.repo.GetMembership(ctx, pr.TenantID, membershipID, pr.Today(s.now()))
	if err != nil {
		return prev, err
	}
	if prev.State == domain.MembershipCancelled {
		return prev, domain.Invalid("cannot renew a cancelled membership")
	}
	planID := in.PlanID
	if planID == "" {
		planID = prev.PlanID
	}
	m, err := s.create(ctx, pr, prev.MemberID, planID, domain.NullDate{}, in.TotalAmountMinor, in.Notes, &prev.ID,
		in.InitialPaymentMinor, in.PaymentMethod)
	if err == nil {
		s.audit.Record(ctx, pr, pr.TenantID, "membership.renew", "membership", m.ID, map[string]any{"renewed_from": prev.ID})
	}
	return m, err
}

func (s *Service) create(ctx context.Context, pr domain.Principal, memberID, planID string, start domain.NullDate,
	total *int64, notes string, renewedFrom *string, initialPayment int64, method string) (domain.Membership, error) {
	today := pr.Today(s.now())
	if initialPayment > 0 && !slices.Contains(domain.PaymentMethods, method) {
		return domain.Membership{}, domain.InvalidField("payment_method", "must be one of CASH, UPI, CARD, BANK_TRANSFER, OTHER")
	}
	var id string
	err := s.repo.WithTx(ctx, func(ctx context.Context) error {
		if _, err := s.repo.GetMember(ctx, pr.TenantID, memberID, today); err != nil {
			return notFoundAs(err, "member_id", "member not found")
		}
		plan, err := s.repo.GetPlan(ctx, pr.TenantID, planID)
		if err != nil {
			return notFoundAs(err, "plan_id", "plan not found")
		}
		if !plan.IsActive {
			return domain.InvalidField("plan_id", "plan is inactive")
		}
		startDate := start.Date
		if !start.Valid {
			latest, err := s.repo.LatestMembershipEnd(ctx, pr.TenantID, memberID)
			if err != nil {
				return err
			}
			startDate = today
			if latest.Valid {
				startDate = domain.RenewalStart(latest.Date, today)
			}
		}
		amount := plan.PriceMinor
		if total != nil {
			amount = *total
		}
		if initialPayment > amount {
			return domain.InvalidField("initial_payment_minor", "cannot exceed the membership amount")
		}
		m := domain.Membership{ID: uuid.NewString(), TenantID: pr.TenantID, MemberID: memberID, PlanID: plan.ID,
			PlanName: plan.Name, StartDate: startDate, EndDate: plan.EndDate(startDate), TotalAmountMinor: amount,
			RenewedFromID: renewedFrom, Notes: notes}
		if err := s.repo.CreateMembership(ctx, &m, pr.UserID); err != nil {
			return err
		}
		if initialPayment > 0 {
			pay := domain.Payment{ID: uuid.NewString(), TenantID: pr.TenantID, MemberID: memberID, MembershipID: &m.ID,
				AmountMinor: initialPayment, Method: method, PaidAt: s.now().UTC(), RecordedBy: &pr.UserID}
			if err := s.repo.CreatePayment(ctx, &pay); err != nil {
				return err
			}
		}
		id = m.ID
		return nil
	})
	if err != nil {
		return domain.Membership{}, err
	}
	return s.repo.GetMembership(ctx, pr.TenantID, id, today)
}

func notFoundAs(err error, field, msg string) error {
	if err == domain.ErrNotFound {
		return domain.InvalidField(field, msg)
	}
	return err
}

func (s *Service) Get(ctx context.Context, pr domain.Principal, id string) (domain.Membership, error) {
	return s.repo.GetMembership(ctx, pr.TenantID, id, pr.Today(s.now()))
}

func (s *Service) List(ctx context.Context, pr domain.Principal, memberID, view string, days, page, size int) (domain.Page[domain.Membership], error) {
	switch view {
	case "", "all", "active", "expiring", "expired":
	default:
		return domain.Page[domain.Membership]{}, domain.InvalidField("view", "must be all, active, expiring or expired")
	}
	if days <= 0 || days > 365 {
		days = 7
		if view == "expired" {
			days = 30
		}
	}
	page, size = domain.NormalizePaging(page, size)
	return s.repo.ListMemberships(ctx, pr.TenantID, domain.MembershipFilter{MemberID: memberID, View: view, Days: days,
		Today: pr.Today(s.now()), Page: page, PageSize: size})
}

func (s *Service) Cancel(ctx context.Context, pr domain.Principal, id string) (domain.Membership, error) {
	if err := s.repo.CancelMembership(ctx, pr.TenantID, id); err != nil {
		return domain.Membership{}, err
	}
	s.audit.Record(ctx, pr, pr.TenantID, "membership.cancel", "membership", id, nil)
	return s.Get(ctx, pr, id)
}

type PaymentInput struct {
	MemberID     string     `json:"member_id" validate:"required,uuid"`
	MembershipID string     `json:"membership_id" validate:"omitempty,uuid"`
	AmountMinor  int64      `json:"amount_minor" validate:"required,min=1"`
	Method       string     `json:"method" validate:"required,oneof=CASH UPI CARD BANK_TRANSFER OTHER"`
	Reference    string     `json:"reference" validate:"max=100"`
	Notes        string     `json:"notes" validate:"max=500"`
	PaidAt       *time.Time `json:"paid_at"`
}

// RecordPayment stores a payment. Payments against a membership may not
// exceed its pending amount.
func (s *Service) RecordPayment(ctx context.Context, pr domain.Principal, in PaymentInput) (domain.Payment, error) {
	today := pr.Today(s.now())
	p := domain.Payment{ID: uuid.NewString(), TenantID: pr.TenantID, MemberID: in.MemberID, AmountMinor: in.AmountMinor,
		Method: in.Method, Reference: in.Reference, Notes: in.Notes, PaidAt: s.now().UTC(), RecordedBy: &pr.UserID}
	if in.PaidAt != nil {
		if in.PaidAt.After(s.now().Add(5 * time.Minute)) {
			return p, domain.InvalidField("paid_at", "cannot be in the future")
		}
		p.PaidAt = in.PaidAt.UTC()
	}
	err := s.repo.WithTx(ctx, func(ctx context.Context) error {
		if _, err := s.repo.GetMember(ctx, pr.TenantID, in.MemberID, today); err != nil {
			return notFoundAs(err, "member_id", "member not found")
		}
		if in.MembershipID != "" {
			if err := s.repo.LockMembership(ctx, pr.TenantID, in.MembershipID); err != nil {
				return notFoundAs(err, "membership_id", "membership not found")
			}
			ms, err := s.repo.GetMembership(ctx, pr.TenantID, in.MembershipID, today)
			if err != nil {
				return err
			}
			if ms.MemberID != in.MemberID {
				return domain.InvalidField("membership_id", "membership belongs to a different member")
			}
			if in.AmountMinor > ms.PendingMinor {
				return domain.InvalidField("amount_minor", "exceeds the pending amount for this membership")
			}
			p.MembershipID = &in.MembershipID
		}
		return s.repo.CreatePayment(ctx, &p)
	})
	return p, err
}

func (s *Service) ListPayments(ctx context.Context, pr domain.Principal, memberID string, from, to *domain.Date, page, size int) (domain.Page[domain.Payment], error) {
	page, size = domain.NormalizePaging(page, size)
	f := domain.PaymentFilter{MemberID: memberID, Page: page, PageSize: size}
	if from != nil {
		start, _ := domain.DayBounds(*from, pr.TenantTimezone)
		f.From = &start
	}
	if to != nil {
		_, end := domain.DayBounds(*to, pr.TenantTimezone)
		f.To = &end
	}
	return s.repo.ListPayments(ctx, pr.TenantID, f)
}
