package domain

import "time"

type UserStatus string

const (
	UserActive       UserStatus = "ACTIVE"
	UserInactive     UserStatus = "INACTIVE"
	UserPendingSetup UserStatus = "PENDING_SETUP"
)

type User struct {
	ID              string     `json:"id"`
	Name            string     `json:"name"`
	Email           string     `json:"email"`
	Phone           string     `json:"phone"`
	PasswordHash    string     `json:"-"`
	IsPlatformAdmin bool       `json:"is_platform_admin"`
	Status          UserStatus `json:"status"`
	LastLoginAt     *time.Time `json:"last_login_at"`
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedAt       time.Time  `json:"updated_at"`
}

// TenantUser is a user together with their role inside a tenant.
type TenantUser struct {
	User
	TenantID  string `json:"tenant_id"`
	Role      Role   `json:"role"`
	IsPrimary bool   `json:"is_primary"`
}

// Principal is the authenticated identity resolved for a request. TenantID and
// Role always come from the database, never from client input.
type Principal struct {
	UserID          string
	Name            string
	Email           string
	Role            Role
	TenantID        string
	TenantCode      string
	TenantName      string
	TenantTimezone  string
	IsPlatformAdmin bool
}

// Today is the current date in the principal's tenant timezone.
func (p Principal) Today(now time.Time) Date { return Today(now, p.TenantTimezone) }

func (p Principal) Can(perm Permission) bool { return p.Role.Can(perm) }
