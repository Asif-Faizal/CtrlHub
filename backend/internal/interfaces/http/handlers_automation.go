package http

import (
	"net/http"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/automation"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/campaign"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

// Endpoints called by n8n with the X-Automation-Key header.

func (s *server) automationRefreshStatus(w http.ResponseWriter, r *http.Request) error {
	sessions, err := s.Tenants.WhatsAppSessions(r.Context())
	if err != nil {
		return err
	}
	out := make([]domain.WhatsAppSession, 0, len(sessions))
	for _, ws := range sessions {
		if ws.Status == domain.SessionNotConnected {
			out = append(out, ws)
			continue
		}
		fresh, err := s.Messaging.Status(r.Context(), ws.TenantID)
		if err != nil {
			return err
		}
		out = append(out, fresh)
	}
	return ok(w, map[string]any{"sessions": out}, nil)
}

func (s *server) automationDue(w http.ResponseWriter, r *http.Request) error {
	items, err := s.Automation.Due(r.Context(), r.URL.Query().Get("type"), queryInt(r, "limit", 200))
	return ok(w, map[string]any{"items": items, "count": len(items)}, err)
}

func (s *server) automationSend(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in automation.SendInput) (any, error) { return s.Automation.Send(r.Context(), in) })
	return ok(w, v, err)
}

func (s *server) automationPendingCampaigns(w http.ResponseWriter, r *http.Request) error {
	items, err := s.Campaigns.Pending(r.Context(), queryInt(r, "limit", 50))
	return ok(w, map[string]any{"items": items, "count": len(items)}, err)
}

func (s *server) automationSendCampaign(w http.ResponseWriter, r *http.Request) error {
	v, err := bind(r, func(in campaign.SendInput) (any, error) { return s.Campaigns.Send(r.Context(), in) })
	return ok(w, v, err)
}
