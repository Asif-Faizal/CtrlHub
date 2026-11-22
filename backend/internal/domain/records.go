package domain

import "time"

// Read models and filters shared between the application and persistence layers.

type PrincipalRecord struct {
	Principal
	UserStatus   UserStatus
	TenantStatus TenantStatus
}

type RefreshToken struct {
	ID        string
	UserID    string
	ExpiresAt time.Time
	RevokedAt *time.Time
}

type SetupToken struct {
	ID        string
	UserID    string
	Purpose   string
	ExpiresAt time.Time
	UsedAt    *time.Time
}

type MembershipFilter struct {
	MemberID string
	View     string // all | active | expiring | expired
	Days     int
	Today    Date
	Page     int
	PageSize int
}

type PaymentFilter struct {
	MemberID string
	From, To *time.Time
	Page     int
	PageSize int
}

// AutomationTenant is an active tenant together with its WhatsApp session.
type AutomationTenant struct {
	Tenant        Tenant
	SessionName   string
	SessionStatus string
}

type ExpiryCandidate struct {
	MembershipID string
	EndDate      Date
	PlanName     string
	MemberID     string
	MemberName   string
	Phone        string
}

type MemberContact struct {
	ID    string
	Name  string
	Phone string
}

// PendingCampaignRecipient is a queued campaign message for n8n to deliver.
type PendingCampaignRecipient struct {
	TenantID     string `json:"tenant_id"`
	TenantCode   string `json:"tenant_code"`
	CampaignID   string `json:"campaign_id"`
	CampaignName string `json:"campaign_name"`
	RecipientID  string `json:"recipient_id"`
	Name         string `json:"recipient_name"`
	Phone        string `json:"recipient_phone"`
}
