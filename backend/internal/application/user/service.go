// Package user manages login accounts that belong to a gym tenant.
package user

import (
	"context"
	"errors"
	"strings"

	"github.com/google/uuid"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/audit"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/auth"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

type Repo interface {
	WithTx(ctx context.Context, fn func(ctx context.Context) error) error
	GetTenant(ctx context.Context, id string) (domain.Tenant, error)
	CreateUser(ctx context.Context, u *domain.User) error
	AddTenantUser(ctx context.Context, tenantID, userID string, role domain.Role, primary bool) error
	ListTenantUsers(ctx context.Context, tenantID string) ([]domain.TenantUser, error)
	GetTenantUser(ctx context.Context, tenantID, userID string) (domain.TenantUser, error)
	GetTenantUserByUserID(ctx context.Context, userID string) (domain.TenantUser, error)
	CountTenantUsers(ctx context.Context, tenantID string) (int, error)
	UpdateTenantUser(ctx context.Context, tenantID string, u domain.TenantUser) error
	RevokeAllRefreshTokens(ctx context.Context, userID string) error
}

type SetupLinks interface {
	IssueSetupLink(ctx context.Context, userID, purpose string, createdBy *string) (string, error)
}

type Service struct {
	repo  Repo
	links SetupLinks
	audit *audit.Logger
}

func NewService(repo Repo, links SetupLinks, a *audit.Logger) *Service {
	return &Service{repo: repo, links: links, audit: a}
}

type CreateInput struct {
	Name     string `json:"name" validate:"required,max=150"`
	Email    string `json:"email" validate:"required,email,max=190"`
	Phone    string `json:"phone" validate:"max=20"`
	Role     string `json:"role"`
	Password string `json:"password" validate:"omitempty,min=8,max=72"`
}

type UpdateInput struct {
	Name   string `json:"name" validate:"required,max=150"`
	Phone  string `json:"phone" validate:"max=20"`
	Role   string `json:"role" validate:"required"`
	Status string `json:"status" validate:"required,oneof=ACTIVE INACTIVE"`
}

type CreatedUser struct {
	User     domain.TenantUser `json:"user"`
	SetupURL string            `json:"setup_url,omitempty"`
}

// Create adds a login account to tenantID. With no password, the user gets a
// one-time setup link instead.
func (s *Service) Create(ctx context.Context, actor domain.Principal, tenantID string, in CreateInput, primary bool) (CreatedUser, error) {
	role, ok := domain.ParseGymRole(in.Role)
	if !ok {
		return CreatedUser{}, domain.InvalidField("role", "must be GYM_ADMIN, GYM_MANAGER, RECEPTIONIST or TRAINER")
	}
	t, err := s.repo.GetTenant(ctx, tenantID)
	if err != nil {
		return CreatedUser{}, err
	}
	var out CreatedUser
	err = s.repo.WithTx(ctx, func(ctx context.Context) error {
		n, err := s.repo.CountTenantUsers(ctx, tenantID)
		if err != nil {
			return err
		}
		if n >= t.MaxUsers {
			return domain.Forbidden("this gym has reached its user limit")
		}
		u := domain.User{ID: uuid.NewString(), Name: strings.TrimSpace(in.Name), Email: auth.NormalizeEmail(in.Email),
			Phone: strings.TrimSpace(in.Phone), Status: domain.UserPendingSetup}
		if in.Password != "" {
			if u.PasswordHash, err = auth.HashPassword(in.Password); err != nil {
				return err
			}
			u.Status = domain.UserActive
		}
		if err := s.repo.CreateUser(ctx, &u); err != nil {
			return err
		}
		if err := s.repo.AddTenantUser(ctx, tenantID, u.ID, role, primary); err != nil {
			return err
		}
		if in.Password == "" {
			if out.SetupURL, err = s.links.IssueSetupLink(ctx, u.ID, "SETUP", &actor.UserID); err != nil {
				return err
			}
		}
		out.User = domain.TenantUser{User: u, TenantID: tenantID, Role: role, IsPrimary: primary}
		return nil
	})
	if err != nil {
		return CreatedUser{}, err
	}
	s.audit.Record(ctx, actor, tenantID, "user.create", "user", out.User.ID, map[string]any{"role": role, "email": out.User.Email})
	return out, nil
}

func (s *Service) List(ctx context.Context, tenantID string) ([]domain.TenantUser, error) {
	return s.repo.ListTenantUsers(ctx, tenantID)
}

func (s *Service) Update(ctx context.Context, actor domain.Principal, tenantID, userID string, in UpdateInput) (domain.TenantUser, error) {
	role, ok := domain.ParseGymRole(in.Role)
	if !ok {
		return domain.TenantUser{}, domain.InvalidField("role", "must be GYM_ADMIN, GYM_MANAGER, RECEPTIONIST or TRAINER")
	}
	cur, err := s.repo.GetTenantUser(ctx, tenantID, userID)
	if err != nil {
		return domain.TenantUser{}, err
	}
	status := domain.UserStatus(in.Status)
	if cur.Status == domain.UserPendingSetup && status == domain.UserActive {
		status = domain.UserPendingSetup
	}
	if !actor.IsPlatformAdmin {
		if cur.IsPrimary && (role != cur.Role || status == domain.UserInactive) {
			return domain.TenantUser{}, domain.Forbidden("only the platform administrator can change the primary gym administrator")
		}
		if actor.UserID == userID && (role != cur.Role || status == domain.UserInactive) {
			return domain.TenantUser{}, domain.Forbidden("you cannot change your own role or deactivate yourself")
		}
	}
	cur.Name, cur.Phone, cur.Role, cur.Status = strings.TrimSpace(in.Name), strings.TrimSpace(in.Phone), role, status
	if err := s.repo.UpdateTenantUser(ctx, tenantID, cur); err != nil {
		return domain.TenantUser{}, err
	}
	if status == domain.UserInactive {
		if err := s.repo.RevokeAllRefreshTokens(ctx, userID); err != nil {
			return domain.TenantUser{}, err
		}
	}
	s.audit.Record(ctx, actor, tenantID, "user.update", "user", userID, map[string]any{"role": role, "status": status})
	return s.repo.GetTenantUser(ctx, tenantID, userID)
}

// ResetPassword issues a new one-time password link for a tenant user.
func (s *Service) ResetPassword(ctx context.Context, actor domain.Principal, tenantID, userID string) (string, error) {
	if _, err := s.repo.GetTenantUser(ctx, tenantID, userID); err != nil {
		return "", err
	}
	link, err := s.links.IssueSetupLink(ctx, userID, "RESET", &actor.UserID)
	if err != nil {
		return "", err
	}
	s.audit.Record(ctx, actor, tenantID, "user.reset_password", "user", userID, nil)
	return link, nil
}

// ResetPasswordAnyTenant is the platform-admin variant that resolves the tenant itself.
func (s *Service) ResetPasswordAnyTenant(ctx context.Context, actor domain.Principal, userID string) (string, error) {
	tu, err := s.repo.GetTenantUserByUserID(ctx, userID)
	if errors.Is(err, domain.ErrNotFound) {
		return "", domain.ErrNotFound
	}
	if err != nil {
		return "", err
	}
	return s.ResetPassword(ctx, actor, tu.TenantID, userID)
}
