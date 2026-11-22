package auth

import (
	"context"
	"errors"
	"log/slog"
	"net/url"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

type Repo interface {
	WithTx(ctx context.Context, fn func(ctx context.Context) error) error
	GetUserByEmail(ctx context.Context, email string) (domain.User, error)
	GetUserByID(ctx context.Context, id string) (domain.User, error)
	CreateUser(ctx context.Context, u *domain.User) error
	PlatformAdminExists(ctx context.Context) (bool, error)
	LoadPrincipal(ctx context.Context, userID string) (domain.PrincipalRecord, error)
	TouchLastLogin(ctx context.Context, userID string) error
	SetPassword(ctx context.Context, userID, hash string) error
	InsertRefreshToken(ctx context.Context, id, userID, hash string, expires time.Time, ua, ip string) error
	GetRefreshToken(ctx context.Context, hash string) (domain.RefreshToken, error)
	RevokeRefreshToken(ctx context.Context, id string, replacedBy *string) (bool, error)
	RevokeAllRefreshTokens(ctx context.Context, userID string) error
	InsertSetupToken(ctx context.Context, userID, hash, purpose string, expires time.Time, createdBy *string) error
	GetSetupToken(ctx context.Context, hash string) (domain.SetupToken, error)
	MarkSetupTokenUsed(ctx context.Context, id string) (bool, error)
}

type Service struct {
	repo       Repo
	tokens     *TokenIssuer
	refreshTTL time.Duration
	setupTTL   time.Duration
	appBaseURL string
	log        *slog.Logger
	now        func() time.Time
}

func NewService(repo Repo, tokens *TokenIssuer, refreshTTL, setupTTL time.Duration, appBaseURL string, log *slog.Logger) *Service {
	return &Service{repo: repo, tokens: tokens, refreshTTL: refreshTTL, setupTTL: setupTTL,
		appBaseURL: appBaseURL, log: log, now: time.Now}
}

// UserInfo is the identity returned to clients; frontends route on Dashboard
// and gate navigation on Permissions.
type UserInfo struct {
	ID          string              `json:"id"`
	Name        string              `json:"name"`
	Email       string              `json:"email"`
	Role        domain.Role         `json:"role"`
	Dashboard   string              `json:"dashboard"`
	TenantID    string              `json:"tenant_id,omitempty"`
	TenantCode  string              `json:"tenant_code,omitempty"`
	TenantName  string              `json:"tenant_name,omitempty"`
	Permissions []domain.Permission `json:"permissions"`
}

type Session struct {
	AccessToken  string   `json:"access_token"`
	RefreshToken string   `json:"refresh_token"`
	TokenType    string   `json:"token_type"`
	ExpiresIn    int      `json:"expires_in"`
	User         UserInfo `json:"user"`
}

func Info(p domain.Principal) UserInfo {
	dash := "gym"
	if p.IsPlatformAdmin {
		dash = "platform"
	}
	return UserInfo{ID: p.UserID, Name: p.Name, Email: p.Email, Role: p.Role, Dashboard: dash,
		TenantID: p.TenantID, TenantCode: p.TenantCode, TenantName: p.TenantName, Permissions: p.Role.Permissions()}
}

func NormalizeEmail(e string) string { return strings.ToLower(strings.TrimSpace(e)) }

// Authenticate resolves an access token into a principal using current
// database state, so deactivation and role changes apply immediately.
func (s *Service) Authenticate(ctx context.Context, accessToken string) (domain.Principal, error) {
	userID, err := s.tokens.Parse(accessToken)
	if err != nil {
		return domain.Principal{}, err
	}
	return s.activePrincipal(ctx, userID)
}

func (s *Service) activePrincipal(ctx context.Context, userID string) (domain.Principal, error) {
	rec, err := s.repo.LoadPrincipal(ctx, userID)
	if errors.Is(err, domain.ErrNotFound) {
		return domain.Principal{}, domain.ErrUnauthorized
	}
	if err != nil {
		return domain.Principal{}, err
	}
	if rec.UserStatus != domain.UserActive {
		return domain.Principal{}, domain.ErrInactive
	}
	if !rec.IsPlatformAdmin {
		if rec.TenantID == "" || !rec.Role.IsGymRole() {
			return domain.Principal{}, domain.ErrUnauthorized
		}
		if rec.TenantStatus != domain.TenantActive {
			return domain.Principal{}, domain.ErrInactive
		}
	}
	return rec.Principal, nil
}

func (s *Service) Login(ctx context.Context, email, password, ua, ip string) (Session, error) {
	u, err := s.repo.GetUserByEmail(ctx, NormalizeEmail(email))
	if err != nil && !errors.Is(err, domain.ErrNotFound) {
		return Session{}, err
	}
	if !checkPassword(u.PasswordHash, password) {
		return Session{}, errInvalidCredentials
	}
	p, err := s.activePrincipal(ctx, u.ID)
	if err != nil {
		return Session{}, err
	}
	sess, err := s.issue(ctx, p, ua, ip)
	if err != nil {
		return Session{}, err
	}
	if err := s.repo.TouchLastLogin(ctx, u.ID); err != nil {
		s.log.Warn("touch last login", "error", err)
	}
	return sess, nil
}

func (s *Service) issue(ctx context.Context, p domain.Principal, ua, ip string) (Session, error) {
	now := s.now()
	access, err := s.tokens.Issue(p, now)
	if err != nil {
		return Session{}, err
	}
	plain, hash, err := RandomToken()
	if err != nil {
		return Session{}, err
	}
	if err := s.repo.InsertRefreshToken(ctx, uuid.NewString(), p.UserID, hash, now.Add(s.refreshTTL).UTC(), ua, ip); err != nil {
		return Session{}, err
	}
	return Session{AccessToken: access, RefreshToken: plain, TokenType: "Bearer",
		ExpiresIn: int(s.tokens.ttl.Seconds()), User: Info(p)}, nil
}

// Refresh rotates a refresh token. Presenting an already-revoked token is
// treated as theft and revokes every session of that user.
func (s *Service) Refresh(ctx context.Context, refreshToken, ua, ip string) (Session, error) {
	rt, err := s.repo.GetRefreshToken(ctx, HashToken(refreshToken))
	if errors.Is(err, domain.ErrNotFound) {
		return Session{}, domain.ErrUnauthorized
	}
	if err != nil {
		return Session{}, err
	}
	if rt.RevokedAt != nil {
		s.log.Warn("refresh token reuse detected", "user_id", rt.UserID)
		_ = s.repo.RevokeAllRefreshTokens(ctx, rt.UserID)
		return Session{}, domain.ErrUnauthorized
	}
	if s.now().After(rt.ExpiresAt) {
		return Session{}, domain.ErrUnauthorized
	}
	p, err := s.activePrincipal(ctx, rt.UserID)
	if err != nil {
		return Session{}, err
	}
	var out Session
	err = s.repo.WithTx(ctx, func(ctx context.Context) error {
		newID := uuid.NewString()
		ok, err := s.repo.RevokeRefreshToken(ctx, rt.ID, &newID)
		if err != nil {
			return err
		}
		if !ok {
			return domain.ErrUnauthorized
		}
		access, err := s.tokens.Issue(p, s.now())
		if err != nil {
			return err
		}
		plain, hash, err := RandomToken()
		if err != nil {
			return err
		}
		if err := s.repo.InsertRefreshToken(ctx, newID, p.UserID, hash, s.now().Add(s.refreshTTL).UTC(), ua, ip); err != nil {
			return err
		}
		out = Session{AccessToken: access, RefreshToken: plain, TokenType: "Bearer",
			ExpiresIn: int(s.tokens.ttl.Seconds()), User: Info(p)}
		return nil
	})
	return out, err
}

func (s *Service) Logout(ctx context.Context, refreshToken string) error {
	rt, err := s.repo.GetRefreshToken(ctx, HashToken(refreshToken))
	if errors.Is(err, domain.ErrNotFound) {
		return nil
	}
	if err != nil {
		return err
	}
	_, err = s.repo.RevokeRefreshToken(ctx, rt.ID, nil)
	return err
}

// IssueSetupLink creates a one-time password setup/reset link for a user.
func (s *Service) IssueSetupLink(ctx context.Context, userID, purpose string, createdBy *string) (string, error) {
	plain, hash, err := RandomToken()
	if err != nil {
		return "", err
	}
	if err := s.repo.InsertSetupToken(ctx, userID, hash, purpose, s.now().Add(s.setupTTL).UTC(), createdBy); err != nil {
		return "", err
	}
	return s.appBaseURL + "/setup-password?token=" + url.QueryEscape(plain), nil
}

// SetupPassword consumes a setup link token and sets the user's password.
func (s *Service) SetupPassword(ctx context.Context, token, password string) error {
	hash, err := HashPassword(password)
	if err != nil {
		return err
	}
	return s.repo.WithTx(ctx, func(ctx context.Context) error {
		st, err := s.repo.GetSetupToken(ctx, HashToken(token))
		if errors.Is(err, domain.ErrNotFound) {
			return domain.Invalid("this link is invalid or has already been used")
		}
		if err != nil {
			return err
		}
		if st.UsedAt != nil || s.now().After(st.ExpiresAt) {
			return domain.Invalid("this link is invalid or has expired")
		}
		ok, err := s.repo.MarkSetupTokenUsed(ctx, st.ID)
		if err != nil {
			return err
		}
		if !ok {
			return domain.Invalid("this link has already been used")
		}
		if err := s.repo.SetPassword(ctx, st.UserID, hash); err != nil {
			return err
		}
		return s.repo.RevokeAllRefreshTokens(ctx, st.UserID)
	})
}

// ChangePassword lets a signed-in user change their own password.
func (s *Service) ChangePassword(ctx context.Context, userID, current, next string) error {
	u, err := s.repo.GetUserByID(ctx, userID)
	if err != nil {
		return err
	}
	if !checkPassword(u.PasswordHash, current) {
		return domain.InvalidField("current_password", "is incorrect")
	}
	hash, err := HashPassword(next)
	if err != nil {
		return err
	}
	return s.repo.SetPassword(ctx, userID, hash)
}

// EnsurePlatformAdmin seeds the first platform administrator when none exists.
func (s *Service) EnsurePlatformAdmin(ctx context.Context, email, password, name string) error {
	exists, err := s.repo.PlatformAdminExists(ctx)
	if err != nil || exists {
		return err
	}
	if email == "" || password == "" {
		s.log.Warn("no platform admin exists; set PLATFORM_ADMIN_EMAIL and PLATFORM_ADMIN_PASSWORD to create one")
		return nil
	}
	hash, err := HashPassword(password)
	if err != nil {
		return err
	}
	u := domain.User{ID: uuid.NewString(), Name: name, Email: NormalizeEmail(email), PasswordHash: hash,
		IsPlatformAdmin: true, Status: domain.UserActive}
	if err := s.repo.CreateUser(ctx, &u); err != nil {
		return err
	}
	s.log.Info("seeded platform admin", "email", u.Email)
	return nil
}

func IsInvalidCredentials(err error) bool { return errors.Is(err, errInvalidCredentials) }
