package database

import (
	"context"
	"database/sql"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

// Every query in this file is scoped by tenant_id.

const memberCols = `m.id, m.tenant_id, m.full_name, m.phone, m.email, m.gender, m.date_of_birth, m.address,
	m.emergency_contact, COALESCE(m.notes, ''), m.joined_on, m.status, m.whatsapp_opt_in, m.marketing_opt_in,
	m.created_at, m.updated_at`

// memberStateCols needs (today, today) args and derives the membership summary.
const memberStateCols = `,
	EXISTS(SELECT 1 FROM memberships x WHERE x.tenant_id = m.tenant_id AND x.member_id = m.id
		AND x.status = 'ACTIVE' AND x.start_date <= ? AND x.end_date >= ?) AS is_active,
	(SELECT MAX(x.end_date) FROM memberships x WHERE x.tenant_id = m.tenant_id AND x.member_id = m.id
		AND x.status = 'ACTIVE') AS max_end,
	COALESCE((SELECT x.plan_name FROM memberships x WHERE x.tenant_id = m.tenant_id AND x.member_id = m.id
		AND x.status = 'ACTIVE' ORDER BY x.end_date DESC LIMIT 1), '') AS plan_name`

func scanMember(sc scanner, m *domain.Member, today domain.Date, withState bool) error {
	dest := []any{&m.ID, &m.TenantID, &m.FullName, &m.Phone, &m.Email, &m.Gender, &m.DateOfBirth, &m.Address,
		&m.EmergencyContact, &m.Notes, &m.JoinedOn, &m.Status, &m.WhatsAppOptIn, &m.MarketingOptIn,
		&m.CreatedAt, &m.UpdatedAt}
	var isActive bool
	var maxEnd domain.NullDate
	if withState {
		dest = append(dest, &isActive, &maxEnd, &m.CurrentPlan)
	}
	if err := sc.Scan(dest...); err != nil {
		return err
	}
	if withState {
		m.ExpiresOn = maxEnd
		switch {
		case isActive:
			m.MembershipState = domain.MembershipActive
		case !maxEnd.Valid:
			m.MembershipState = domain.MembershipNone
		case maxEnd.Date.Before(today):
			m.MembershipState = domain.MembershipExpired
		default:
			m.MembershipState = domain.MembershipUpcoming
		}
	}
	return nil
}

func (s *Store) CreateMember(ctx context.Context, m *domain.Member) error {
	_, err := s.conn(ctx).ExecContext(ctx, `INSERT INTO members (id, tenant_id, full_name, phone, email, gender,
		date_of_birth, address, emergency_contact, notes, joined_on, status, whatsapp_opt_in, marketing_opt_in,
		consent_updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, UTC_TIMESTAMP(3))`,
		m.ID, m.TenantID, m.FullName, m.Phone, m.Email, m.Gender, m.DateOfBirth, m.Address, m.EmergencyContact,
		m.Notes, m.JoinedOn, m.Status, m.WhatsAppOptIn, m.MarketingOptIn)
	return mapErr(err, "a member with this phone number already exists")
}

func (s *Store) UpdateMember(ctx context.Context, m domain.Member) error {
	_, err := s.conn(ctx).ExecContext(ctx, `UPDATE members SET full_name = ?, phone = ?, email = ?, gender = ?,
		date_of_birth = ?, address = ?, emergency_contact = ?, notes = ?, joined_on = ?, status = ?,
		consent_updated_at = IF(whatsapp_opt_in <> ? OR marketing_opt_in <> ?, UTC_TIMESTAMP(3), consent_updated_at),
		whatsapp_opt_in = ?, marketing_opt_in = ?
		WHERE tenant_id = ? AND id = ?`,
		m.FullName, m.Phone, m.Email, m.Gender, m.DateOfBirth, m.Address, m.EmergencyContact, m.Notes, m.JoinedOn,
		m.Status, m.WhatsAppOptIn, m.MarketingOptIn, m.WhatsAppOptIn, m.MarketingOptIn, m.TenantID, m.ID)
	return mapErr(err, "a member with this phone number already exists")
}

func (s *Store) GetMember(ctx context.Context, tenantID, id string, today domain.Date) (domain.Member, error) {
	var m domain.Member
	err := scanMember(s.conn(ctx).QueryRowContext(ctx, `SELECT `+memberCols+memberStateCols+`
		FROM members m WHERE m.tenant_id = ? AND m.id = ?`, today, today, tenantID, id), &m, today, true)
	return m, mapErr(err, "")
}

func (s *Store) ListMembers(ctx context.Context, tenantID string, f domain.MemberFilter) (domain.Page[domain.Member], error) {
	where := ` WHERE m.tenant_id = ?`
	args := []any{tenantID}
	if f.Search != "" {
		l := likeArg(f.Search)
		where += ` AND (m.full_name LIKE ? OR m.phone LIKE ? OR m.email LIKE ?)`
		args = append(args, l, l, l)
	}
	const anyMs = `EXISTS(SELECT 1 FROM memberships x WHERE x.tenant_id = m.tenant_id AND x.member_id = m.id AND x.status = 'ACTIVE'`
	switch f.Status {
	case "active":
		where += ` AND ` + anyMs + ` AND x.start_date <= ? AND x.end_date >= ?)`
		args = append(args, f.Today, f.Today)
	case "expired":
		where += ` AND ` + anyMs + `) AND NOT ` + anyMs + ` AND x.end_date >= ?)`
		args = append(args, f.Today)
	case "none":
		where += ` AND NOT ` + anyMs + `)`
	}
	out := domain.Page[domain.Member]{Items: []domain.Member{}, Page: f.Page, PageSize: f.PageSize}
	if err := s.conn(ctx).QueryRowContext(ctx, `SELECT COUNT(*) FROM members m`+where, args...).Scan(&out.Total); err != nil {
		return out, err
	}
	qargs := append([]any{f.Today, f.Today}, args...)
	qargs = append(qargs, f.PageSize, (f.Page-1)*f.PageSize)
	rows, err := s.conn(ctx).QueryContext(ctx, `SELECT `+memberCols+memberStateCols+` FROM members m`+where+
		` ORDER BY m.full_name LIMIT ? OFFSET ?`, qargs...)
	if err != nil {
		return out, err
	}
	defer rows.Close()
	for rows.Next() {
		var m domain.Member
		if err := scanMember(rows, &m, f.Today, true); err != nil {
			return out, err
		}
		out.Items = append(out.Items, m)
	}
	return out, rows.Err()
}

// Membership plans

const planCols = `id, tenant_id, name, description, duration_type, duration_days, price_minor, is_active, created_at, updated_at`

func scanPlan(sc scanner, p *domain.MembershipPlan) error {
	var days sql.NullInt64
	if err := sc.Scan(&p.ID, &p.TenantID, &p.Name, &p.Description, &p.DurationType, &days, &p.PriceMinor,
		&p.IsActive, &p.CreatedAt, &p.UpdatedAt); err != nil {
		return err
	}
	if days.Valid {
		d := int(days.Int64)
		p.DurationDays = &d
	}
	return nil
}

func (s *Store) CreatePlan(ctx context.Context, p *domain.MembershipPlan) error {
	_, err := s.conn(ctx).ExecContext(ctx, `INSERT INTO membership_plans (id, tenant_id, name, description,
		duration_type, duration_days, price_minor, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
		p.ID, p.TenantID, p.Name, p.Description, p.DurationType, p.DurationDays, p.PriceMinor, p.IsActive)
	return mapErr(err, "a plan with this name already exists")
}

func (s *Store) UpdatePlan(ctx context.Context, p domain.MembershipPlan) error {
	_, err := s.conn(ctx).ExecContext(ctx, `UPDATE membership_plans SET name = ?, description = ?, duration_type = ?,
		duration_days = ?, price_minor = ?, is_active = ? WHERE tenant_id = ? AND id = ?`,
		p.Name, p.Description, p.DurationType, p.DurationDays, p.PriceMinor, p.IsActive, p.TenantID, p.ID)
	return mapErr(err, "a plan with this name already exists")
}

func (s *Store) GetPlan(ctx context.Context, tenantID, id string) (domain.MembershipPlan, error) {
	var p domain.MembershipPlan
	err := scanPlan(s.conn(ctx).QueryRowContext(ctx, `SELECT `+planCols+` FROM membership_plans
		WHERE tenant_id = ? AND id = ?`, tenantID, id), &p)
	return p, mapErr(err, "")
}

func (s *Store) ListPlans(ctx context.Context, tenantID string, activeOnly bool) ([]domain.MembershipPlan, error) {
	q := `SELECT ` + planCols + ` FROM membership_plans WHERE tenant_id = ?`
	if activeOnly {
		q += ` AND is_active = TRUE`
	}
	rows, err := s.conn(ctx).QueryContext(ctx, q+` ORDER BY price_minor`, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.MembershipPlan{}
	for rows.Next() {
		var p domain.MembershipPlan
		if err := scanPlan(rows, &p); err != nil {
			return nil, err
		}
		out = append(out, p)
	}
	return out, rows.Err()
}

// Leads

const leadCols = `id, tenant_id, full_name, phone, email, source, status, whatsapp_opt_in, marketing_opt_in, notes, created_at, updated_at`

func scanLead(sc scanner, l *domain.Lead) error {
	return sc.Scan(&l.ID, &l.TenantID, &l.FullName, &l.Phone, &l.Email, &l.Source, &l.Status, &l.WhatsAppOptIn,
		&l.MarketingOptIn, &l.Notes, &l.CreatedAt, &l.UpdatedAt)
}

func (s *Store) CreateLead(ctx context.Context, l *domain.Lead) error {
	_, err := s.conn(ctx).ExecContext(ctx, `INSERT INTO leads (id, tenant_id, full_name, phone, email, source, status,
		whatsapp_opt_in, marketing_opt_in, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		l.ID, l.TenantID, l.FullName, l.Phone, l.Email, l.Source, l.Status, l.WhatsAppOptIn, l.MarketingOptIn, l.Notes)
	return mapErr(err, "a lead with this phone number already exists")
}

func (s *Store) UpdateLead(ctx context.Context, l domain.Lead) error {
	_, err := s.conn(ctx).ExecContext(ctx, `UPDATE leads SET full_name = ?, phone = ?, email = ?, source = ?, status = ?,
		whatsapp_opt_in = ?, marketing_opt_in = ?, notes = ? WHERE tenant_id = ? AND id = ?`,
		l.FullName, l.Phone, l.Email, l.Source, l.Status, l.WhatsAppOptIn, l.MarketingOptIn, l.Notes, l.TenantID, l.ID)
	return mapErr(err, "a lead with this phone number already exists")
}

func (s *Store) GetLead(ctx context.Context, tenantID, id string) (domain.Lead, error) {
	var l domain.Lead
	err := scanLead(s.conn(ctx).QueryRowContext(ctx, `SELECT `+leadCols+` FROM leads WHERE tenant_id = ? AND id = ?`, tenantID, id), &l)
	return l, mapErr(err, "")
}

func (s *Store) ListLeads(ctx context.Context, tenantID, status string) ([]domain.Lead, error) {
	q, args := `SELECT `+leadCols+` FROM leads WHERE tenant_id = ?`, []any{tenantID}
	if status != "" {
		q += ` AND status = ?`
		args = append(args, status)
	}
	rows, err := s.conn(ctx).QueryContext(ctx, q+` ORDER BY created_at DESC LIMIT 500`, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.Lead{}
	for rows.Next() {
		var l domain.Lead
		if err := scanLead(rows, &l); err != nil {
			return nil, err
		}
		out = append(out, l)
	}
	return out, rows.Err()
}
