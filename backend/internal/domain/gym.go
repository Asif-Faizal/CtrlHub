package domain

import "time"

type Member struct {
	ID               string          `json:"id"`
	TenantID         string          `json:"-"`
	FullName         string          `json:"full_name"`
	Phone            string          `json:"phone"`
	Email            string          `json:"email"`
	Gender           string          `json:"gender"`
	DateOfBirth      NullDate        `json:"date_of_birth"`
	Address          string          `json:"address"`
	EmergencyContact string          `json:"emergency_contact"`
	Notes            string          `json:"notes"`
	JoinedOn         Date            `json:"joined_on"`
	Status           string          `json:"status"`
	WhatsAppOptIn    bool            `json:"whatsapp_opt_in"`
	MarketingOptIn   bool            `json:"marketing_opt_in"`
	CreatedAt        time.Time       `json:"created_at"`
	UpdatedAt        time.Time       `json:"updated_at"`
	MembershipState  MembershipState `json:"membership_status"`
	CurrentPlan      string          `json:"current_plan"`
	ExpiresOn        NullDate        `json:"expires_on"`
}

type MemberFilter struct {
	Search   string
	Status   string // active | expired | none | ""
	Today    Date
	Page     int
	PageSize int
}

type Payment struct {
	ID           string    `json:"id"`
	TenantID     string    `json:"-"`
	MemberID     string    `json:"member_id"`
	MemberName   string    `json:"member_name,omitempty"`
	MembershipID *string   `json:"membership_id"`
	AmountMinor  int64     `json:"amount_minor"`
	Method       string    `json:"method"`
	Reference    string    `json:"reference"`
	Notes        string    `json:"notes"`
	PaidAt       time.Time `json:"paid_at"`
	RecordedBy   *string   `json:"recorded_by"`
	CreatedAt    time.Time `json:"created_at"`
}

var PaymentMethods = []string{"CASH", "UPI", "CARD", "BANK_TRANSFER", "OTHER"}

type Attendance struct {
	ID             string    `json:"id"`
	TenantID       string    `json:"-"`
	MemberID       string    `json:"member_id"`
	MemberName     string    `json:"member_name,omitempty"`
	AttendanceDate Date      `json:"attendance_date"`
	CheckInAt      time.Time `json:"check_in_at"`
	RecordedBy     *string   `json:"recorded_by"`
}

type Holiday struct {
	ID               string    `json:"id"`
	TenantID         string    `json:"-"`
	Title            string    `json:"title"`
	Description      string    `json:"description"`
	HolidayDate      Date      `json:"holiday_date"`
	NotifyEnabled    bool      `json:"notify_enabled"`
	NotifyDaysBefore []int     `json:"notify_days_before"`
	CreatedAt        time.Time `json:"created_at"`
	UpdatedAt        time.Time `json:"updated_at"`
}

type Lead struct {
	ID             string    `json:"id"`
	TenantID       string    `json:"-"`
	FullName       string    `json:"full_name"`
	Phone          string    `json:"phone"`
	Email          string    `json:"email"`
	Source         string    `json:"source"`
	Status         string    `json:"status"`
	WhatsAppOptIn  bool      `json:"whatsapp_opt_in"`
	MarketingOptIn bool      `json:"marketing_opt_in"`
	Notes          string    `json:"notes"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

type DailyReport struct {
	Date                 Date  `json:"date"`
	ActiveMembers        int   `json:"active_members"`
	NewMembers           int   `json:"new_members"`
	ExpiringNext7Days    int   `json:"expiring_next_7_days"`
	ExpiredToday         int   `json:"expired_today"`
	Renewals             int   `json:"renewals"`
	PendingPaymentsMinor int64 `json:"pending_payments_minor"`
	RevenueMinor         int64 `json:"revenue_minor"`
	Attendance           int   `json:"attendance"`
}

type Page[T any] struct {
	Items    []T `json:"items"`
	Total    int `json:"total"`
	Page     int `json:"page"`
	PageSize int `json:"page_size"`
}

func NormalizePaging(page, size int) (int, int) {
	if page < 1 {
		page = 1
	}
	if size < 1 || size > 100 {
		size = 20
	}
	return page, size
}
