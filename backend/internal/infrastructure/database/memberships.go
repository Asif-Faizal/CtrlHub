package database

import (
	"context"
	"database/sql"
	"encoding/json"
	"time"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

// notRenewed excludes memberships that already have a later membership.
const notRenewed = ` AND NOT EXISTS (SELECT 1 FROM memberships y WHERE y.tenant_id = ms.tenant_id
	AND y.member_id = ms.member_id AND y.status = 'ACTIVE' AND y.end_date > ms.end_date)`

const membershipSelect = `SELECT ms.id, ms.tenant_id, ms.member_id, mb.full_name, ms.plan_id, ms.plan_name,
	ms.start_date, ms.end_date, ms.total_amount_minor,
	COALESCE((SELECT SUM(p.amount_minor) FROM payments p WHERE p.tenant_id = ms.tenant_id AND p.membership_id = ms.id), 0),
	ms.status, ms.renewed_from_id, ms.notes, ms.created_at
	FROM memberships ms JOIN members mb ON mb.tenant_id = ms.tenant_id AND mb.id = ms.member_id`

func scanMembership(sc scanner, m *domain.Membership, today domain.Date) error {
	var status string
	var renewed sql.NullString
	if err := sc.Scan(&m.ID, &m.TenantID, &m.MemberID, &m.MemberName, &m.PlanID, &m.PlanName, &m.StartDate,
		&m.EndDate, &m.TotalAmountMinor, &m.PaidAmountMinor, &status, &renewed, &m.Notes, &m.CreatedAt); err != nil {
		return err
	}
	m.Cancelled = status == "CANCELLED"
	m.RenewedFromID = nullStringPtr(renewed)
	m.Derive(today)
	return nil
}

func (s *Store) CreateMembership(ctx context.Context, m *domain.Membership, createdBy string) error {
	_, err := s.conn(ctx).ExecContext(ctx, `INSERT INTO memberships (id, tenant_id, member_id, plan_id, plan_name,
		start_date, end_date, total_amount_minor, status, renewed_from_id, notes, created_by)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE', ?, ?, ?)`,
		m.ID, m.TenantID, m.MemberID, m.PlanID, m.PlanName, m.StartDate, m.EndDate, m.TotalAmountMinor,
		m.RenewedFromID, m.Notes, createdBy)
	return mapErr(err, "")
}

func (s *Store) GetMembership(ctx context.Context, tenantID, id string, today domain.Date) (domain.Membership, error) {
	var m domain.Membership
	err := scanMembership(s.conn(ctx).QueryRowContext(ctx, membershipSelect+` WHERE ms.tenant_id = ? AND ms.id = ?`,
		tenantID, id), &m, today)
	return m, mapErr(err, "")
}

// LockMembership takes a row lock so concurrent payments cannot overpay.
func (s *Store) LockMembership(ctx context.Context, tenantID, id string) error {
	var x string
	return mapErr(s.conn(ctx).QueryRowContext(ctx, `SELECT id FROM memberships WHERE tenant_id = ? AND id = ? FOR UPDATE`,
		tenantID, id).Scan(&x), "")
}

// LatestMembershipEnd returns the latest non-cancelled end date for a member.
func (s *Store) LatestMembershipEnd(ctx context.Context, tenantID, memberID string) (domain.NullDate, error) {
	var d domain.NullDate
	err := s.conn(ctx).QueryRowContext(ctx, `SELECT MAX(end_date) FROM memberships WHERE tenant_id = ? AND member_id = ?
		AND status = 'ACTIVE'`, tenantID, memberID).Scan(&d)
	return d, err
}

type MembershipFilter = domain.MembershipFilter

func (s *Store) ListMemberships(ctx context.Context, tenantID string, f MembershipFilter) (domain.Page[domain.Membership], error) {
	where := ` WHERE ms.tenant_id = ?`
	args := []any{tenantID}
	if f.MemberID != "" {
		where += ` AND ms.member_id = ?`
		args = append(args, f.MemberID)
	}
	switch f.View {
	case "active":
		where += ` AND ms.status = 'ACTIVE' AND ms.start_date <= ? AND ms.end_date >= ?`
		args = append(args, f.Today, f.Today)
	case "expiring":
		where += ` AND ms.status = 'ACTIVE' AND ms.end_date BETWEEN ? AND ?` + notRenewed
		args = append(args, f.Today, f.Today.AddDays(f.Days))
	case "expired":
		where += ` AND ms.status = 'ACTIVE' AND ms.end_date < ? AND ms.end_date >= ?` + notRenewed
		args = append(args, f.Today, f.Today.AddDays(-f.Days))
	}
	out := domain.Page[domain.Membership]{Items: []domain.Membership{}, Page: f.Page, PageSize: f.PageSize}
	if err := s.conn(ctx).QueryRowContext(ctx, `SELECT COUNT(*) FROM memberships ms`+where, args...).Scan(&out.Total); err != nil {
		return out, err
	}
	order := ` ORDER BY ms.end_date DESC`
	if f.View == "expiring" {
		order = ` ORDER BY ms.end_date ASC`
	}
	rows, err := s.conn(ctx).QueryContext(ctx, membershipSelect+where+order+` LIMIT ? OFFSET ?`,
		append(args, f.PageSize, (f.Page-1)*f.PageSize)...)
	if err != nil {
		return out, err
	}
	defer rows.Close()
	for rows.Next() {
		var m domain.Membership
		if err := scanMembership(rows, &m, f.Today); err != nil {
			return out, err
		}
		out.Items = append(out.Items, m)
	}
	return out, rows.Err()
}

func (s *Store) CancelMembership(ctx context.Context, tenantID, id string) error {
	return affected(s.conn(ctx).ExecContext(ctx, `UPDATE memberships SET status = 'CANCELLED'
		WHERE tenant_id = ? AND id = ? AND status = 'ACTIVE'`, tenantID, id))
}

// Payments

func (s *Store) CreatePayment(ctx context.Context, p *domain.Payment) error {
	_, err := s.conn(ctx).ExecContext(ctx, `INSERT INTO payments (id, tenant_id, member_id, membership_id,
		amount_minor, method, reference, notes, paid_at, recorded_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		p.ID, p.TenantID, p.MemberID, p.MembershipID, p.AmountMinor, p.Method, p.Reference, p.Notes, p.PaidAt, p.RecordedBy)
	return mapErr(err, "")
}

type PaymentFilter = domain.PaymentFilter

func (s *Store) ListPayments(ctx context.Context, tenantID string, f PaymentFilter) (domain.Page[domain.Payment], error) {
	where := ` WHERE p.tenant_id = ?`
	args := []any{tenantID}
	if f.MemberID != "" {
		where += ` AND p.member_id = ?`
		args = append(args, f.MemberID)
	}
	if f.From != nil {
		where += ` AND p.paid_at >= ?`
		args = append(args, *f.From)
	}
	if f.To != nil {
		where += ` AND p.paid_at < ?`
		args = append(args, *f.To)
	}
	out := domain.Page[domain.Payment]{Items: []domain.Payment{}, Page: f.Page, PageSize: f.PageSize}
	if err := s.conn(ctx).QueryRowContext(ctx, `SELECT COUNT(*) FROM payments p`+where, args...).Scan(&out.Total); err != nil {
		return out, err
	}
	rows, err := s.conn(ctx).QueryContext(ctx, `SELECT p.id, p.tenant_id, p.member_id, mb.full_name, p.membership_id,
		p.amount_minor, p.method, p.reference, p.notes, p.paid_at, p.recorded_by, p.created_at
		FROM payments p JOIN members mb ON mb.tenant_id = p.tenant_id AND mb.id = p.member_id`+where+
		` ORDER BY p.paid_at DESC LIMIT ? OFFSET ?`, append(args, f.PageSize, (f.Page-1)*f.PageSize)...)
	if err != nil {
		return out, err
	}
	defer rows.Close()
	for rows.Next() {
		var p domain.Payment
		var msID, by sql.NullString
		if err := rows.Scan(&p.ID, &p.TenantID, &p.MemberID, &p.MemberName, &msID, &p.AmountMinor, &p.Method,
			&p.Reference, &p.Notes, &p.PaidAt, &by, &p.CreatedAt); err != nil {
			return out, err
		}
		p.MembershipID, p.RecordedBy = nullStringPtr(msID), nullStringPtr(by)
		out.Items = append(out.Items, p)
	}
	return out, rows.Err()
}

// Attendance

func (s *Store) CreateAttendance(ctx context.Context, a *domain.Attendance) error {
	_, err := s.conn(ctx).ExecContext(ctx, `INSERT INTO attendance (id, tenant_id, member_id, attendance_date,
		check_in_at, recorded_by) VALUES (?, ?, ?, ?, ?, ?)`,
		a.ID, a.TenantID, a.MemberID, a.AttendanceDate, a.CheckInAt, a.RecordedBy)
	return mapErr(err, "attendance already recorded for this member today")
}

func (s *Store) ListAttendance(ctx context.Context, tenantID string, date *domain.Date, memberID string, limit int) ([]domain.Attendance, error) {
	where, args := ` WHERE a.tenant_id = ?`, []any{tenantID}
	if date != nil {
		where += ` AND a.attendance_date = ?`
		args = append(args, *date)
	}
	if memberID != "" {
		where += ` AND a.member_id = ?`
		args = append(args, memberID)
	}
	rows, err := s.conn(ctx).QueryContext(ctx, `SELECT a.id, a.tenant_id, a.member_id, mb.full_name, a.attendance_date,
		a.check_in_at, a.recorded_by FROM attendance a
		JOIN members mb ON mb.tenant_id = a.tenant_id AND mb.id = a.member_id`+where+
		` ORDER BY a.check_in_at DESC LIMIT ?`, append(args, limit)...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.Attendance{}
	for rows.Next() {
		var a domain.Attendance
		var by sql.NullString
		if err := rows.Scan(&a.ID, &a.TenantID, &a.MemberID, &a.MemberName, &a.AttendanceDate, &a.CheckInAt, &by); err != nil {
			return nil, err
		}
		a.RecordedBy = nullStringPtr(by)
		out = append(out, a)
	}
	return out, rows.Err()
}

// Holidays

func scanHoliday(sc scanner, h *domain.Holiday) error {
	var days []byte
	if err := sc.Scan(&h.ID, &h.TenantID, &h.Title, &h.Description, &h.HolidayDate, &h.NotifyEnabled, &days,
		&h.CreatedAt, &h.UpdatedAt); err != nil {
		return err
	}
	h.NotifyDaysBefore = []int{}
	_ = json.Unmarshal(days, &h.NotifyDaysBefore)
	return nil
}

const holidayCols = `id, tenant_id, title, description, holiday_date, notify_enabled, notify_days_before, created_at, updated_at`

func (s *Store) CreateHoliday(ctx context.Context, h *domain.Holiday, createdBy string) error {
	days, _ := json.Marshal(h.NotifyDaysBefore)
	_, err := s.conn(ctx).ExecContext(ctx, `INSERT INTO holidays (id, tenant_id, title, description, holiday_date,
		notify_enabled, notify_days_before, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
		h.ID, h.TenantID, h.Title, h.Description, h.HolidayDate, h.NotifyEnabled, string(days), createdBy)
	return mapErr(err, "")
}

func (s *Store) UpdateHoliday(ctx context.Context, h domain.Holiday) error {
	days, _ := json.Marshal(h.NotifyDaysBefore)
	_, err := s.conn(ctx).ExecContext(ctx, `UPDATE holidays SET title = ?, description = ?, holiday_date = ?,
		notify_enabled = ?, notify_days_before = ? WHERE tenant_id = ? AND id = ?`,
		h.Title, h.Description, h.HolidayDate, h.NotifyEnabled, string(days), h.TenantID, h.ID)
	return mapErr(err, "")
}

func (s *Store) DeleteHoliday(ctx context.Context, tenantID, id string) error {
	return affected(s.conn(ctx).ExecContext(ctx, `DELETE FROM holidays WHERE tenant_id = ? AND id = ?`, tenantID, id))
}

func (s *Store) GetHoliday(ctx context.Context, tenantID, id string) (domain.Holiday, error) {
	var h domain.Holiday
	err := scanHoliday(s.conn(ctx).QueryRowContext(ctx, `SELECT `+holidayCols+` FROM holidays WHERE tenant_id = ? AND id = ?`,
		tenantID, id), &h)
	return h, mapErr(err, "")
}

// ListHolidays returns holidays on or after from (all when from is nil).
func (s *Store) ListHolidays(ctx context.Context, tenantID string, from, to *domain.Date) ([]domain.Holiday, error) {
	q, args := `SELECT `+holidayCols+` FROM holidays WHERE tenant_id = ?`, []any{tenantID}
	if from != nil {
		q += ` AND holiday_date >= ?`
		args = append(args, *from)
	}
	if to != nil {
		q += ` AND holiday_date <= ?`
		args = append(args, *to)
	}
	rows, err := s.conn(ctx).QueryContext(ctx, q+` ORDER BY holiday_date`, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.Holiday{}
	for rows.Next() {
		var h domain.Holiday
		if err := scanHoliday(rows, &h); err != nil {
			return nil, err
		}
		out = append(out, h)
	}
	return out, rows.Err()
}

// Reports

func (s *Store) DailyReport(ctx context.Context, tenantID string, d domain.Date, dayStart, dayEnd time.Time) (domain.DailyReport, error) {
	r := domain.DailyReport{Date: d}
	err := s.conn(ctx).QueryRowContext(ctx, `SELECT
		(SELECT COUNT(DISTINCT member_id) FROM memberships WHERE tenant_id = ? AND status = 'ACTIVE' AND start_date <= ? AND end_date >= ?),
		(SELECT COUNT(*) FROM members WHERE tenant_id = ? AND joined_on = ?),
		(SELECT COUNT(*) FROM memberships ms WHERE ms.tenant_id = ? AND ms.status = 'ACTIVE' AND ms.end_date BETWEEN ? AND ?`+notRenewed+`),
		(SELECT COUNT(*) FROM memberships ms WHERE ms.tenant_id = ? AND ms.status = 'ACTIVE' AND ms.end_date = ?`+notRenewed+`),
		(SELECT COUNT(*) FROM memberships WHERE tenant_id = ? AND renewed_from_id IS NOT NULL AND created_at >= ? AND created_at < ?),
		(SELECT COALESCE(SUM(GREATEST(ms.total_amount_minor - COALESCE(
			(SELECT SUM(p.amount_minor) FROM payments p WHERE p.tenant_id = ms.tenant_id AND p.membership_id = ms.id), 0), 0)), 0)
			FROM memberships ms WHERE ms.tenant_id = ? AND ms.status = 'ACTIVE'),
		(SELECT COALESCE(SUM(amount_minor), 0) FROM payments WHERE tenant_id = ? AND paid_at >= ? AND paid_at < ?),
		(SELECT COUNT(*) FROM attendance WHERE tenant_id = ? AND attendance_date = ?)`,
		tenantID, d, d,
		tenantID, d,
		tenantID, d, d.AddDays(7),
		tenantID, d.AddDays(-1),
		tenantID, dayStart, dayEnd,
		tenantID,
		tenantID, dayStart, dayEnd,
		tenantID, d,
	).Scan(&r.ActiveMembers, &r.NewMembers, &r.ExpiringNext7Days, &r.ExpiredToday, &r.Renewals,
		&r.PendingPaymentsMinor, &r.RevenueMinor, &r.Attendance)
	return r, err
}
