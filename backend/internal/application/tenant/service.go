// Package tenant implements platform administration and gym onboarding.
package tenant

import (
	"context"
	"encoding/json"
	"strings"

	"github.com/google/uuid"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/audit"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/user"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

type Repo interface {
	WithTx(ctx context.Context, fn func(ctx context.Context) error) error
	CreateTenant(ctx context.Context, t *domain.Tenant) error
	InitTenantDefaults(ctx context.Context, tenantID, sessionName string) error
	GetTenant(ctx context.Context, id string) (domain.Tenant, error)
	ListTenants(ctx context.Context, search, status string, page, size int) (domain.Page[domain.TenantSummary], error)
	UpdateTenant(ctx context.Context, t domain.Tenant) error
	SetTenantStatus(ctx context.Context, id string, status domain.TenantStatus) error
	PlatformStats(ctx context.Context) (domain.PlatformStats, error)
	ListWhatsAppSessions(ctx context.Context) ([]domain.WhatsAppSession, error)
	ListAudit(ctx context.Context, tenantID string, limit int) ([]domain.AuditEntry, error)
}

type Service struct {
	repo  Repo
	users *user.Service
	audit *audit.Logger
}

func NewService(repo Repo, users *user.Service, a *audit.Logger) *Service {
	return &Service{repo: repo, users: users, audit: a}
}

type GymInput struct {
	Name            string          `json:"name" validate:"required,max=150"`
	OwnerName       string          `json:"owner_name" validate:"required,max=150"`
	ContactNumber   string          `json:"contact_number" validate:"required,max=20"`
	Email           string          `json:"email" validate:"required,email,max=190"`
	Address         string          `json:"address" validate:"max=255"`
	City            string          `json:"city" validate:"max=100"`
	State           string          `json:"state" validate:"max=100"`
	Country         string          `json:"country" validate:"max=100"`
	Timezone        string          `json:"timezone" validate:"required"`
	Currency        string          `json:"currency" validate:"omitempty,len=3"`
	OpeningHours    json.RawMessage `json:"opening_hours"`
	Status          string          `json:"status" validate:"omitempty,oneof=ACTIVE INACTIVE"`
	MaxUsers        int             `json:"max_users" validate:"omitempty,min=1,max=500"`
	WhatsAppEnabled *bool           `json:"whatsapp_enabled"`
}

type OnboardInput struct {
	Gym   GymInput         `json:"gym"`
	Admin user.CreateInput `json:"admin"`
}

type OnboardResult struct {
	Tenant   domain.Tenant     `json:"tenant"`
	Admin    domain.TenantUser `json:"admin"`
	SetupURL string            `json:"setup_url,omitempty"`
}

func (in GymInput) apply(t *domain.Tenant) error {
	if !domain.ValidTimezone(in.Timezone) {
		return domain.InvalidField("timezone", "must be a valid IANA timezone such as Asia/Kolkata")
	}
	if len(in.OpeningHours) > 0 && !json.Valid(in.OpeningHours) {
		return domain.InvalidField("opening_hours", "must be valid JSON")
	}
	t.Name, t.OwnerName = strings.TrimSpace(in.Name), strings.TrimSpace(in.OwnerName)
	t.ContactNumber, t.Email = strings.TrimSpace(in.ContactNumber), strings.ToLower(strings.TrimSpace(in.Email))
	t.Address, t.City, t.State, t.Country = in.Address, in.City, in.State, in.Country
	t.Timezone, t.OpeningHours = in.Timezone, in.OpeningHours
	if in.Currency != "" {
		t.Currency = strings.ToUpper(in.Currency)
	}
	if in.MaxUsers > 0 {
		t.MaxUsers = in.MaxUsers
	}
	if in.WhatsAppEnabled != nil {
		t.WhatsAppEnabled = *in.WhatsAppEnabled
	}
	return nil
}

// Onboard creates a gym tenant, its default settings and its primary
// GYM_ADMIN account in one transaction.
func (s *Service) Onboard(ctx context.Context, actor domain.Principal, in OnboardInput) (OnboardResult, error) {
	t := domain.Tenant{ID: uuid.NewString(), Currency: "INR", MaxUsers: 10, WhatsAppEnabled: true, Status: domain.TenantActive}
	if err := in.Gym.apply(&t); err != nil {
		return OnboardResult{}, err
	}
	if in.Gym.Status != "" {
		t.Status = domain.TenantStatus(in.Gym.Status)
	}
	in.Admin.Role = string(domain.RoleGymAdmin)
	var res OnboardResult
	err := s.repo.WithTx(ctx, func(ctx context.Context) error {
		if err := s.repo.CreateTenant(ctx, &t); err != nil {
			return err
		}
		// The tenant code doubles as the WAHA session name (gym_001, ...).
		if err := s.repo.InitTenantDefaults(ctx, t.ID, t.Code); err != nil {
			return err
		}
		created, err := s.users.Create(ctx, actor, t.ID, in.Admin, true)
		if err != nil {
			return err
		}
		res.Admin, res.SetupURL = created.User, created.SetupURL
		return nil
	})
	if err != nil {
		return OnboardResult{}, err
	}
	res.Tenant, err = s.repo.GetTenant(ctx, t.ID)
	if err != nil {
		return OnboardResult{}, err
	}
	s.audit.Record(ctx, actor, t.ID, "tenant.create", "tenant", t.ID, map[string]any{"code": t.Code, "name": t.Name})
	return res, nil
}

func (s *Service) List(ctx context.Context, search, status string, page, size int) (domain.Page[domain.TenantSummary], error) {
	page, size = domain.NormalizePaging(page, size)
	return s.repo.ListTenants(ctx, search, status, page, size)
}

func (s *Service) Get(ctx context.Context, id string) (domain.Tenant, error) {
	return s.repo.GetTenant(ctx, id)
}

// Update changes gym details and tenant configuration (platform admin).
func (s *Service) Update(ctx context.Context, actor domain.Principal, id string, in GymInput) (domain.Tenant, error) {
	t, err := s.repo.GetTenant(ctx, id)
	if err != nil {
		return t, err
	}
	if err := in.apply(&t); err != nil {
		return t, err
	}
	if err := s.repo.UpdateTenant(ctx, t); err != nil {
		return t, err
	}
	if in.Status != "" && domain.TenantStatus(in.Status) != t.Status {
		if err := s.repo.SetTenantStatus(ctx, id, domain.TenantStatus(in.Status)); err != nil {
			return t, err
		}
	}
	s.audit.Record(ctx, actor, id, "tenant.update", "tenant", id, nil)
	return s.repo.GetTenant(ctx, id)
}

type ProfileInput struct {
	Name          string          `json:"name" validate:"required,max=150"`
	OwnerName     string          `json:"owner_name" validate:"required,max=150"`
	ContactNumber string          `json:"contact_number" validate:"required,max=20"`
	Email         string          `json:"email" validate:"required,email,max=190"`
	Address       string          `json:"address" validate:"max=255"`
	City          string          `json:"city" validate:"max=100"`
	State         string          `json:"state" validate:"max=100"`
	Country       string          `json:"country" validate:"max=100"`
	Timezone      string          `json:"timezone" validate:"required"`
	OpeningHours  json.RawMessage `json:"opening_hours"`
}

// UpdateProfile lets a gym admin edit their own gym's details but not
// platform-controlled configuration (status, user limit, WhatsApp access).
func (s *Service) UpdateProfile(ctx context.Context, actor domain.Principal, in ProfileInput) (domain.Tenant, error) {
	t, err := s.repo.GetTenant(ctx, actor.TenantID)
	if err != nil {
		return t, err
	}
	gi := GymInput{Name: in.Name, OwnerName: in.OwnerName, ContactNumber: in.ContactNumber, Email: in.Email,
		Address: in.Address, City: in.City, State: in.State, Country: in.Country, Timezone: in.Timezone,
		OpeningHours: in.OpeningHours}
	if err := gi.apply(&t); err != nil {
		return t, err
	}
	if err := s.repo.UpdateTenant(ctx, t); err != nil {
		return t, err
	}
	s.audit.Record(ctx, actor, t.ID, "tenant.profile_update", "tenant", t.ID, nil)
	return s.repo.GetTenant(ctx, t.ID)
}

func (s *Service) SetStatus(ctx context.Context, actor domain.Principal, id string, status domain.TenantStatus) (domain.Tenant, error) {
	if status != domain.TenantActive && status != domain.TenantInactive {
		return domain.Tenant{}, domain.InvalidField("status", "must be ACTIVE or INACTIVE")
	}
	if err := s.repo.SetTenantStatus(ctx, id, status); err != nil {
		return domain.Tenant{}, err
	}
	s.audit.Record(ctx, actor, id, "tenant.status", "tenant", id, map[string]any{"status": status})
	return s.repo.GetTenant(ctx, id)
}

func (s *Service) Stats(ctx context.Context) (domain.PlatformStats, error) {
	return s.repo.PlatformStats(ctx)
}

func (s *Service) WhatsAppSessions(ctx context.Context) ([]domain.WhatsAppSession, error) {
	return s.repo.ListWhatsAppSessions(ctx)
}

func (s *Service) Audit(ctx context.Context, tenantID string) ([]domain.AuditEntry, error) {
	return s.repo.ListAudit(ctx, tenantID, 100)
}
