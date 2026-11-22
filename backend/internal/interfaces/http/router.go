// Package http wires REST routes to the application services.
package http

import (
	"context"
	_ "embed"
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	chimw "github.com/go-chi/chi/v5/middleware"

	"github.com/Asif-Faizal/CtrlHub/backend/api"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/attendance"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/auth"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/automation"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/campaign"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/member"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/membership"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/messaging"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/report"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/tenant"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/user"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
	mw "github.com/Asif-Faizal/CtrlHub/backend/internal/interfaces/middleware"
)

type Pinger interface {
	Ping(ctx context.Context) error
}

type Deps struct {
	Log              *slog.Logger
	DB               Pinger
	Auth             *auth.Service
	Tenants          *tenant.Service
	Users            *user.Service
	Members          *member.Service
	Memberships      *membership.Service
	Attendance       *attendance.Service
	Reports          *report.Service
	Messaging        *messaging.Service
	Automation       *automation.Service
	Campaigns        *campaign.Service
	AutomationAPIKey string
	AllowedOrigins   []string
	LoginRatePerMin  int
}

type handler func(w http.ResponseWriter, r *http.Request) error

type server struct {
	Deps
	errs errorWriter
}

func (s *server) h(fn handler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if err := fn(w, r); err != nil {
			s.errs.write(w, r, err)
		}
	}
}

func NewRouter(d Deps) http.Handler {
	s := &server{Deps: d, errs: errorWriter{log: d.Log}}
	we := s.errs.write
	perm := func(p domain.Permission) func(http.Handler) http.Handler { return mw.RequirePermission(p, we) }

	r := chi.NewRouter()
	r.Use(chimw.RequestID, chimw.RealIP, mw.RequestLogger(d.Log), chimw.Recoverer, mw.SecurityHeaders,
		mw.CORS(d.AllowedOrigins), mw.AuditIP, chimw.Timeout(60*time.Second))

	r.Get("/healthz", func(w http.ResponseWriter, _ *http.Request) { writeJSON(w, 200, map[string]string{"status": "ok"}) })
	r.Get("/readyz", func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
		defer cancel()
		if err := d.DB.Ping(ctx); err != nil {
			writeJSON(w, 503, map[string]string{"status": "unavailable"})
			return
		}
		writeJSON(w, 200, map[string]string{"status": "ready"})
	})

	r.Route("/api/v1", func(r chi.Router) {
		r.Get("/openapi.yaml", func(w http.ResponseWriter, _ *http.Request) {
			w.Header().Set("Content-Type", "application/yaml")
			_, _ = w.Write(api.OpenAPI)
		})

		limiter := mw.NewRateLimiter(d.LoginRatePerMin)
		r.Route("/auth", func(r chi.Router) {
			r.With(limiter.Middleware).Post("/login", s.h(s.login))
			r.With(limiter.Middleware).Post("/refresh", s.h(s.refresh))
			r.With(limiter.Middleware).Post("/setup-password", s.h(s.setupPassword))
			r.Post("/logout", s.h(s.logout))
			r.Group(func(r chi.Router) {
				r.Use(mw.Authenticate(d.Auth, we))
				r.Get("/me", s.h(s.me))
				r.With(limiter.Middleware).Post("/change-password", s.h(s.changePassword))
			})
		})

		r.Route("/platform", func(r chi.Router) {
			r.Use(mw.Authenticate(d.Auth, we), mw.RequirePlatformAdmin(we))
			r.Get("/stats", s.h(s.platformStats))
			r.Get("/whatsapp-sessions", s.h(s.platformWhatsApp))
			r.Get("/tenants", s.h(s.listTenants))
			r.Post("/tenants", s.h(s.onboardTenant))
			r.Get("/tenants/{id}", s.h(s.getTenant))
			r.Patch("/tenants/{id}", s.h(s.updateTenant))
			r.Patch("/tenants/{id}/status", s.h(s.setTenantStatus))
			r.Get("/tenants/{id}/users", s.h(s.platformListUsers))
			r.Post("/tenants/{id}/users", s.h(s.platformCreateUser))
			r.Patch("/tenants/{id}/users/{userID}", s.h(s.platformUpdateUser))
			r.Get("/tenants/{id}/whatsapp", s.h(s.platformTenantWhatsApp))
			r.Get("/tenants/{id}/audit", s.h(s.platformAudit))
			r.Post("/users/{userID}/reset-password", s.h(s.platformResetPassword))
		})

		r.Route("/gym", func(r chi.Router) {
			r.Use(mw.Authenticate(d.Auth, we), mw.RequireTenant(we))

			r.With(perm(domain.PermTenantRead)).Get("/profile", s.h(s.gymProfile))
			r.With(perm(domain.PermTenantUpdate)).Put("/profile", s.h(s.updateGymProfile))

			r.Route("/users", func(r chi.Router) {
				r.Use(perm(domain.PermUsersManage))
				r.Get("/", s.h(s.gymListUsers))
				r.Post("/", s.h(s.gymCreateUser))
				r.Patch("/{userID}", s.h(s.gymUpdateUser))
				r.Post("/{userID}/reset-password", s.h(s.gymResetPassword))
			})

			r.Route("/members", func(r chi.Router) {
				r.With(perm(domain.PermMembersRead)).Get("/", s.h(s.listMembers))
				r.With(perm(domain.PermMembersWrite)).Post("/", s.h(s.createMember))
				r.With(perm(domain.PermMembersRead)).Get("/{id}", s.h(s.getMember))
				r.With(perm(domain.PermMembersWrite)).Put("/{id}", s.h(s.updateMember))
				r.With(perm(domain.PermMembershipsRead)).Get("/{id}/memberships", s.h(s.memberMemberships))
				r.With(perm(domain.PermPaymentsRead)).Get("/{id}/payments", s.h(s.memberPayments))
				r.With(perm(domain.PermAttendanceRead)).Get("/{id}/attendance", s.h(s.memberAttendance))
			})

			r.With(perm(domain.PermPlansRead)).Get("/plans", s.h(s.listPlans))
			r.With(perm(domain.PermPlansWrite)).Post("/plans", s.h(s.createPlan))
			r.With(perm(domain.PermPlansWrite)).Put("/plans/{id}", s.h(s.updatePlan))

			r.Route("/memberships", func(r chi.Router) {
				r.With(perm(domain.PermMembershipsRead)).Get("/", s.h(s.listMemberships))
				r.With(perm(domain.PermMembershipsWrite)).Post("/", s.h(s.assignMembership))
				r.With(perm(domain.PermMembershipsRead)).Get("/{id}", s.h(s.getMembership))
				r.With(perm(domain.PermMembershipsWrite)).Post("/{id}/renew", s.h(s.renewMembership))
				r.With(perm(domain.PermMembershipsWrite)).Post("/{id}/cancel", s.h(s.cancelMembership))
			})

			r.With(perm(domain.PermPaymentsRead)).Get("/payments", s.h(s.listPayments))
			r.With(perm(domain.PermPaymentsWrite)).Post("/payments", s.h(s.recordPayment))

			r.With(perm(domain.PermAttendanceRead)).Get("/attendance", s.h(s.listAttendance))
			r.With(perm(domain.PermAttendanceWrite)).Post("/attendance", s.h(s.checkIn))

			r.With(perm(domain.PermHolidaysRead)).Get("/holidays", s.h(s.listHolidays))
			r.With(perm(domain.PermHolidaysWrite)).Post("/holidays", s.h(s.createHoliday))
			r.With(perm(domain.PermHolidaysWrite)).Put("/holidays/{id}", s.h(s.updateHoliday))
			r.With(perm(domain.PermHolidaysWrite)).Delete("/holidays/{id}", s.h(s.deleteHoliday))

			r.With(perm(domain.PermLeadsRead)).Get("/leads", s.h(s.listLeads))
			r.With(perm(domain.PermLeadsWrite)).Post("/leads", s.h(s.createLead))
			r.With(perm(domain.PermLeadsWrite)).Put("/leads/{id}", s.h(s.updateLead))

			r.Route("/campaigns", func(r chi.Router) {
				r.With(perm(domain.PermCampaignsRead)).Get("/", s.h(s.listCampaigns))
				r.With(perm(domain.PermCampaignsWrite)).Post("/", s.h(s.createCampaign))
				r.With(perm(domain.PermCampaignsRead)).Get("/{id}", s.h(s.getCampaign))
				r.With(perm(domain.PermCampaignsWrite)).Put("/{id}", s.h(s.updateCampaign))
				r.With(perm(domain.PermCampaignsRead)).Get("/{id}/recipients", s.h(s.campaignRecipients))
				r.With(perm(domain.PermCampaignsWrite)).Post("/{id}/submit", s.h(s.submitCampaign))
				r.With(perm(domain.PermCampaignsApprove)).Post("/{id}/approve", s.h(s.approveCampaign))
				r.With(perm(domain.PermCampaignsApprove)).Post("/{id}/reject", s.h(s.rejectCampaign))
				r.With(perm(domain.PermCampaignsWrite)).Post("/{id}/cancel", s.h(s.cancelCampaign))
			})

			r.Route("/whatsapp", func(r chi.Router) {
				r.With(perm(domain.PermWhatsAppRead)).Get("/", s.h(s.whatsappStatus))
				r.With(perm(domain.PermWhatsAppManage)).Post("/connect", s.h(s.whatsappConnect))
				r.With(perm(domain.PermWhatsAppManage)).Get("/qr", s.h(s.whatsappQR))
				r.With(perm(domain.PermWhatsAppManage)).Post("/disconnect", s.h(s.whatsappDisconnect))
				r.With(perm(domain.PermWhatsAppManage)).Post("/test-message", s.h(s.whatsappTest))
			})

			r.With(perm(domain.PermAutomationManage)).Get("/automation-settings", s.h(s.getAutomationSettings))
			r.With(perm(domain.PermAutomationManage)).Put("/automation-settings", s.h(s.updateAutomationSettings))
			r.With(perm(domain.PermAutomationManage)).Get("/messaging-preferences", s.h(s.getMessagingPreferences))
			r.With(perm(domain.PermAutomationManage)).Put("/messaging-preferences", s.h(s.updateMessagingPreferences))
			r.With(perm(domain.PermMessagesRead)).Get("/messages", s.h(s.listMessages))
			r.With(perm(domain.PermReportsRead)).Get("/reports/daily", s.h(s.dailyReport))
		})

		r.Route("/automation", func(r chi.Router) {
			r.Use(mw.AutomationKey(d.AutomationAPIKey, we))
			r.Post("/whatsapp/refresh-status", s.h(s.automationRefreshStatus))
			r.Get("/notifications/due", s.h(s.automationDue))
			r.Post("/notifications/send", s.h(s.automationSend))
			r.Get("/campaigns/pending", s.h(s.automationPendingCampaigns))
			r.Post("/campaigns/send", s.h(s.automationSendCampaign))
		})
	})
	return r
}
