package database

import (
	"context"
	"database/sql"
	"encoding/json"
	"time"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

type AutomationTenant = domain.AutomationTenant

func (s *Store) ListAutomationTenants(ctx context.Context) ([]AutomationTenant, error) {
	rows, err := s.conn(ctx).QueryContext(ctx, `SELECT `+tenantCols+`, ws.session_name, ws.status
		FROM tenants t JOIN whatsapp_sessions ws ON ws.tenant_id = t.id
		WHERE t.status = 'ACTIVE' AND t.whatsapp_enabled = TRUE ORDER BY t.seq`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []AutomationTenant
	for rows.Next() {
		var at AutomationTenant
		if err := scanTenant(rows, &at.Tenant, &at.SessionName, &at.SessionStatus); err != nil {
			return nil, err
		}
		out = append(out, at)
	}
	return out, rows.Err()
}

func (s *Store) GetAutomationTenant(ctx context.Context, tenantID string) (AutomationTenant, error) {
	var at AutomationTenant
	err := scanTenant(s.conn(ctx).QueryRowContext(ctx, `SELECT `+tenantCols+`, ws.session_name, ws.status
		FROM tenants t JOIN whatsapp_sessions ws ON ws.tenant_id = t.id WHERE t.id = ?`, tenantID),
		&at.Tenant, &at.SessionName, &at.SessionStatus)
	return at, mapErr(err, "")
}

type ExpiryCandidate = domain.ExpiryCandidate

// ExpiryCandidates lists consenting members whose unrenewed membership ends
// on one of dates. membershipID optionally narrows to one membership.
func (s *Store) ExpiryCandidates(ctx context.Context, tenantID string, dates []domain.Date, membershipID string) ([]ExpiryCandidate, error) {
	if len(dates) == 0 {
		return nil, nil
	}
	args := []any{tenantID}
	for _, d := range dates {
		args = append(args, d)
	}
	q := `SELECT ms.id, ms.end_date, ms.plan_name, mb.id, mb.full_name, mb.phone
		FROM memberships ms JOIN members mb ON mb.tenant_id = ms.tenant_id AND mb.id = ms.member_id
		WHERE ms.tenant_id = ? AND ms.status = 'ACTIVE' AND mb.status = 'ACTIVE' AND mb.whatsapp_opt_in = TRUE
		AND ms.end_date IN (` + placeholders(len(dates)) + `)` + notRenewed
	if membershipID != "" {
		q += ` AND ms.id = ?`
		args = append(args, membershipID)
	}
	rows, err := s.conn(ctx).QueryContext(ctx, q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []ExpiryCandidate
	for rows.Next() {
		var c ExpiryCandidate
		if err := rows.Scan(&c.MembershipID, &c.EndDate, &c.PlanName, &c.MemberID, &c.MemberName, &c.Phone); err != nil {
			return nil, err
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

type MemberContact = domain.MemberContact

// NotifiableMembers lists members with WhatsApp consent and a current or
// upcoming membership. memberID optionally narrows to one member.
func (s *Store) NotifiableMembers(ctx context.Context, tenantID string, today domain.Date, memberID string) ([]MemberContact, error) {
	q := `SELECT m.id, m.full_name, m.phone FROM members m WHERE m.tenant_id = ? AND m.status = 'ACTIVE'
		AND m.whatsapp_opt_in = TRUE AND EXISTS (SELECT 1 FROM memberships x WHERE x.tenant_id = m.tenant_id
		AND x.member_id = m.id AND x.status = 'ACTIVE' AND x.end_date >= ?)`
	args := []any{tenantID, today}
	if memberID != "" {
		q += ` AND m.id = ?`
		args = append(args, memberID)
	}
	return s.contacts(ctx, q, args...)
}

// BirthdayMembers lists consenting active members born on the given month/day.
func (s *Store) BirthdayMembers(ctx context.Context, tenantID string, month, day int, memberID string) ([]MemberContact, error) {
	q := `SELECT m.id, m.full_name, m.phone FROM members m WHERE m.tenant_id = ? AND m.status = 'ACTIVE'
		AND m.whatsapp_opt_in = TRUE AND m.date_of_birth IS NOT NULL
		AND MONTH(m.date_of_birth) = ? AND DAYOFMONTH(m.date_of_birth) = ?`
	args := []any{tenantID, month, day}
	if memberID != "" {
		q += ` AND m.id = ?`
		args = append(args, memberID)
	}
	return s.contacts(ctx, q, args...)
}

func (s *Store) contacts(ctx context.Context, q string, args ...any) ([]MemberContact, error) {
	rows, err := s.conn(ctx).QueryContext(ctx, q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []MemberContact
	for rows.Next() {
		var c MemberContact
		if err := rows.Scan(&c.ID, &c.Name, &c.Phone); err != nil {
			return nil, err
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

// Campaigns

const campaignCols = `id, tenant_id, name, message, audience, audience_params, status, scheduled_at, created_by,
	approved_by, approved_at, rejection_reason, recipients_total, sent_count, failed_count, skipped_count, created_at, updated_at`

func scanCampaign(sc scanner, c *domain.Campaign) error {
	var params []byte
	var sched, appAt sql.NullTime
	var by, appBy sql.NullString
	if err := sc.Scan(&c.ID, &c.TenantID, &c.Name, &c.Message, &c.Audience, &params, &c.Status, &sched, &by, &appBy,
		&appAt, &c.RejectionReason, &c.RecipientsTotal, &c.SentCount, &c.FailedCount, &c.SkippedCount,
		&c.CreatedAt, &c.UpdatedAt); err != nil {
		return err
	}
	if len(params) > 0 {
		_ = json.Unmarshal(params, &c.AudienceParams)
	}
	c.ScheduledAt, c.ApprovedAt = nullTimePtr(sched), nullTimePtr(appAt)
	c.CreatedBy, c.ApprovedBy = nullStringPtr(by), nullStringPtr(appBy)
	return nil
}

func (s *Store) CreateCampaign(ctx context.Context, c *domain.Campaign) error {
	params, _ := json.Marshal(c.AudienceParams)
	_, err := s.conn(ctx).ExecContext(ctx, `INSERT INTO campaigns (id, tenant_id, name, message, audience,
		audience_params, status, scheduled_at, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		c.ID, c.TenantID, c.Name, c.Message, c.Audience, string(params), c.Status, c.ScheduledAt, c.CreatedBy)
	return mapErr(err, "")
}

func (s *Store) UpdateCampaignContent(ctx context.Context, c domain.Campaign) error {
	params, _ := json.Marshal(c.AudienceParams)
	_, err := s.conn(ctx).ExecContext(ctx, `UPDATE campaigns SET name = ?, message = ?, audience = ?, audience_params = ?,
		scheduled_at = ?, status = ?, rejection_reason = '' WHERE tenant_id = ? AND id = ?`,
		c.Name, c.Message, c.Audience, string(params), c.ScheduledAt, c.Status, c.TenantID, c.ID)
	return mapErr(err, "")
}

func (s *Store) GetCampaign(ctx context.Context, tenantID, id string, forUpdate bool) (domain.Campaign, error) {
	var c domain.Campaign
	q := `SELECT ` + campaignCols + ` FROM campaigns WHERE tenant_id = ? AND id = ?`
	if forUpdate {
		q += ` FOR UPDATE`
	}
	err := scanCampaign(s.conn(ctx).QueryRowContext(ctx, q, tenantID, id), &c)
	return c, mapErr(err, "")
}

func (s *Store) ListCampaigns(ctx context.Context, tenantID string) ([]domain.Campaign, error) {
	rows, err := s.conn(ctx).QueryContext(ctx, `SELECT `+campaignCols+` FROM campaigns WHERE tenant_id = ?
		ORDER BY created_at DESC LIMIT 200`, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.Campaign{}
	for rows.Next() {
		var c domain.Campaign
		if err := scanCampaign(rows, &c); err != nil {
			return nil, err
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

func (s *Store) SetCampaignStatus(ctx context.Context, tenantID, id, status string) error {
	_, err := s.conn(ctx).ExecContext(ctx, `UPDATE campaigns SET status = ? WHERE tenant_id = ? AND id = ?`, status, tenantID, id)
	return err
}

func (s *Store) RejectCampaign(ctx context.Context, tenantID, id, reason string) error {
	_, err := s.conn(ctx).ExecContext(ctx, `UPDATE campaigns SET status = 'REJECTED', rejection_reason = ?
		WHERE tenant_id = ? AND id = ?`, reason, tenantID, id)
	return err
}

func (s *Store) ApproveCampaign(ctx context.Context, tenantID, id, approver string) error {
	_, err := s.conn(ctx).ExecContext(ctx, `UPDATE campaigns SET status = 'APPROVED', approved_by = ?, approved_at = ?
		WHERE tenant_id = ? AND id = ?`, approver, time.Now().UTC(), tenantID, id)
	return err
}

// MaterializeRecipients snapshots the consenting audience into campaign_recipients.
func (s *Store) MaterializeRecipients(ctx context.Context, c domain.Campaign, today domain.Date) (int, error) {
	const memberInsert = `INSERT INTO campaign_recipients (id, tenant_id, campaign_id, recipient_type, recipient_id, name, phone)
		SELECT UUID(), m.tenant_id, ?, 'MEMBER', m.id, m.full_name, m.phone FROM members m
		WHERE m.tenant_id = ? AND m.status = 'ACTIVE' AND m.whatsapp_opt_in = TRUE AND m.marketing_opt_in = TRUE`
	const msExists = ` EXISTS (SELECT 1 FROM memberships x WHERE x.tenant_id = m.tenant_id AND x.member_id = m.id AND x.status = 'ACTIVE'`
	args := []any{c.ID, c.TenantID}
	var q string
	switch c.Audience {
	case domain.AudienceActive:
		q = memberInsert + ` AND` + msExists + ` AND x.start_date <= ? AND x.end_date >= ?)`
		args = append(args, today, today)
	case domain.AudienceExpired:
		q = memberInsert + ` AND` + msExists + `) AND NOT` + msExists + ` AND x.end_date >= ?)`
		args = append(args, today)
	case domain.AudienceExpiringSoon:
		days := c.AudienceParams.ExpiringInDays
		if days <= 0 {
			days = 7
		}
		q = memberInsert + ` AND EXISTS (SELECT 1 FROM memberships ms WHERE ms.tenant_id = m.tenant_id
			AND ms.member_id = m.id AND ms.status = 'ACTIVE' AND ms.end_date BETWEEN ? AND ?` + notRenewed + `)`
		args = append(args, today, today.AddDays(days))
	case domain.AudienceSelected:
		if len(c.AudienceParams.MemberIDs) == 0 {
			return 0, nil
		}
		q = memberInsert + ` AND m.id IN (` + placeholders(len(c.AudienceParams.MemberIDs)) + `)`
		for _, id := range c.AudienceParams.MemberIDs {
			args = append(args, id)
		}
	case domain.AudienceNewLeads:
		days := c.AudienceParams.LeadsCreatedDays
		if days <= 0 {
			days = 30
		}
		q = `INSERT INTO campaign_recipients (id, tenant_id, campaign_id, recipient_type, recipient_id, name, phone)
			SELECT UUID(), l.tenant_id, ?, 'LEAD', l.id, l.full_name, l.phone FROM leads l
			WHERE l.tenant_id = ? AND l.status = 'NEW' AND l.whatsapp_opt_in = TRUE AND l.marketing_opt_in = TRUE
			AND l.created_at >= ?`
		args = append(args, time.Now().UTC().AddDate(0, 0, -days))
	default:
		return 0, domain.InvalidField("audience", "unsupported audience")
	}
	res, err := s.conn(ctx).ExecContext(ctx, q, args...)
	if err != nil {
		return 0, mapErr(err, "")
	}
	n, _ := res.RowsAffected()
	_, err = s.conn(ctx).ExecContext(ctx, `UPDATE campaigns SET recipients_total = ? WHERE tenant_id = ? AND id = ?`, n, c.TenantID, c.ID)
	return int(n), err
}

func (s *Store) ListCampaignRecipients(ctx context.Context, tenantID, campaignID string) ([]domain.CampaignRecipient, error) {
	rows, err := s.conn(ctx).QueryContext(ctx, `SELECT id, tenant_id, campaign_id, recipient_type, recipient_id, name, phone,
		status, error, sent_at FROM campaign_recipients WHERE tenant_id = ? AND campaign_id = ? ORDER BY name LIMIT 1000`,
		tenantID, campaignID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.CampaignRecipient{}
	for rows.Next() {
		var r domain.CampaignRecipient
		var sent sql.NullTime
		if err := rows.Scan(&r.ID, &r.TenantID, &r.CampaignID, &r.RecipientType, &r.RecipientID, &r.Name, &r.Phone,
			&r.Status, &r.Error, &sent); err != nil {
			return nil, err
		}
		r.SentAt = nullTimePtr(sent)
		out = append(out, r)
	}
	return out, rows.Err()
}

type PendingCampaignRecipient = domain.PendingCampaignRecipient

func (s *Store) PendingCampaignRecipients(ctx context.Context, now time.Time, limit int) ([]PendingCampaignRecipient, error) {
	rows, err := s.conn(ctx).QueryContext(ctx, `SELECT cr.tenant_id, t.code, c.id, c.name, cr.id, cr.name, cr.phone
		FROM campaign_recipients cr
		JOIN campaigns c ON c.tenant_id = cr.tenant_id AND c.id = cr.campaign_id
		JOIN tenants t ON t.id = cr.tenant_id
		JOIN whatsapp_sessions ws ON ws.tenant_id = cr.tenant_id
		JOIN automation_settings a ON a.tenant_id = cr.tenant_id
		WHERE cr.status = 'PENDING' AND c.status IN ('APPROVED', 'SENDING')
		AND (c.scheduled_at IS NULL OR c.scheduled_at <= ?)
		AND t.status = 'ACTIVE' AND t.whatsapp_enabled = TRUE AND ws.status = 'WORKING' AND a.campaigns_enabled = TRUE
		ORDER BY c.approved_at, cr.created_at LIMIT ?`, now, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []PendingCampaignRecipient{}
	for rows.Next() {
		var p PendingCampaignRecipient
		if err := rows.Scan(&p.TenantID, &p.TenantCode, &p.CampaignID, &p.CampaignName, &p.RecipientID, &p.Name, &p.Phone); err != nil {
			return nil, err
		}
		out = append(out, p)
	}
	return out, rows.Err()
}

func (s *Store) GetCampaignRecipient(ctx context.Context, tenantID, id string) (domain.CampaignRecipient, error) {
	var r domain.CampaignRecipient
	var sent sql.NullTime
	err := s.conn(ctx).QueryRowContext(ctx, `SELECT id, tenant_id, campaign_id, recipient_type, recipient_id, name, phone,
		status, error, sent_at FROM campaign_recipients WHERE tenant_id = ? AND id = ?`, tenantID, id).
		Scan(&r.ID, &r.TenantID, &r.CampaignID, &r.RecipientType, &r.RecipientID, &r.Name, &r.Phone, &r.Status, &r.Error, &sent)
	r.SentAt = nullTimePtr(sent)
	return r, mapErr(err, "")
}

// RecipientStillConsents re-checks marketing consent at send time.
func (s *Store) RecipientStillConsents(ctx context.Context, tenantID, typ, id string) (bool, error) {
	table := "members"
	if typ == "LEAD" {
		table = "leads"
	}
	var ok bool
	err := s.conn(ctx).QueryRowContext(ctx, `SELECT whatsapp_opt_in AND marketing_opt_in FROM `+table+`
		WHERE tenant_id = ? AND id = ?`, tenantID, id).Scan(&ok)
	if err == sql.ErrNoRows {
		return false, nil
	}
	return ok, err
}

func (s *Store) UpdateCampaignRecipient(ctx context.Context, tenantID, id, status, errMsg string) error {
	if len(errMsg) > 500 {
		errMsg = errMsg[:500]
	}
	var sentAt any
	if status == "SENT" {
		sentAt = time.Now().UTC()
	}
	_, err := s.conn(ctx).ExecContext(ctx, `UPDATE campaign_recipients SET status = ?, error = ?, sent_at = ?
		WHERE tenant_id = ? AND id = ?`, status, errMsg, sentAt, tenantID, id)
	return err
}

// SkipPendingRecipients marks all pending recipients skipped (campaign cancelled).
func (s *Store) SkipPendingRecipients(ctx context.Context, tenantID, campaignID string) error {
	_, err := s.conn(ctx).ExecContext(ctx, `UPDATE campaign_recipients SET status = 'SKIPPED', error = 'campaign cancelled'
		WHERE tenant_id = ? AND campaign_id = ? AND status = 'PENDING'`, tenantID, campaignID)
	return err
}

// RefreshCampaignCounts recomputes counters and completes the campaign when
// nothing is pending.
func (s *Store) RefreshCampaignCounts(ctx context.Context, tenantID, campaignID string) error {
	_, err := s.conn(ctx).ExecContext(ctx, `UPDATE campaigns c
		JOIN (SELECT SUM(status = 'SENT') sent, SUM(status = 'FAILED') failed, SUM(status = 'SKIPPED') skipped,
			SUM(status = 'PENDING') pending FROM campaign_recipients WHERE tenant_id = ? AND campaign_id = ?) r
		SET c.sent_count = COALESCE(r.sent, 0), c.failed_count = COALESCE(r.failed, 0),
			c.skipped_count = COALESCE(r.skipped, 0),
			c.status = CASE WHEN c.status IN ('APPROVED', 'SENDING') AND COALESCE(r.pending, 0) = 0 THEN 'COMPLETED'
				WHEN c.status = 'APPROVED' THEN 'SENDING' ELSE c.status END
		WHERE c.tenant_id = ? AND c.id = ?`, tenantID, campaignID, tenantID, campaignID)
	return err
}
