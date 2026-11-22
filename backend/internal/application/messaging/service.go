package messaging

import (
	"context"
	"errors"
	"log/slog"
	"strings"
	"time"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/audit"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

type Repo interface {
	GetTenant(ctx context.Context, id string) (domain.Tenant, error)
	GetWhatsAppSession(ctx context.Context, tenantID string) (domain.WhatsAppSession, error)
	UpdateWhatsAppStatus(ctx context.Context, tenantID, status, phone string) error
	InsertMessageLog(ctx context.Context, m *domain.MessageLog) error
	ListMessageLogs(ctx context.Context, tenantID, category string, page, size int) (domain.Page[domain.MessageLog], error)
	GetMessagingPreferences(ctx context.Context, tenantID string) (domain.MessagingPreferences, error)
	UpdateMessagingPreferences(ctx context.Context, tenantID string, p domain.MessagingPreferences) error
}

// Service owns tenant WhatsApp sessions and is the single path for sending
// messages, so every outbound message is recorded in message_logs.
type Service struct {
	repo      Repo
	provider  Provider
	audit     *audit.Logger
	defaultCC string
	log       *slog.Logger
}

func NewService(repo Repo, provider Provider, a *audit.Logger, defaultCC string, log *slog.Logger) *Service {
	return &Service{repo: repo, provider: provider, audit: a, defaultCC: defaultCC, log: log}
}

func (s *Service) ProviderName() string { return s.provider.Name() }

func (s *Service) session(ctx context.Context, tenantID string) (domain.WhatsAppSession, error) {
	return s.repo.GetWhatsAppSession(ctx, tenantID)
}

// Connect creates/starts the tenant's session so a QR code can be scanned.
func (s *Service) Connect(ctx context.Context, p domain.Principal) (domain.WhatsAppSession, error) {
	t, err := s.repo.GetTenant(ctx, p.TenantID)
	if err != nil {
		return domain.WhatsAppSession{}, err
	}
	if !t.WhatsAppEnabled {
		return domain.WhatsAppSession{}, domain.Forbidden("WhatsApp is disabled for this gym by the platform administrator")
	}
	ws, err := s.session(ctx, p.TenantID)
	if err != nil {
		return ws, err
	}
	info, err := s.provider.StartSession(ctx, ws.SessionName)
	if err != nil {
		s.log.Error("whatsapp start session failed", "session", ws.SessionName, "error", err)
		return ws, domain.Invalid("could not start the WhatsApp session; please try again")
	}
	if err := s.repo.UpdateWhatsAppStatus(ctx, p.TenantID, info.Status, info.Phone); err != nil {
		return ws, err
	}
	s.audit.Record(ctx, p, p.TenantID, "whatsapp.connect", "whatsapp_session", ws.SessionName, nil)
	return s.session(ctx, p.TenantID)
}

// Status refreshes the session state from the provider and stores it.
func (s *Service) Status(ctx context.Context, tenantID string) (domain.WhatsAppSession, error) {
	ws, err := s.session(ctx, tenantID)
	if err != nil {
		return ws, err
	}
	if ws.Status == domain.SessionNotConnected {
		return ws, nil
	}
	info, err := s.provider.SessionStatus(ctx, ws.SessionName)
	if errors.Is(err, ErrSessionNotFound) {
		info = SessionInfo{Status: domain.SessionNotConnected}
	} else if err != nil {
		s.log.Warn("whatsapp status check failed", "session", ws.SessionName, "error", err)
		return ws, nil
	}
	phone := info.Phone
	if phone == "" && info.Status == domain.SessionWorking {
		phone = ws.PhoneNumber
	}
	if err := s.repo.UpdateWhatsAppStatus(ctx, tenantID, info.Status, phone); err != nil {
		return ws, err
	}
	return s.session(ctx, tenantID)
}

func (s *Service) QR(ctx context.Context, p domain.Principal) (QRCode, error) {
	ws, err := s.Status(ctx, p.TenantID)
	if err != nil {
		return QRCode{}, err
	}
	if ws.Status != domain.SessionScanQR {
		return QRCode{}, domain.Invalid("no QR code available; session status is " + ws.Status)
	}
	qr, err := s.provider.QRCode(ctx, ws.SessionName)
	if err != nil {
		s.log.Warn("whatsapp qr failed", "session", ws.SessionName, "error", err)
		return QRCode{}, domain.Invalid("QR code not available yet; retry in a few seconds")
	}
	return qr, nil
}

func (s *Service) Disconnect(ctx context.Context, p domain.Principal) (domain.WhatsAppSession, error) {
	ws, err := s.session(ctx, p.TenantID)
	if err != nil {
		return ws, err
	}
	if err := s.provider.Disconnect(ctx, ws.SessionName); err != nil {
		s.log.Error("whatsapp disconnect failed", "session", ws.SessionName, "error", err)
		return ws, domain.Invalid("could not disconnect WhatsApp; please try again")
	}
	if err := s.repo.UpdateWhatsAppStatus(ctx, p.TenantID, domain.SessionNotConnected, ""); err != nil {
		return ws, err
	}
	s.audit.Record(ctx, p, p.TenantID, "whatsapp.disconnect", "whatsapp_session", ws.SessionName, nil)
	return s.session(ctx, p.TenantID)
}

type Outbound struct {
	TenantID          string
	Phone             string
	Name              string
	Category          string
	Body              string
	NotificationLogID *string
	SentBy            *string
}

// Send delivers one message through the tenant's own session and logs the
// outcome. A delivery failure is returned in the log, not as an error.
func (s *Service) Send(ctx context.Context, o Outbound) (domain.MessageLog, error) {
	ws, err := s.session(ctx, o.TenantID)
	if err != nil {
		return domain.MessageLog{}, err
	}
	m := domain.MessageLog{TenantID: o.TenantID, SessionName: ws.SessionName, RecipientPhone: o.Phone,
		RecipientName: o.Name, Category: o.Category, Body: o.Body, Provider: s.provider.Name(),
		NotificationLogID: o.NotificationLogID, SentBy: o.SentBy, Status: "SENT"}
	sendCtx, cancel := context.WithTimeout(ctx, 30*time.Second)
	defer cancel()
	id, err := s.provider.SendText(sendCtx, ws.SessionName, o.Phone, o.Body)
	if err != nil {
		m.Status, m.Error = "FAILED", err.Error()
		s.log.Warn("whatsapp send failed", "tenant_id", o.TenantID, "category", o.Category, "error", err)
	}
	m.ProviderMessageID = id
	if err := s.repo.InsertMessageLog(ctx, &m); err != nil {
		return m, err
	}
	m.CreatedAt = time.Now().UTC()
	return m, nil
}

type TestInput struct {
	Phone string `json:"phone" validate:"required,max=20"`
	Text  string `json:"text" validate:"max=1000"`
}

func (s *Service) SendTest(ctx context.Context, p domain.Principal, in TestInput) (domain.MessageLog, error) {
	phone, err := domain.NormalizePhone(in.Phone, s.defaultCC)
	if err != nil {
		return domain.MessageLog{}, err
	}
	ws, err := s.Status(ctx, p.TenantID)
	if err != nil {
		return domain.MessageLog{}, err
	}
	if ws.Status != domain.SessionWorking {
		return domain.MessageLog{}, domain.Invalid("WhatsApp is not connected (status " + ws.Status + ")")
	}
	text := strings.TrimSpace(in.Text)
	if text == "" {
		text = "Test message from " + p.TenantName + " via CtrlHub."
	}
	return s.Send(ctx, Outbound{TenantID: p.TenantID, Phone: phone, Category: domain.CategoryTest, Body: text, SentBy: &p.UserID})
}

func (s *Service) Messages(ctx context.Context, p domain.Principal, category string, page, size int) (domain.Page[domain.MessageLog], error) {
	page, size = domain.NormalizePaging(page, size)
	return s.repo.ListMessageLogs(ctx, p.TenantID, category, page, size)
}

func (s *Service) Preferences(ctx context.Context, p domain.Principal) (domain.MessagingPreferences, error) {
	return s.repo.GetMessagingPreferences(ctx, p.TenantID)
}

type PreferencesInput struct {
	ExpiryTemplate    string `json:"expiry_template" validate:"required,max=1000"`
	HolidayTemplate   string `json:"holiday_template" validate:"required,max=1000"`
	BirthdayTemplate  string `json:"birthday_template" validate:"required,max=1000"`
	DailyMessageLimit int    `json:"daily_message_limit" validate:"min=1,max=5000"`
}

func (s *Service) UpdatePreferences(ctx context.Context, p domain.Principal, in PreferencesInput) (domain.MessagingPreferences, error) {
	prefs := domain.MessagingPreferences(in)
	if err := s.repo.UpdateMessagingPreferences(ctx, p.TenantID, prefs); err != nil {
		return prefs, err
	}
	s.audit.Record(ctx, p, p.TenantID, "messaging.preferences_update", "tenant", p.TenantID, nil)
	return prefs, nil
}
