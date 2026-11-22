// Package campaign manages promotional campaigns: draft, approval, recipient
// snapshot and throttled delivery through n8n.
package campaign

import (
	"context"
	"slices"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/audit"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/application/messaging"
	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

type Repo interface {
	WithTx(ctx context.Context, fn func(ctx context.Context) error) error
	CreateCampaign(ctx context.Context, c *domain.Campaign) error
	UpdateCampaignContent(ctx context.Context, c domain.Campaign) error
	GetCampaign(ctx context.Context, tenantID, id string, forUpdate bool) (domain.Campaign, error)
	ListCampaigns(ctx context.Context, tenantID string) ([]domain.Campaign, error)
	SetCampaignStatus(ctx context.Context, tenantID, id, status string) error
	RejectCampaign(ctx context.Context, tenantID, id, reason string) error
	ApproveCampaign(ctx context.Context, tenantID, id, approver string) error
	MaterializeRecipients(ctx context.Context, c domain.Campaign, today domain.Date) (int, error)
	ListCampaignRecipients(ctx context.Context, tenantID, campaignID string) ([]domain.CampaignRecipient, error)
	PendingCampaignRecipients(ctx context.Context, now time.Time, limit int) ([]domain.PendingCampaignRecipient, error)
	GetCampaignRecipient(ctx context.Context, tenantID, id string) (domain.CampaignRecipient, error)
	RecipientStillConsents(ctx context.Context, tenantID, typ, id string) (bool, error)
	UpdateCampaignRecipient(ctx context.Context, tenantID, id, status, errMsg string) error
	SkipPendingRecipients(ctx context.Context, tenantID, campaignID string) error
	RefreshCampaignCounts(ctx context.Context, tenantID, campaignID string) error
	GetAutomationTenant(ctx context.Context, tenantID string) (domain.AutomationTenant, error)
	GetAutomationSettings(ctx context.Context, tenantID string) (domain.AutomationSettings, error)
}

type Deliverer interface {
	Deliver(ctx context.Context, at domain.AutomationTenant, typ, key string, o messaging.Outbound) (domain.SendResult, error)
}

type Service struct {
	repo    Repo
	deliver Deliverer
	audit   *audit.Logger
	now     func() time.Time
}

func NewService(repo Repo, d Deliverer, a *audit.Logger) *Service {
	return &Service{repo: repo, deliver: d, audit: a, now: time.Now}
}

var audiences = []domain.CampaignAudience{domain.AudienceActive, domain.AudienceExpired, domain.AudienceNewLeads,
	domain.AudienceExpiringSoon, domain.AudienceSelected}

type Input struct {
	Name           string                        `json:"name" validate:"required,max=150"`
	Message        string                        `json:"message" validate:"required,max=1500"`
	Audience       string                        `json:"audience" validate:"required"`
	AudienceParams domain.CampaignAudienceParams `json:"audience_params"`
	ScheduledAt    *time.Time                    `json:"scheduled_at"`
}

func (in Input) apply(c *domain.Campaign) error {
	aud := domain.CampaignAudience(in.Audience)
	if !slices.Contains(audiences, aud) {
		return domain.InvalidField("audience", "must be ACTIVE_MEMBERS, EXPIRED_MEMBERS, NEW_LEADS, EXPIRING_SOON or SELECTED_MEMBERS")
	}
	if aud == domain.AudienceSelected && len(in.AudienceParams.MemberIDs) == 0 {
		return domain.InvalidField("audience_params.member_ids", "select at least one member")
	}
	if len(in.AudienceParams.MemberIDs) > 1000 {
		return domain.InvalidField("audience_params.member_ids", "at most 1000 members")
	}
	for _, id := range in.AudienceParams.MemberIDs {
		if uuid.Validate(id) != nil {
			return domain.InvalidField("audience_params.member_ids", "contains an invalid id")
		}
	}
	c.Name, c.Message, c.Audience, c.AudienceParams = strings.TrimSpace(in.Name), strings.TrimSpace(in.Message), aud, in.AudienceParams
	c.ScheduledAt = in.ScheduledAt
	return nil
}

func (s *Service) Create(ctx context.Context, p domain.Principal, in Input) (domain.Campaign, error) {
	c := domain.Campaign{ID: uuid.NewString(), TenantID: p.TenantID, Status: domain.CampaignDraft, CreatedBy: &p.UserID}
	if err := in.apply(&c); err != nil {
		return c, err
	}
	if err := s.repo.CreateCampaign(ctx, &c); err != nil {
		return c, err
	}
	return s.repo.GetCampaign(ctx, p.TenantID, c.ID, false)
}

func (s *Service) Update(ctx context.Context, p domain.Principal, id string, in Input) (domain.Campaign, error) {
	c, err := s.repo.GetCampaign(ctx, p.TenantID, id, false)
	if err != nil {
		return c, err
	}
	if c.Status != domain.CampaignDraft && c.Status != domain.CampaignRejected {
		return c, domain.Conflict("only draft or rejected campaigns can be edited")
	}
	if err := in.apply(&c); err != nil {
		return c, err
	}
	c.Status = domain.CampaignDraft
	if err := s.repo.UpdateCampaignContent(ctx, c); err != nil {
		return c, err
	}
	return s.repo.GetCampaign(ctx, p.TenantID, id, false)
}

func (s *Service) Get(ctx context.Context, p domain.Principal, id string) (domain.Campaign, error) {
	return s.repo.GetCampaign(ctx, p.TenantID, id, false)
}

func (s *Service) List(ctx context.Context, p domain.Principal) ([]domain.Campaign, error) {
	return s.repo.ListCampaigns(ctx, p.TenantID)
}

func (s *Service) Recipients(ctx context.Context, p domain.Principal, id string) ([]domain.CampaignRecipient, error) {
	if _, err := s.repo.GetCampaign(ctx, p.TenantID, id, false); err != nil {
		return nil, err
	}
	return s.repo.ListCampaignRecipients(ctx, p.TenantID, id)
}

// transition moves a campaign between states under a row lock.
func (s *Service) transition(ctx context.Context, p domain.Principal, id string, from []string, fn func(ctx context.Context, c domain.Campaign) error) (domain.Campaign, error) {
	err := s.repo.WithTx(ctx, func(ctx context.Context) error {
		c, err := s.repo.GetCampaign(ctx, p.TenantID, id, true)
		if err != nil {
			return err
		}
		if !slices.Contains(from, c.Status) {
			return domain.Conflict("campaign is " + c.Status)
		}
		return fn(ctx, c)
	})
	if err != nil {
		return domain.Campaign{}, err
	}
	return s.repo.GetCampaign(ctx, p.TenantID, id, false)
}

func (s *Service) Submit(ctx context.Context, p domain.Principal, id string) (domain.Campaign, error) {
	return s.transition(ctx, p, id, []string{domain.CampaignDraft, domain.CampaignRejected}, func(ctx context.Context, c domain.Campaign) error {
		return s.repo.SetCampaignStatus(ctx, p.TenantID, id, domain.CampaignPendingApproval)
	})
}

// Approve authorizes sending and snapshots the consenting audience.
func (s *Service) Approve(ctx context.Context, p domain.Principal, id string) (domain.Campaign, error) {
	c, err := s.transition(ctx, p, id, []string{domain.CampaignPendingApproval}, func(ctx context.Context, c domain.Campaign) error {
		if err := s.repo.ApproveCampaign(ctx, p.TenantID, id, p.UserID); err != nil {
			return err
		}
		n, err := s.repo.MaterializeRecipients(ctx, c, p.Today(s.now()))
		if err != nil {
			return err
		}
		if n == 0 {
			return s.repo.SetCampaignStatus(ctx, p.TenantID, id, domain.CampaignCompleted)
		}
		return nil
	})
	if err == nil {
		s.audit.Record(ctx, p, p.TenantID, "campaign.approve", "campaign", id, map[string]any{"recipients": c.RecipientsTotal})
	}
	return c, err
}

func (s *Service) Reject(ctx context.Context, p domain.Principal, id, reason string) (domain.Campaign, error) {
	c, err := s.transition(ctx, p, id, []string{domain.CampaignPendingApproval}, func(ctx context.Context, c domain.Campaign) error {
		return s.repo.RejectCampaign(ctx, p.TenantID, id, reason)
	})
	if err == nil {
		s.audit.Record(ctx, p, p.TenantID, "campaign.reject", "campaign", id, nil)
	}
	return c, err
}

func (s *Service) Cancel(ctx context.Context, p domain.Principal, id string) (domain.Campaign, error) {
	c, err := s.transition(ctx, p, id, []string{domain.CampaignDraft, domain.CampaignPendingApproval, domain.CampaignApproved,
		domain.CampaignSending, domain.CampaignRejected}, func(ctx context.Context, c domain.Campaign) error {
		if err := s.repo.SetCampaignStatus(ctx, p.TenantID, id, domain.CampaignCancelled); err != nil {
			return err
		}
		if err := s.repo.SkipPendingRecipients(ctx, p.TenantID, id); err != nil {
			return err
		}
		return s.repo.RefreshCampaignCounts(ctx, p.TenantID, id)
	})
	if err == nil {
		s.audit.Record(ctx, p, p.TenantID, "campaign.cancel", "campaign", id, nil)
	}
	return c, err
}

// Pending lists queued campaign messages across tenants for n8n.
func (s *Service) Pending(ctx context.Context, limit int) ([]domain.PendingCampaignRecipient, error) {
	if limit <= 0 || limit > 500 {
		limit = 50
	}
	return s.repo.PendingCampaignRecipients(ctx, s.now().UTC(), limit)
}

type SendInput struct {
	TenantID    string `json:"tenant_id" validate:"required,uuid"`
	RecipientID string `json:"recipient_id" validate:"required,uuid"`
}

// Send delivers one campaign recipient after re-checking approval and consent.
func (s *Service) Send(ctx context.Context, in SendInput) (domain.SendResult, error) {
	r, err := s.repo.GetCampaignRecipient(ctx, in.TenantID, in.RecipientID)
	if err != nil {
		return domain.SendResult{}, err
	}
	key := domain.CampaignKey(r.CampaignID, r.ID)
	res := domain.SendResult{DedupeKey: key, Status: "SKIPPED"}
	if r.Status != "PENDING" {
		res.Reason = "already processed"
		return res, nil
	}
	c, err := s.repo.GetCampaign(ctx, in.TenantID, r.CampaignID, false)
	if err != nil {
		return res, err
	}
	if c.Status != domain.CampaignApproved && c.Status != domain.CampaignSending {
		res.Reason = "campaign is " + c.Status
		return res, nil
	}
	if c.ScheduledAt != nil && c.ScheduledAt.After(s.now()) {
		res.Reason = "campaign scheduled for later"
		return res, nil
	}
	at, err := s.repo.GetAutomationTenant(ctx, in.TenantID)
	if err != nil {
		return res, err
	}
	settings, err := s.repo.GetAutomationSettings(ctx, in.TenantID)
	if err != nil {
		return res, err
	}
	if at.Tenant.Status != domain.TenantActive || !at.Tenant.WhatsAppEnabled || at.SessionStatus != domain.SessionWorking || !settings.CampaignsEnabled {
		res.Reason = "tenant cannot send campaigns right now"
		return res, nil
	}
	ok, err := s.repo.RecipientStillConsents(ctx, in.TenantID, r.RecipientType, r.RecipientID)
	if err != nil {
		return res, err
	}
	if !ok {
		res.Reason = "recipient withdrew consent"
		if err := s.repo.UpdateCampaignRecipient(ctx, in.TenantID, r.ID, "SKIPPED", res.Reason); err != nil {
			return res, err
		}
		return res, s.repo.RefreshCampaignCounts(ctx, in.TenantID, c.ID)
	}
	body := domain.RenderTemplate(c.Message, map[string]string{"name": r.Name, "gym": at.Tenant.Name})
	res, err = s.deliver.Deliver(ctx, at, domain.NotifyCampaign, key, messaging.Outbound{TenantID: in.TenantID,
		Phone: r.Phone, Name: r.Name, Category: domain.CategoryCampaign, Body: body})
	if err != nil {
		return res, err
	}
	switch {
	case res.Status == "SENT" || res.Status == "FAILED":
		err = s.repo.UpdateCampaignRecipient(ctx, in.TenantID, r.ID, res.Status, res.Reason)
	case res.Reason == "already sent":
		err = s.repo.UpdateCampaignRecipient(ctx, in.TenantID, r.ID, "SKIPPED", res.Reason)
	default:
		// Daily limit and similar: leave PENDING so a later run picks it up.
		return res, nil
	}
	if err != nil {
		return res, err
	}
	return res, s.repo.RefreshCampaignCounts(ctx, in.TenantID, c.ID)
}
