package database

import (
	"context"
	"database/sql"
	"encoding/json"
	"time"

	"github.com/google/uuid"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

func (s *Store) GetWhatsAppSession(ctx context.Context, tenantID string) (domain.WhatsAppSession, error) {
	var ws domain.WhatsAppSession
	var last sql.NullTime
	err := s.conn(ctx).QueryRowContext(ctx, `SELECT ws.tenant_id, t.name, ws.session_name, ws.phone_number, ws.status,
		ws.last_status_at FROM whatsapp_sessions ws JOIN tenants t ON t.id = ws.tenant_id WHERE ws.tenant_id = ?`, tenantID).
		Scan(&ws.TenantID, &ws.TenantName, &ws.SessionName, &ws.PhoneNumber, &ws.Status, &last)
	ws.LastStatusAt = nullTimePtr(last)
	return ws, mapErr(err, "")
}

func (s *Store) UpdateWhatsAppStatus(ctx context.Context, tenantID, status, phone string) error {
	_, err := s.conn(ctx).ExecContext(ctx, `UPDATE whatsapp_sessions SET status = ?, phone_number = ?, last_status_at = ?
		WHERE tenant_id = ?`, status, phone, time.Now().UTC(), tenantID)
	return err
}

func (s *Store) ListWhatsAppSessions(ctx context.Context) ([]domain.WhatsAppSession, error) {
	rows, err := s.conn(ctx).QueryContext(ctx, `SELECT ws.tenant_id, t.name, ws.session_name, ws.phone_number,
		ws.status, ws.last_status_at FROM whatsapp_sessions ws JOIN tenants t ON t.id = ws.tenant_id ORDER BY t.name`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.WhatsAppSession{}
	for rows.Next() {
		var ws domain.WhatsAppSession
		var last sql.NullTime
		if err := rows.Scan(&ws.TenantID, &ws.TenantName, &ws.SessionName, &ws.PhoneNumber, &ws.Status, &last); err != nil {
			return nil, err
		}
		ws.LastStatusAt = nullTimePtr(last)
		out = append(out, ws)
	}
	return out, rows.Err()
}

func (s *Store) InsertMessageLog(ctx context.Context, m *domain.MessageLog) error {
	if m.ID == "" {
		m.ID = uuid.NewString()
	}
	if len(m.Error) > 500 {
		m.Error = m.Error[:500]
	}
	_, err := s.conn(ctx).ExecContext(ctx, `INSERT INTO message_logs (id, tenant_id, session_name, recipient_phone,
		recipient_name, category, body, provider, provider_message_id, status, error, notification_log_id, sent_by)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		m.ID, m.TenantID, m.SessionName, m.RecipientPhone, m.RecipientName, m.Category, m.Body, m.Provider,
		m.ProviderMessageID, m.Status, m.Error, m.NotificationLogID, m.SentBy)
	return err
}

func (s *Store) ListMessageLogs(ctx context.Context, tenantID, category string, page, size int) (domain.Page[domain.MessageLog], error) {
	where, args := ` WHERE tenant_id = ?`, []any{tenantID}
	if category != "" {
		where += ` AND category = ?`
		args = append(args, category)
	}
	out := domain.Page[domain.MessageLog]{Items: []domain.MessageLog{}, Page: page, PageSize: size}
	if err := s.conn(ctx).QueryRowContext(ctx, `SELECT COUNT(*) FROM message_logs`+where, args...).Scan(&out.Total); err != nil {
		return out, err
	}
	rows, err := s.conn(ctx).QueryContext(ctx, `SELECT id, tenant_id, session_name, recipient_phone, recipient_name,
		category, body, provider, provider_message_id, status, error, notification_log_id, sent_by, created_at
		FROM message_logs`+where+` ORDER BY created_at DESC LIMIT ? OFFSET ?`, append(args, size, (page-1)*size)...)
	if err != nil {
		return out, err
	}
	defer rows.Close()
	for rows.Next() {
		var m domain.MessageLog
		var nl, by sql.NullString
		if err := rows.Scan(&m.ID, &m.TenantID, &m.SessionName, &m.RecipientPhone, &m.RecipientName, &m.Category,
			&m.Body, &m.Provider, &m.ProviderMessageID, &m.Status, &m.Error, &nl, &by, &m.CreatedAt); err != nil {
			return out, err
		}
		m.NotificationLogID, m.SentBy = nullStringPtr(nl), nullStringPtr(by)
		out.Items = append(out.Items, m)
	}
	return out, rows.Err()
}

// CountMessagesSince counts sent automated/campaign messages (test messages excluded).
func (s *Store) CountMessagesSince(ctx context.Context, tenantID string, since time.Time) (int, error) {
	var n int
	err := s.conn(ctx).QueryRowContext(ctx, `SELECT COUNT(*) FROM message_logs WHERE tenant_id = ? AND created_at >= ?
		AND status = 'SENT' AND category <> 'TEST'`, tenantID, since).Scan(&n)
	return n, err
}

func (s *Store) GetMessagingPreferences(ctx context.Context, tenantID string) (domain.MessagingPreferences, error) {
	var p domain.MessagingPreferences
	err := s.conn(ctx).QueryRowContext(ctx, `SELECT expiry_template, holiday_template, birthday_template,
		daily_message_limit FROM messaging_preferences WHERE tenant_id = ?`, tenantID).
		Scan(&p.ExpiryTemplate, &p.HolidayTemplate, &p.BirthdayTemplate, &p.DailyMessageLimit)
	if err == sql.ErrNoRows {
		return domain.DefaultMessagingPreferences, nil
	}
	return p, err
}

func (s *Store) UpdateMessagingPreferences(ctx context.Context, tenantID string, p domain.MessagingPreferences) error {
	_, err := s.conn(ctx).ExecContext(ctx, `INSERT INTO messaging_preferences (tenant_id, expiry_template, holiday_template,
		birthday_template, daily_message_limit) VALUES (?, ?, ?, ?, ?)
		ON DUPLICATE KEY UPDATE expiry_template = VALUES(expiry_template), holiday_template = VALUES(holiday_template),
		birthday_template = VALUES(birthday_template), daily_message_limit = VALUES(daily_message_limit)`,
		tenantID, p.ExpiryTemplate, p.HolidayTemplate, p.BirthdayTemplate, p.DailyMessageLimit)
	return err
}

func (s *Store) GetAutomationSettings(ctx context.Context, tenantID string) (domain.AutomationSettings, error) {
	var a domain.AutomationSettings
	var days []byte
	err := s.conn(ctx).QueryRowContext(ctx, `SELECT expiry_enabled, expiry_days_before, holiday_enabled, birthday_enabled,
		campaigns_enabled, daily_report_enabled, daily_report_phone FROM automation_settings WHERE tenant_id = ?`, tenantID).
		Scan(&a.ExpiryEnabled, &days, &a.HolidayEnabled, &a.BirthdayEnabled, &a.CampaignsEnabled, &a.DailyReportEnabled,
			&a.DailyReportPhone)
	if err != nil {
		return a, mapErr(err, "")
	}
	a.ExpiryDaysBefore = []int{}
	_ = json.Unmarshal(days, &a.ExpiryDaysBefore)
	return a, nil
}

func (s *Store) UpdateAutomationSettings(ctx context.Context, tenantID string, a domain.AutomationSettings) error {
	days, _ := json.Marshal(a.ExpiryDaysBefore)
	_, err := s.conn(ctx).ExecContext(ctx, `INSERT INTO automation_settings (tenant_id, expiry_enabled, expiry_days_before,
		holiday_enabled, birthday_enabled, campaigns_enabled, daily_report_enabled, daily_report_phone)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?)
		ON DUPLICATE KEY UPDATE expiry_enabled = VALUES(expiry_enabled), expiry_days_before = VALUES(expiry_days_before),
		holiday_enabled = VALUES(holiday_enabled), birthday_enabled = VALUES(birthday_enabled),
		campaigns_enabled = VALUES(campaigns_enabled), daily_report_enabled = VALUES(daily_report_enabled),
		daily_report_phone = VALUES(daily_report_phone)`,
		tenantID, a.ExpiryEnabled, string(days), a.HolidayEnabled, a.BirthdayEnabled, a.CampaignsEnabled,
		a.DailyReportEnabled, a.DailyReportPhone)
	return err
}

// Notification dedupe

// ClaimNotification reserves a dedupe key. It returns claimed=false when the
// notification was already sent, is in flight, or failed too many times.
func (s *Store) ClaimNotification(ctx context.Context, tenantID, key, typ, phone string) (string, bool, error) {
	id := uuid.NewString()
	_, err := s.conn(ctx).ExecContext(ctx, `INSERT INTO notification_logs (id, tenant_id, dedupe_key, type, recipient_phone)
		VALUES (?, ?, ?, ?, ?)`, id, tenantID, key, typ, phone)
	if err == nil {
		return id, true, nil
	}
	if _, isConflict := mapErr(err, "").(*domain.ConflictError); !isConflict {
		return "", false, err
	}
	res, err := s.conn(ctx).ExecContext(ctx, `UPDATE notification_logs SET status = 'PENDING', attempts = attempts + 1,
		last_error = '' WHERE tenant_id = ? AND dedupe_key = ? AND status = 'FAILED' AND attempts < 3`, tenantID, key)
	if err != nil {
		return "", false, err
	}
	if n, _ := res.RowsAffected(); n != 1 {
		return "", false, nil
	}
	err = s.conn(ctx).QueryRowContext(ctx, `SELECT id FROM notification_logs WHERE tenant_id = ? AND dedupe_key = ?`,
		tenantID, key).Scan(&id)
	return id, err == nil, err
}

func (s *Store) FinishNotification(ctx context.Context, id, status, errMsg string) error {
	if len(errMsg) > 500 {
		errMsg = errMsg[:500]
	}
	_, err := s.conn(ctx).ExecContext(ctx, `UPDATE notification_logs SET status = ?, last_error = ? WHERE id = ?`, status, errMsg, id)
	return err
}

// SettledKeys returns which of keys can no longer be sent (sent, in flight,
// skipped, or failed with no retries left).
func (s *Store) SettledKeys(ctx context.Context, tenantID string, keys []string) (map[string]bool, error) {
	out := map[string]bool{}
	if len(keys) == 0 {
		return out, nil
	}
	args := []any{tenantID}
	for _, k := range keys {
		args = append(args, k)
	}
	rows, err := s.conn(ctx).QueryContext(ctx, `SELECT dedupe_key FROM notification_logs WHERE tenant_id = ?
		AND dedupe_key IN (`+placeholders(len(keys))+`) AND (status <> 'FAILED' OR attempts >= 3)`, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var k string
		if err := rows.Scan(&k); err != nil {
			return nil, err
		}
		out[k] = true
	}
	return out, rows.Err()
}
