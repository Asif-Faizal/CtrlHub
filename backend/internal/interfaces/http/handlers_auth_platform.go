package http

import (
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/auth"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/tenant"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/user"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/interfaces/dto"
	mw "github.com/Asif-Faizal/CtrlHub/backend/internal/interfaces/middleware"
)

func principal(r *http.Request) domain.Principal { return mw.PrincipalFrom(r.Context()) }

// Auth

func (s *server) login(w http.ResponseWriter, r *http.Request) error {
	var req dto.LoginRequest
	if err := decode(r, &req); err != nil {
		return err
	}
	sess, err := s.Auth.Login(r.Context(), req.Email, req.Password, r.UserAgent(), r.RemoteAddr)
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusOK, sess)
	return nil
}

func (s *server) refresh(w http.ResponseWriter, r *http.Request) error {
	var req dto.RefreshRequest
	if err := decode(r, &req); err != nil {
		return err
	}
	sess, err := s.Auth.Refresh(r.Context(), req.RefreshToken, r.UserAgent(), r.RemoteAddr)
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusOK, sess)
	return nil
}

func (s *server) logout(w http.ResponseWriter, r *http.Request) error {
	var req dto.RefreshRequest
	if err := decode(r, &req); err != nil {
		return err
	}
	if err := s.Auth.Logout(r.Context(), req.RefreshToken); err != nil {
		return err
	}
	w.WriteHeader(http.StatusNoContent)
	return nil
}

func (s *server) setupPassword(w http.ResponseWriter, r *http.Request) error {
	var req dto.SetupPasswordRequest
	if err := decode(r, &req); err != nil {
		return err
	}
	if err := s.Auth.SetupPassword(r.Context(), req.Token, req.Password); err != nil {
		return err
	}
	writeJSON(w, http.StatusOK, map[string]string{"status": "password set"})
	return nil
}

func (s *server) me(w http.ResponseWriter, r *http.Request) error {
	writeJSON(w, http.StatusOK, auth.Info(principal(r)))
	return nil
}

func (s *server) changePassword(w http.ResponseWriter, r *http.Request) error {
	var req dto.ChangePasswordRequest
	if err := decode(r, &req); err != nil {
		return err
	}
	if err := s.Auth.ChangePassword(r.Context(), principal(r).UserID, req.CurrentPassword, req.NewPassword); err != nil {
		return err
	}
	writeJSON(w, http.StatusOK, map[string]string{"status": "password changed"})
	return nil
}

// Platform administration

func (s *server) platformStats(w http.ResponseWriter, r *http.Request) error {
	st, err := s.Tenants.Stats(r.Context())
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusOK, st)
	return nil
}

func (s *server) platformWhatsApp(w http.ResponseWriter, r *http.Request) error {
	list, err := s.Tenants.WhatsAppSessions(r.Context())
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusOK, list)
	return nil
}

func (s *server) platformTenantWhatsApp(w http.ResponseWriter, r *http.Request) error {
	ws, err := s.Messaging.Status(r.Context(), chi.URLParam(r, "id"))
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusOK, ws)
	return nil
}

func (s *server) platformAudit(w http.ResponseWriter, r *http.Request) error {
	list, err := s.Tenants.Audit(r.Context(), chi.URLParam(r, "id"))
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusOK, list)
	return nil
}

func (s *server) listTenants(w http.ResponseWriter, r *http.Request) error {
	q := r.URL.Query()
	page, err := s.Tenants.List(r.Context(), q.Get("search"), q.Get("status"), queryInt(r, "page", 1), queryInt(r, "page_size", 20))
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusOK, page)
	return nil
}

func (s *server) onboardTenant(w http.ResponseWriter, r *http.Request) error {
	var in tenant.OnboardInput
	if err := decode(r, &in); err != nil {
		return err
	}
	res, err := s.Tenants.Onboard(r.Context(), principal(r), in)
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusCreated, res)
	return nil
}

func (s *server) getTenant(w http.ResponseWriter, r *http.Request) error {
	t, err := s.Tenants.Get(r.Context(), chi.URLParam(r, "id"))
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusOK, t)
	return nil
}

func (s *server) updateTenant(w http.ResponseWriter, r *http.Request) error {
	var in tenant.GymInput
	if err := decode(r, &in); err != nil {
		return err
	}
	t, err := s.Tenants.Update(r.Context(), principal(r), chi.URLParam(r, "id"), in)
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusOK, t)
	return nil
}

func (s *server) setTenantStatus(w http.ResponseWriter, r *http.Request) error {
	var req dto.StatusRequest
	if err := decode(r, &req); err != nil {
		return err
	}
	t, err := s.Tenants.SetStatus(r.Context(), principal(r), chi.URLParam(r, "id"), domain.TenantStatus(req.Status))
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusOK, t)
	return nil
}

func (s *server) platformListUsers(w http.ResponseWriter, r *http.Request) error {
	id := chi.URLParam(r, "id")
	if _, err := s.Tenants.Get(r.Context(), id); err != nil {
		return err
	}
	list, err := s.Users.List(r.Context(), id)
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusOK, list)
	return nil
}

func (s *server) platformCreateUser(w http.ResponseWriter, r *http.Request) error {
	var in user.CreateInput
	if err := decode(r, &in); err != nil {
		return err
	}
	res, err := s.Users.Create(r.Context(), principal(r), chi.URLParam(r, "id"), in, false)
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusCreated, res)
	return nil
}

func (s *server) platformUpdateUser(w http.ResponseWriter, r *http.Request) error {
	var in user.UpdateInput
	if err := decode(r, &in); err != nil {
		return err
	}
	u, err := s.Users.Update(r.Context(), principal(r), chi.URLParam(r, "id"), chi.URLParam(r, "userID"), in)
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusOK, u)
	return nil
}

func (s *server) platformResetPassword(w http.ResponseWriter, r *http.Request) error {
	link, err := s.Users.ResetPasswordAnyTenant(r.Context(), principal(r), chi.URLParam(r, "userID"))
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusOK, dto.SetupLinkResponse{SetupURL: link})
	return nil
}
