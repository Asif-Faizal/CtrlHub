// Package app assembles the application from its parts (composition root).
package app

import (
	"context"
	"database/sql"
	"log/slog"
	"net/http"
	"time"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/attendance"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/audit"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/auth"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/automation"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/campaign"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/member"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/membership"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/messaging"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/report"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/tenant"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/user"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/config"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/infrastructure/database"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/infrastructure/mockwhatsapp"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/infrastructure/waha"
	apihttp "github.com/Asif-Faizal/CtrlHub/backend/internal/interfaces/http"
)

type App struct {
	Handler    http.Handler
	Auth       *auth.Service
	Automation *automation.Service
}

// NewProvider selects the WhatsApp transport from configuration.
func NewProvider(cfg config.Config, log *slog.Logger) messaging.Provider {
	if cfg.MessagingProvider == "waha" {
		log.Info("messaging provider: WAHA", "base_url", cfg.WAHABaseURL)
		return waha.New(cfg.WAHABaseURL, cfg.WAHAAPIKey)
	}
	log.Warn("messaging provider: MOCK - no WhatsApp messages will be delivered")
	return mockwhatsapp.New(5 * time.Second)
}

func New(cfg config.Config, db *sql.DB, provider messaging.Provider, log *slog.Logger) *App {
	store := database.NewStore(db)
	auditLog := audit.New(store, log)

	authSvc := auth.NewService(store, auth.NewTokenIssuer(cfg.JWTSecret, cfg.AccessTokenTTL),
		cfg.RefreshTokenTTL, cfg.SetupTokenTTL, cfg.AppBaseURL, log)
	userSvc := user.NewService(store, authSvc, auditLog)
	tenantSvc := tenant.NewService(store, userSvc, auditLog)
	reportSvc := report.NewService(store)
	msgSvc := messaging.NewService(store, provider, auditLog, cfg.DefaultCountryCode, log)
	autoSvc := automation.NewService(store, msgSvc, reportSvc, auditLog, cfg.DefaultCountryCode, log)

	handler := apihttp.NewRouter(apihttp.Deps{
		Log:              log,
		DB:               store,
		Auth:             authSvc,
		Tenants:          tenantSvc,
		Users:            userSvc,
		Members:          member.NewService(store, cfg.DefaultCountryCode),
		Memberships:      membership.NewService(store, auditLog),
		Attendance:       attendance.NewService(store),
		Reports:          reportSvc,
		Messaging:        msgSvc,
		Automation:       autoSvc,
		Campaigns:        campaign.NewService(store, autoSvc, auditLog),
		AutomationAPIKey: cfg.AutomationAPIKey,
		AllowedOrigins:   cfg.AllowedOrigins,
		LoginRatePerMin:  cfg.LoginRatePerMinute,
	})
	return &App{Handler: handler, Auth: authSvc, Automation: autoSvc}
}

func (a *App) Seed(ctx context.Context, cfg config.Config) error {
	return a.Auth.EnsurePlatformAdmin(ctx, cfg.PlatformAdminEmail, cfg.PlatformAdminPassword, cfg.PlatformAdminName)
}
