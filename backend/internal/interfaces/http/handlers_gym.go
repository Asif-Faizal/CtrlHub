package http

import (
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/attendance"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/automation"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/campaign"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/member"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/membership"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/messaging"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/tenant"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/user"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/interfaces/dto"
)

// All gym handlers take the tenant from the authenticated principal; no
// tenant identifier is ever read from the request.

func ok(w http.ResponseWriter, v any, err error) error {
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusOK, v)
	return nil
}

func created(w http.ResponseWriter, v any, err error) error {
	if err != nil {
		return err
	}
	writeJSON(w, http.StatusCreated, v)
	return nil
}

// bind decodes the body into a new T and calls fn with it.
func bind[T any](r *http.Request, fn func(T) (any, error)) (any, error) {
	var in T
	if err := decode(r, &in); err != nil {
		return nil, err
	}
	return fn(in)
}

// Profile

func (s *server) gymProfile(w http.ResponseWriter, r *http.Request) error {
	t, err := s.Tenants.Get(r.Context(), principal(r).TenantID)
	return ok(w, t, err)
}

func (s *server) updateGymProfile(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in tenant.ProfileInput) (any, error) {
		return s.Tenants.UpdateProfile(r.Context(), principal(r), in)
	})
	return ok(w, v, err)
}

// Users

func (s *server) gymListUsers(w http.ResponseWriter, r *http.Request) error {
	list, err := s.Users.List(r.Context(), principal(r).TenantID)
	return ok(w, list, err)
}

func (s *server) gymCreateUser(w http.ResponseWriter, r *http.Request) error {
	p := principal(r)
	v, err := bind(r, func(in user.CreateInput) (any, error) { return s.Users.Create(r.Context(), p, p.TenantID, in, false) })
	return created(w, v, err)
}

func (s *server) gymUpdateUser(w http.ResponseWriter, r *http.Request) error {
	p := principal(r)
	v, err := bind(r, func(in user.UpdateInput) (any, error) {
		return s.Users.Update(r.Context(), p, p.TenantID, chi.URLParam(r, "userID"), in)
	})
	return ok(w, v, err)
}

func (s *server) gymResetPassword(w http.ResponseWriter, r *http.Request) error {
	p := principal(r)
	link, err := s.Users.ResetPassword(r.Context(), p, p.TenantID, chi.URLParam(r, "userID"))
	return ok(w, dto.SetupLinkResponse{SetupURL: link}, err)
}

// Members

func (s *server) listMembers(w http.ResponseWriter, r *http.Request) error {
	q := r.URL.Query()
	page, err := s.Members.List(r.Context(), principal(r), q.Get("search"), q.Get("status"),
		queryInt(r, "page", 1), queryInt(r, "page_size", 20))
	return ok(w, page, err)
}

func (s *server) createMember(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in member.Input) (any, error) { return s.Members.Create(r.Context(), principal(r), in) })
	return created(w, v, err)
}

func (s *server) getMember(w http.ResponseWriter, r *http.Request) error {
	m, err := s.Members.Get(r.Context(), principal(r), chi.URLParam(r, "id"))
	return ok(w, m, err)
}

func (s *server) updateMember(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in member.Input) (any, error) {
		return s.Members.Update(r.Context(), principal(r), chi.URLParam(r, "id"), in)
	})
	return ok(w, v, err)
}

func (s *server) memberMemberships(w http.ResponseWriter, r *http.Request) error {
	p := principal(r)
	id := chi.URLParam(r, "id")
	if _, err := s.Members.Get(r.Context(), p, id); err != nil {
		return err
	}
	page, err := s.Memberships.List(r.Context(), p, id, "all", 0, 1, 100)
	return ok(w, page, err)
}

func (s *server) memberPayments(w http.ResponseWriter, r *http.Request) error {
	p := principal(r)
	id := chi.URLParam(r, "id")
	if _, err := s.Members.Get(r.Context(), p, id); err != nil {
		return err
	}
	page, err := s.Memberships.ListPayments(r.Context(), p, id, nil, nil, 1, 100)
	return ok(w, page, err)
}

func (s *server) memberAttendance(w http.ResponseWriter, r *http.Request) error {
	p := principal(r)
	id := chi.URLParam(r, "id")
	if _, err := s.Members.Get(r.Context(), p, id); err != nil {
		return err
	}
	list, err := s.Attendance.List(r.Context(), p, nil, id)
	return ok(w, list, err)
}

// Plans and memberships

func (s *server) listPlans(w http.ResponseWriter, r *http.Request) error {
	list, err := s.Memberships.ListPlans(r.Context(), principal(r), r.URL.Query().Get("active") == "true")
	return ok(w, list, err)
}

func (s *server) createPlan(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in membership.PlanInput) (any, error) {
		return s.Memberships.CreatePlan(r.Context(), principal(r), in)
	})
	return created(w, v, err)
}

func (s *server) updatePlan(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in membership.PlanInput) (any, error) {
		return s.Memberships.UpdatePlan(r.Context(), principal(r), chi.URLParam(r, "id"), in)
	})
	return ok(w, v, err)
}

func (s *server) listMemberships(w http.ResponseWriter, r *http.Request) error {
	q := r.URL.Query()
	page, err := s.Memberships.List(r.Context(), principal(r), q.Get("member_id"), q.Get("view"), queryInt(r, "days", 0),
		queryInt(r, "page", 1), queryInt(r, "page_size", 20))
	return ok(w, page, err)
}

func (s *server) assignMembership(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in membership.AssignInput) (any, error) {
		return s.Memberships.Assign(r.Context(), principal(r), in)
	})
	return created(w, v, err)
}

func (s *server) getMembership(w http.ResponseWriter, r *http.Request) error {
	m, err := s.Memberships.Get(r.Context(), principal(r), chi.URLParam(r, "id"))
	return ok(w, m, err)
}

func (s *server) renewMembership(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in membership.RenewInput) (any, error) {
		return s.Memberships.Renew(r.Context(), principal(r), chi.URLParam(r, "id"), in)
	})
	return created(w, v, err)
}

func (s *server) cancelMembership(w http.ResponseWriter, r *http.Request) error {
	m, err := s.Memberships.Cancel(r.Context(), principal(r), chi.URLParam(r, "id"))
	return ok(w, m, err)
}

// Payments

func (s *server) listPayments(w http.ResponseWriter, r *http.Request) error {
	from, err := queryDate(r, "from")
	if err != nil {
		return err
	}
	to, err := queryDate(r, "to")
	if err != nil {
		return err
	}
	page, err := s.Memberships.ListPayments(r.Context(), principal(r), r.URL.Query().Get("member_id"), from, to,
		queryInt(r, "page", 1), queryInt(r, "page_size", 20))
	return ok(w, page, err)
}

func (s *server) recordPayment(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in membership.PaymentInput) (any, error) {
		return s.Memberships.RecordPayment(r.Context(), principal(r), in)
	})
	return created(w, v, err)
}

// Attendance and holidays

func (s *server) listAttendance(w http.ResponseWriter, r *http.Request) error {
	d, err := queryDate(r, "date")
	if err != nil {
		return err
	}
	list, err := s.Attendance.List(r.Context(), principal(r), d, r.URL.Query().Get("member_id"))
	return ok(w, list, err)
}

func (s *server) checkIn(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in attendance.CheckInInput) (any, error) {
		return s.Attendance.CheckIn(r.Context(), principal(r), in)
	})
	return created(w, v, err)
}

func (s *server) listHolidays(w http.ResponseWriter, r *http.Request) error {
	list, err := s.Attendance.ListHolidays(r.Context(), principal(r), r.URL.Query().Get("upcoming") == "true")
	return ok(w, list, err)
}

func (s *server) createHoliday(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in attendance.HolidayInput) (any, error) {
		return s.Attendance.CreateHoliday(r.Context(), principal(r), in)
	})
	return created(w, v, err)
}

func (s *server) updateHoliday(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in attendance.HolidayInput) (any, error) {
		return s.Attendance.UpdateHoliday(r.Context(), principal(r), chi.URLParam(r, "id"), in)
	})
	return ok(w, v, err)
}

func (s *server) deleteHoliday(w http.ResponseWriter, r *http.Request) error {
	if err := s.Attendance.DeleteHoliday(r.Context(), principal(r), chi.URLParam(r, "id")); err != nil {
		return err
	}
	w.WriteHeader(http.StatusNoContent)
	return nil
}

// Leads

func (s *server) listLeads(w http.ResponseWriter, r *http.Request) error {
	list, err := s.Members.ListLeads(r.Context(), principal(r), r.URL.Query().Get("status"))
	return ok(w, list, err)
}

func (s *server) createLead(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in member.LeadInput) (any, error) { return s.Members.CreateLead(r.Context(), principal(r), in) })
	return created(w, v, err)
}

func (s *server) updateLead(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in member.LeadInput) (any, error) {
		return s.Members.UpdateLead(r.Context(), principal(r), chi.URLParam(r, "id"), in)
	})
	return ok(w, v, err)
}

// Campaigns

func (s *server) listCampaigns(w http.ResponseWriter, r *http.Request) error {
	list, err := s.Campaigns.List(r.Context(), principal(r))
	return ok(w, list, err)
}

func (s *server) createCampaign(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in campaign.Input) (any, error) { return s.Campaigns.Create(r.Context(), principal(r), in) })
	return created(w, v, err)
}

func (s *server) getCampaign(w http.ResponseWriter, r *http.Request) error {
	c, err := s.Campaigns.Get(r.Context(), principal(r), chi.URLParam(r, "id"))
	return ok(w, c, err)
}

func (s *server) updateCampaign(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in campaign.Input) (any, error) {
		return s.Campaigns.Update(r.Context(), principal(r), chi.URLParam(r, "id"), in)
	})
	return ok(w, v, err)
}

func (s *server) campaignRecipients(w http.ResponseWriter, r *http.Request) error {
	list, err := s.Campaigns.Recipients(r.Context(), principal(r), chi.URLParam(r, "id"))
	return ok(w, list, err)
}

func (s *server) submitCampaign(w http.ResponseWriter, r *http.Request) error {
	c, err := s.Campaigns.Submit(r.Context(), principal(r), chi.URLParam(r, "id"))
	return ok(w, c, err)
}

func (s *server) approveCampaign(w http.ResponseWriter, r *http.Request) error {
	c, err := s.Campaigns.Approve(r.Context(), principal(r), chi.URLParam(r, "id"))
	return ok(w, c, err)
}

func (s *server) rejectCampaign(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in dto.RejectRequest) (any, error) {
		return s.Campaigns.Reject(r.Context(), principal(r), chi.URLParam(r, "id"), in.Reason)
	})
	return ok(w, v, err)
}

func (s *server) cancelCampaign(w http.ResponseWriter, r *http.Request) error {
	c, err := s.Campaigns.Cancel(r.Context(), principal(r), chi.URLParam(r, "id"))
	return ok(w, c, err)
}

// WhatsApp

func (s *server) whatsappStatus(w http.ResponseWriter, r *http.Request) error {
	ws, err := s.Messaging.Status(r.Context(), principal(r).TenantID)
	return ok(w, map[string]any{"session": ws, "provider": s.Messaging.ProviderName()}, err)
}

func (s *server) whatsappConnect(w http.ResponseWriter, r *http.Request) error {
	ws, err := s.Messaging.Connect(r.Context(), principal(r))
	return ok(w, ws, err)
}

func (s *server) whatsappQR(w http.ResponseWriter, r *http.Request) error {
	qr, err := s.Messaging.QR(r.Context(), principal(r))
	return ok(w, qr, err)
}

func (s *server) whatsappDisconnect(w http.ResponseWriter, r *http.Request) error {
	ws, err := s.Messaging.Disconnect(r.Context(), principal(r))
	return ok(w, ws, err)
}

func (s *server) whatsappTest(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in messaging.TestInput) (any, error) { return s.Messaging.SendTest(r.Context(), principal(r), in) })
	return ok(w, v, err)
}

// Automation settings, messages and reports

func (s *server) getAutomationSettings(w http.ResponseWriter, r *http.Request) error {
	a, err := s.Automation.Settings(r.Context(), principal(r))
	return ok(w, a, err)
}

func (s *server) updateAutomationSettings(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in automation.SettingsInput) (any, error) {
		return s.Automation.UpdateSettings(r.Context(), principal(r), in)
	})
	return ok(w, v, err)
}

func (s *server) getMessagingPreferences(w http.ResponseWriter, r *http.Request) error {
	p, err := s.Messaging.Preferences(r.Context(), principal(r))
	return ok(w, p, err)
}

func (s *server) updateMessagingPreferences(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in messaging.PreferencesInput) (any, error) {
		return s.Messaging.UpdatePreferences(r.Context(), principal(r), in)
	})
	return ok(w, v, err)
}

func (s *server) listMessages(w http.ResponseWriter, r *http.Request) error {
	page, err := s.Messaging.Messages(r.Context(), principal(r), r.URL.Query().Get("category"),
		queryInt(r, "page", 1), queryInt(r, "page_size", 20))
	return ok(w, page, err)
}

func (s *server) dailyReport(w http.ResponseWriter, r *http.Request) error {
	d, err := queryDate(r, "date")
	if err != nil {
		return err
	}
	p := principal(r)
	rep, err := s.Reports.Daily(r.Context(), p.TenantID, p.TenantTimezone, d)
	return ok(w, rep, err)
}
