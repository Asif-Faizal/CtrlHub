// Package member manages gym members and sales leads. Every method takes the
// authenticated principal and scopes all data access to its tenant.
package member

import (
	"context"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

type Repo interface {
	CreateMember(ctx context.Context, m *domain.Member) error
	UpdateMember(ctx context.Context, m domain.Member) error
	GetMember(ctx context.Context, tenantID, id string, today domain.Date) (domain.Member, error)
	ListMembers(ctx context.Context, tenantID string, f domain.MemberFilter) (domain.Page[domain.Member], error)
	CreateLead(ctx context.Context, l *domain.Lead) error
	UpdateLead(ctx context.Context, l domain.Lead) error
	GetLead(ctx context.Context, tenantID, id string) (domain.Lead, error)
	ListLeads(ctx context.Context, tenantID, status string) ([]domain.Lead, error)
}

type Service struct {
	repo      Repo
	defaultCC string
	now       func() time.Time
}

func NewService(repo Repo, defaultCC string) *Service {
	return &Service{repo: repo, defaultCC: defaultCC, now: time.Now}
}

type Input struct {
	FullName         string          `json:"full_name" validate:"required,max=150"`
	Phone            string          `json:"phone" validate:"required,max=20"`
	Email            string          `json:"email" validate:"omitempty,email,max=190"`
	Gender           string          `json:"gender" validate:"omitempty,oneof=MALE FEMALE OTHER"`
	DateOfBirth      domain.NullDate `json:"date_of_birth"`
	Address          string          `json:"address" validate:"max=255"`
	EmergencyContact string          `json:"emergency_contact" validate:"max=100"`
	Notes            string          `json:"notes" validate:"max=2000"`
	JoinedOn         domain.NullDate `json:"joined_on"`
	Status           string          `json:"status" validate:"omitempty,oneof=ACTIVE INACTIVE"`
	WhatsAppOptIn    bool            `json:"whatsapp_opt_in"`
	MarketingOptIn   bool            `json:"marketing_opt_in"`
}

func (s *Service) apply(p domain.Principal, in Input, m *domain.Member) error {
	phone, err := domain.NormalizePhone(in.Phone, s.defaultCC)
	if err != nil {
		return err
	}
	today := p.Today(s.now())
	if in.DateOfBirth.Valid && in.DateOfBirth.Date.After(today) {
		return domain.InvalidField("date_of_birth", "cannot be in the future")
	}
	m.FullName, m.Phone, m.Email = strings.TrimSpace(in.FullName), phone, strings.ToLower(strings.TrimSpace(in.Email))
	m.Gender, m.DateOfBirth, m.Address = in.Gender, in.DateOfBirth, in.Address
	m.EmergencyContact, m.Notes = in.EmergencyContact, in.Notes
	m.WhatsAppOptIn = in.WhatsAppOptIn
	// Marketing messages additionally require general WhatsApp consent.
	m.MarketingOptIn = in.MarketingOptIn && in.WhatsAppOptIn
	if in.JoinedOn.Valid {
		m.JoinedOn = in.JoinedOn.Date
	} else if m.JoinedOn.IsZero() {
		m.JoinedOn = today
	}
	if in.Status != "" {
		m.Status = in.Status
	} else if m.Status == "" {
		m.Status = "ACTIVE"
	}
	return nil
}

func (s *Service) Create(ctx context.Context, p domain.Principal, in Input) (domain.Member, error) {
	m := domain.Member{ID: uuid.NewString(), TenantID: p.TenantID}
	if err := s.apply(p, in, &m); err != nil {
		return m, err
	}
	if err := s.repo.CreateMember(ctx, &m); err != nil {
		return m, err
	}
	return s.repo.GetMember(ctx, p.TenantID, m.ID, p.Today(s.now()))
}

func (s *Service) Update(ctx context.Context, p domain.Principal, id string, in Input) (domain.Member, error) {
	today := p.Today(s.now())
	m, err := s.repo.GetMember(ctx, p.TenantID, id, today)
	if err != nil {
		return m, err
	}
	if err := s.apply(p, in, &m); err != nil {
		return m, err
	}
	if err := s.repo.UpdateMember(ctx, m); err != nil {
		return m, err
	}
	return s.repo.GetMember(ctx, p.TenantID, id, today)
}

func (s *Service) Get(ctx context.Context, p domain.Principal, id string) (domain.Member, error) {
	return s.repo.GetMember(ctx, p.TenantID, id, p.Today(s.now()))
}

func (s *Service) List(ctx context.Context, p domain.Principal, search, status string, page, size int) (domain.Page[domain.Member], error) {
	switch status {
	case "", "active", "expired", "none":
	default:
		return domain.Page[domain.Member]{}, domain.InvalidField("status", "must be active, expired or none")
	}
	page, size = domain.NormalizePaging(page, size)
	return s.repo.ListMembers(ctx, p.TenantID, domain.MemberFilter{Search: strings.TrimSpace(search), Status: status,
		Today: p.Today(s.now()), Page: page, PageSize: size})
}

type LeadInput struct {
	FullName       string `json:"full_name" validate:"required,max=150"`
	Phone          string `json:"phone" validate:"required,max=20"`
	Email          string `json:"email" validate:"omitempty,email,max=190"`
	Source         string `json:"source" validate:"max=50"`
	Status         string `json:"status" validate:"omitempty,oneof=NEW CONTACTED CONVERTED LOST"`
	WhatsAppOptIn  bool   `json:"whatsapp_opt_in"`
	MarketingOptIn bool   `json:"marketing_opt_in"`
	Notes          string `json:"notes" validate:"max=500"`
}

func (s *Service) applyLead(in LeadInput, l *domain.Lead) error {
	phone, err := domain.NormalizePhone(in.Phone, s.defaultCC)
	if err != nil {
		return err
	}
	l.FullName, l.Phone, l.Email = strings.TrimSpace(in.FullName), phone, strings.ToLower(strings.TrimSpace(in.Email))
	l.Source, l.Notes = in.Source, in.Notes
	l.WhatsAppOptIn, l.MarketingOptIn = in.WhatsAppOptIn, in.MarketingOptIn && in.WhatsAppOptIn
	l.Status = in.Status
	if l.Status == "" {
		l.Status = "NEW"
	}
	return nil
}

func (s *Service) CreateLead(ctx context.Context, p domain.Principal, in LeadInput) (domain.Lead, error) {
	l := domain.Lead{ID: uuid.NewString(), TenantID: p.TenantID}
	if err := s.applyLead(in, &l); err != nil {
		return l, err
	}
	if err := s.repo.CreateLead(ctx, &l); err != nil {
		return l, err
	}
	return s.repo.GetLead(ctx, p.TenantID, l.ID)
}

func (s *Service) UpdateLead(ctx context.Context, p domain.Principal, id string, in LeadInput) (domain.Lead, error) {
	l, err := s.repo.GetLead(ctx, p.TenantID, id)
	if err != nil {
		return l, err
	}
	if err := s.applyLead(in, &l); err != nil {
		return l, err
	}
	if err := s.repo.UpdateLead(ctx, l); err != nil {
		return l, err
	}
	return s.repo.GetLead(ctx, p.TenantID, id)
}

func (s *Service) ListLeads(ctx context.Context, p domain.Principal, status string) ([]domain.Lead, error) {
	return s.repo.ListLeads(ctx, p.TenantID, status)
}
