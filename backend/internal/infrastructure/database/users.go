package database

import (
	"context"
	"database/sql"
	"time"

	"github.com/google/uuid"

	"github.com/Asif-Faizal/CtrlHub/backend/internal/domain"
)

const userCols = `u.id, u.name, u.email, u.phone, COALESCE(u.password_hash, ''), u.is_platform_admin,
	u.status, u.last_login_at, u.created_at, u.updated_at`

func scanUser(sc scanner, u *domain.User, extra ...any) error {
	var last sql.NullTime
	dest := []any{&u.ID, &u.Name, &u.Email, &u.Phone, &u.PasswordHash, &u.IsPlatformAdmin, &u.Status,
		&last, &u.CreatedAt, &u.UpdatedAt}
	if err := sc.Scan(append(dest, extra...)...); err != nil {
		return err
	}
	u.LastLoginAt = nullTimePtr(last)
	return nil
}

func (s *Store) CreateUser(ctx context.Context, u *domain.User) error {
	var hash any
	if u.PasswordHash != "" {
		hash = u.PasswordHash
	}
	_, err := s.conn(ctx).ExecContext(ctx, `INSERT INTO users (id, name, email, phone, password_hash,
		is_platform_admin, status) VALUES (?, ?, ?, ?, ?, ?, ?)`,
		u.ID, u.Name, u.Email, u.Phone, hash, u.IsPlatformAdmin, u.Status)
	return mapErr(err, "a user with this email already exists")
}

func (s *Store) GetUserByEmail(ctx context.Context, email string) (domain.User, error) {
	var u domain.User
	err := scanUser(s.conn(ctx).QueryRowContext(ctx, `SELECT `+userCols+` FROM users u WHERE u.email = ?`, email), &u)
	return u, mapErr(err, "")
}

func (s *Store) GetUserByID(ctx context.Context, id string) (domain.User, error) {
	var u domain.User
	err := scanUser(s.conn(ctx).QueryRowContext(ctx, `SELECT `+userCols+` FROM users u WHERE u.id = ?`, id), &u)
	return u, mapErr(err, "")
}

func (s *Store) PlatformAdminExists(ctx context.Context) (bool, error) {
	var n int
	err := s.conn(ctx).QueryRowContext(ctx, `SELECT COUNT(*) FROM users WHERE is_platform_admin = TRUE`).Scan(&n)
	return n > 0, err
}

func (s *Store) TouchLastLogin(ctx context.Context, userID string) error {
	_, err := s.conn(ctx).ExecContext(ctx, `UPDATE users SET last_login_at = ? WHERE id = ?`, time.Now().UTC(), userID)
	return err
}

func (s *Store) SetPassword(ctx context.Context, userID, hash string) error {
	return affected(s.conn(ctx).ExecContext(ctx, `UPDATE users SET password_hash = ?,
		status = IF(status = 'PENDING_SETUP', 'ACTIVE', status) WHERE id = ?`, hash, userID))
}

type PrincipalRecord = domain.PrincipalRecord

func (s *Store) LoadPrincipal(ctx context.Context, userID string) (PrincipalRecord, error) {
	var p PrincipalRecord
	var role, tenantStatus string
	err := s.conn(ctx).QueryRowContext(ctx, `SELECT u.id, u.name, u.email, u.status, u.is_platform_admin,
		COALESCE(tu.tenant_id, ''), COALESCE(r.name, ''), COALESCE(t.code, ''), COALESCE(t.name, ''),
		COALESCE(t.status, ''), COALESCE(t.timezone, 'UTC')
		FROM users u
		LEFT JOIN tenant_users tu ON tu.user_id = u.id
		LEFT JOIN roles r ON r.id = tu.role_id
		LEFT JOIN tenants t ON t.id = tu.tenant_id
		WHERE u.id = ?`, userID).Scan(&p.UserID, &p.Name, &p.Email, &p.UserStatus, &p.IsPlatformAdmin,
		&p.TenantID, &role, &p.TenantCode, &p.TenantName, &tenantStatus, &p.TenantTimezone)
	if err != nil {
		return p, mapErr(err, "")
	}
	p.TenantStatus = domain.TenantStatus(tenantStatus)
	if p.IsPlatformAdmin {
		p.Role = domain.RolePlatformAdmin
		p.TenantID = ""
	} else {
		p.Role = domain.Role(role)
	}
	return p, nil
}

func (s *Store) AddTenantUser(ctx context.Context, tenantID, userID string, role domain.Role, primary bool) error {
	_, err := s.conn(ctx).ExecContext(ctx, `INSERT INTO tenant_users (id, tenant_id, user_id, role_id, is_primary)
		VALUES (?, ?, ?, ?, ?)`, uuid.NewString(), tenantID, userID, role.ID(), primary)
	return mapErr(err, "user already belongs to a gym")
}

const tenantUserSelect = `SELECT ` + userCols + `, tu.tenant_id, r.name, tu.is_primary
	FROM tenant_users tu JOIN users u ON u.id = tu.user_id JOIN roles r ON r.id = tu.role_id`

func (s *Store) ListTenantUsers(ctx context.Context, tenantID string) ([]domain.TenantUser, error) {
	rows, err := s.conn(ctx).QueryContext(ctx, tenantUserSelect+` WHERE tu.tenant_id = ? ORDER BY tu.is_primary DESC, u.name`, tenantID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.TenantUser{}
	for rows.Next() {
		var tu domain.TenantUser
		if err := scanUser(rows, &tu.User, &tu.TenantID, &tu.Role, &tu.IsPrimary); err != nil {
			return nil, err
		}
		out = append(out, tu)
	}
	return out, rows.Err()
}

func (s *Store) GetTenantUser(ctx context.Context, tenantID, userID string) (domain.TenantUser, error) {
	var tu domain.TenantUser
	err := scanUser(s.conn(ctx).QueryRowContext(ctx, tenantUserSelect+` WHERE tu.tenant_id = ? AND tu.user_id = ?`,
		tenantID, userID), &tu.User, &tu.TenantID, &tu.Role, &tu.IsPrimary)
	return tu, mapErr(err, "")
}

// GetTenantUserByUserID finds a gym user's membership without knowing the tenant (platform admin use).
func (s *Store) GetTenantUserByUserID(ctx context.Context, userID string) (domain.TenantUser, error) {
	var tu domain.TenantUser
	err := scanUser(s.conn(ctx).QueryRowContext(ctx, tenantUserSelect+` WHERE tu.user_id = ?`, userID),
		&tu.User, &tu.TenantID, &tu.Role, &tu.IsPrimary)
	return tu, mapErr(err, "")
}

func (s *Store) CountTenantUsers(ctx context.Context, tenantID string) (int, error) {
	var n int
	err := s.conn(ctx).QueryRowContext(ctx, `SELECT COUNT(*) FROM tenant_users WHERE tenant_id = ?`, tenantID).Scan(&n)
	return n, err
}

func (s *Store) UpdateTenantUser(ctx context.Context, tenantID string, u domain.TenantUser) error {
	q := s.conn(ctx)
	if err := affected(q.ExecContext(ctx, `UPDATE tenant_users SET role_id = ? WHERE tenant_id = ? AND user_id = ?`,
		u.Role.ID(), tenantID, u.ID)); err != nil {
		// Zero rows affected also happens when nothing changed; confirm membership exists.
		if _, gerr := s.GetTenantUser(ctx, tenantID, u.ID); gerr != nil {
			return gerr
		}
	}
	_, err := q.ExecContext(ctx, `UPDATE users SET name = ?, phone = ?, status = ? WHERE id = ?`,
		u.Name, u.Phone, u.Status, u.ID)
	return err
}

// Refresh tokens

type RefreshToken = domain.RefreshToken

func (s *Store) InsertRefreshToken(ctx context.Context, id, userID, hash string, expires time.Time, ua, ip string) error {
	if len(ua) > 255 {
		ua = ua[:255]
	}
	_, err := s.conn(ctx).ExecContext(ctx, `INSERT INTO refresh_tokens (id, user_id, token_hash, expires_at, user_agent, ip)
		VALUES (?, ?, ?, ?, ?, ?)`, id, userID, hash, expires, ua, ip)
	return err
}

func (s *Store) GetRefreshToken(ctx context.Context, hash string) (RefreshToken, error) {
	var t RefreshToken
	var revoked sql.NullTime
	err := s.conn(ctx).QueryRowContext(ctx, `SELECT id, user_id, expires_at, revoked_at FROM refresh_tokens
		WHERE token_hash = ?`, hash).Scan(&t.ID, &t.UserID, &t.ExpiresAt, &revoked)
	t.RevokedAt = nullTimePtr(revoked)
	return t, mapErr(err, "")
}

// RevokeRefreshToken revokes a token only if it is still active, so two
// concurrent refreshes with the same token cannot both succeed.
func (s *Store) RevokeRefreshToken(ctx context.Context, id string, replacedBy *string) (bool, error) {
	res, err := s.conn(ctx).ExecContext(ctx, `UPDATE refresh_tokens SET revoked_at = ?, replaced_by = ?
		WHERE id = ? AND revoked_at IS NULL`, time.Now().UTC(), replacedBy, id)
	if err != nil {
		return false, err
	}
	n, err := res.RowsAffected()
	return n == 1, err
}

func (s *Store) RevokeAllRefreshTokens(ctx context.Context, userID string) error {
	_, err := s.conn(ctx).ExecContext(ctx, `UPDATE refresh_tokens SET revoked_at = ? WHERE user_id = ? AND revoked_at IS NULL`,
		time.Now().UTC(), userID)
	return err
}

// Password setup tokens

type SetupToken = domain.SetupToken

func (s *Store) InsertSetupToken(ctx context.Context, userID, hash, purpose string, expires time.Time, createdBy *string) error {
	q := s.conn(ctx)
	// Only the newest link stays valid.
	if _, err := q.ExecContext(ctx, `UPDATE password_setup_tokens SET used_at = ? WHERE user_id = ? AND used_at IS NULL`,
		time.Now().UTC(), userID); err != nil {
		return err
	}
	_, err := q.ExecContext(ctx, `INSERT INTO password_setup_tokens (id, user_id, token_hash, purpose, expires_at, created_by)
		VALUES (?, ?, ?, ?, ?, ?)`, uuid.NewString(), userID, hash, purpose, expires, createdBy)
	return err
}

func (s *Store) GetSetupToken(ctx context.Context, hash string) (SetupToken, error) {
	var t SetupToken
	var used sql.NullTime
	err := s.conn(ctx).QueryRowContext(ctx, `SELECT id, user_id, purpose, expires_at, used_at FROM password_setup_tokens
		WHERE token_hash = ?`, hash).Scan(&t.ID, &t.UserID, &t.Purpose, &t.ExpiresAt, &used)
	t.UsedAt = nullTimePtr(used)
	return t, mapErr(err, "")
}

func (s *Store) MarkSetupTokenUsed(ctx context.Context, id string) (bool, error) {
	res, err := s.conn(ctx).ExecContext(ctx, `UPDATE password_setup_tokens SET used_at = ? WHERE id = ? AND used_at IS NULL`,
		time.Now().UTC(), id)
	if err != nil {
		return false, err
	}
	n, err := res.RowsAffected()
	return n == 1, err
}
