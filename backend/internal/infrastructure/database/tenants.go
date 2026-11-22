package database

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

const tenantCols = `t.id, t.code, t.name, t.owner_name, t.contact_number, t.email, t.address, t.city,
	t.state, t.country, t.timezone, t.currency, t.opening_hours, t.status, t.max_users,
	t.whatsapp_enabled, t.created_at, t.updated_at`

func scanTenant(sc scanner, t *domain.Tenant, extra ...any) error {
	var hours []byte
	dest := []any{&t.ID, &t.Code, &t.Name, &t.OwnerName, &t.ContactNumber, &t.Email, &t.Address, &t.City,
		&t.State, &t.Country, &t.Timezone, &t.Currency, &hours, &t.Status, &t.MaxUsers,
		&t.WhatsAppEnabled, &t.CreatedAt, &t.UpdatedAt}
	if err := sc.Scan(append(dest, extra...)...); err != nil {
		return err
	}
	if len(hours) > 0 {
		t.OpeningHours = json.RawMessage(hours)
	}
	return nil
}

func jsonOrNil(raw json.RawMessage) any {
	if len(raw) == 0 || string(raw) == "null" {
		return nil
	}
	return string(raw)
}

// CreateTenant inserts the tenant and assigns its sequential code (gym_001, ...).
func (s *Store) CreateTenant(ctx context.Context, t *domain.Tenant) error {
	q := s.conn(ctx)
	res, err := q.ExecContext(ctx, `INSERT INTO tenants (id, code, name, owner_name, contact_number, email,
		address, city, state, country, timezone, currency, opening_hours, status, max_users, whatsapp_enabled)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		t.ID, t.ID, t.Name, t.OwnerName, t.ContactNumber, t.Email, t.Address, t.City, t.State, t.Country,
		t.Timezone, t.Currency, jsonOrNil(t.OpeningHours), t.Status, t.MaxUsers, t.WhatsAppEnabled)
	if err != nil {
		return mapErr(err, "tenant already exists")
	}
	seq, err := res.LastInsertId()
	if err != nil {
		return err
	}
	t.Code = fmt.Sprintf("gym_%03d", seq)
	if _, err := q.ExecContext(ctx, `UPDATE tenants SET code = ? WHERE id = ?`, t.Code, t.ID); err != nil {
		return mapErr(err, "tenant code already exists")
	}
	return nil
}

// InitTenantDefaults creates the per-tenant WhatsApp mapping, messaging
// preferences and automation settings rows.
func (s *Store) InitTenantDefaults(ctx context.Context, tenantID, sessionName string) error {
	q := s.conn(ctx)
	if _, err := q.ExecContext(ctx, `INSERT INTO whatsapp_sessions (id, tenant_id, session_name, status)
		VALUES (?, ?, ?, ?)`, uuid.NewString(), tenantID, sessionName, domain.SessionNotConnected); err != nil {
		return mapErr(err, "whatsapp session already exists")
	}
	p := domain.DefaultMessagingPreferences
	if _, err := q.ExecContext(ctx, `INSERT INTO messaging_preferences (tenant_id, expiry_template, holiday_template,
		birthday_template, daily_message_limit) VALUES (?, ?, ?, ?, ?)`,
		tenantID, p.ExpiryTemplate, p.HolidayTemplate, p.BirthdayTemplate, p.DailyMessageLimit); err != nil {
		return err
	}
	days, _ := json.Marshal(domain.DefaultExpiryDaysBefore)
	_, err := q.ExecContext(ctx, `INSERT INTO automation_settings (tenant_id, expiry_days_before) VALUES (?, ?)`,
		tenantID, string(days))
	return err
}

func (s *Store) GetTenant(ctx context.Context, id string) (domain.Tenant, error) {
	var t domain.Tenant
	err := scanTenant(s.conn(ctx).QueryRowContext(ctx, `SELECT `+tenantCols+` FROM tenants t WHERE t.id = ?`, id), &t)
	return t, mapErr(err, "")
}

func (s *Store) ListTenants(ctx context.Context, search, status string, page, size int) (domain.Page[domain.TenantSummary], error) {
	where := ` WHERE 1=1`
	var args []any
	if search != "" {
		where += ` AND (t.name LIKE ? OR t.code LIKE ? OR t.city LIKE ? OR t.email LIKE ?)`
		l := likeArg(search)
		args = append(args, l, l, l, l)
	}
	if status != "" {
		where += ` AND t.status = ?`
		args = append(args, status)
	}
	out := domain.Page[domain.TenantSummary]{Items: []domain.TenantSummary{}, Page: page, PageSize: size}
	if err := s.conn(ctx).QueryRowContext(ctx, `SELECT COUNT(*) FROM tenants t`+where, args...).Scan(&out.Total); err != nil {
		return out, err
	}
	rows, err := s.conn(ctx).QueryContext(ctx, `SELECT `+tenantCols+`,
		(SELECT COUNT(*) FROM tenant_users tu WHERE tu.tenant_id = t.id),
		(SELECT COUNT(*) FROM members m WHERE m.tenant_id = t.id),
		COALESCE(ws.status, 'NOT_CONNECTED')
		FROM tenants t LEFT JOIN whatsapp_sessions ws ON ws.tenant_id = t.id`+where+
		` ORDER BY t.created_at DESC LIMIT ? OFFSET ?`, append(args, size, (page-1)*size)...)
	if err != nil {
		return out, err
	}
	defer rows.Close()
	for rows.Next() {
		var ts domain.TenantSummary
		if err := scanTenant(rows, &ts.Tenant, &ts.UserCount, &ts.MemberCount, &ts.WhatsAppStatus); err != nil {
			return out, err
		}
		out.Items = append(out.Items, ts)
	}
	return out, rows.Err()
}

func (s *Store) UpdateTenant(ctx context.Context, t domain.Tenant) error {
	_, err := s.conn(ctx).ExecContext(ctx, `UPDATE tenants SET name = ?, owner_name = ?, contact_number = ?,
		email = ?, address = ?, city = ?, state = ?, country = ?, timezone = ?, currency = ?, opening_hours = ?,
		max_users = ?, whatsapp_enabled = ? WHERE id = ?`,
		t.Name, t.OwnerName, t.ContactNumber, t.Email, t.Address, t.City, t.State, t.Country, t.Timezone,
		t.Currency, jsonOrNil(t.OpeningHours), t.MaxUsers, t.WhatsAppEnabled, t.ID)
	return mapErr(err, "")
}

func (s *Store) SetTenantStatus(ctx context.Context, id string, status domain.TenantStatus) error {
	return affected(s.conn(ctx).ExecContext(ctx, `UPDATE tenants SET status = ? WHERE id = ?`, status, id))
}

func (s *Store) PlatformStats(ctx context.Context) (domain.PlatformStats, error) {
	var st domain.PlatformStats
	err := s.conn(ctx).QueryRowContext(ctx, `SELECT
		(SELECT COUNT(*) FROM tenants),
		(SELECT COUNT(*) FROM tenants WHERE status = 'ACTIVE'),
		(SELECT COUNT(*) FROM users WHERE is_platform_admin = FALSE),
		(SELECT COUNT(*) FROM members),
		(SELECT COUNT(*) FROM whatsapp_sessions WHERE status = 'WORKING'),
		(SELECT COUNT(*) FROM message_logs WHERE status = 'SENT' AND created_at >= ?)`,
		time.Now().UTC().AddDate(0, 0, -30)).Scan(&st.TotalTenants, &st.ActiveTenants, &st.TotalUsers,
		&st.TotalMembers, &st.WhatsAppConnected, &st.MessagesLast30Days)
	return st, err
}

func (s *Store) InsertAudit(ctx context.Context, e domain.AuditEntry) error {
	var meta any
	if len(e.Metadata) > 0 {
		meta = string(e.Metadata)
	}
	_, err := s.conn(ctx).ExecContext(ctx, `INSERT INTO audit_logs (id, tenant_id, actor_user_id, action,
		entity_type, entity_id, metadata, ip) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
		uuid.NewString(), e.TenantID, e.ActorUserID, e.Action, e.EntityType, e.EntityID, meta, e.IP)
	return err
}

func (s *Store) ListAudit(ctx context.Context, tenantID string, limit int) ([]domain.AuditEntry, error) {
	where, args := "", []any{}
	if tenantID != "" {
		where = ` WHERE tenant_id = ?`
		args = append(args, tenantID)
	}
	rows, err := s.conn(ctx).QueryContext(ctx, `SELECT id, tenant_id, actor_user_id, action, entity_type,
		entity_id, metadata, ip, created_at FROM audit_logs`+where+` ORDER BY created_at DESC LIMIT ?`, append(args, limit)...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.AuditEntry{}
	for rows.Next() {
		var e domain.AuditEntry
		var tid, actor []byte
		var meta []byte
		if err := rows.Scan(&e.ID, &tid, &actor, &e.Action, &e.EntityType, &e.EntityID, &meta, &e.IP, &e.CreatedAt); err != nil {
			return nil, err
		}
		if tid != nil {
			s := string(tid)
			e.TenantID = &s
		}
		if actor != nil {
			s := string(actor)
			e.ActorUserID = &s
		}
		if meta != nil {
			e.Metadata = json.RawMessage(meta)
		}
		out = append(out, e)
	}
	return out, rows.Err()
}
