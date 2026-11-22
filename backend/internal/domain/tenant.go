package domain

import (
	"encoding/json"
	"time"
)

type TenantStatus string

const (
	TenantActive   TenantStatus = "ACTIVE"
	TenantInactive TenantStatus = "INACTIVE"
)

type Tenant struct {
	ID              string          `json:"id"`
	Code            string          `json:"code"`
	Name            string          `json:"name"`
	OwnerName       string          `json:"owner_name"`
	ContactNumber   string          `json:"contact_number"`
	Email           string          `json:"email"`
	Address         string          `json:"address"`
	City            string          `json:"city"`
	State           string          `json:"state"`
	Country         string          `json:"country"`
	Timezone        string          `json:"timezone"`
	Currency        string          `json:"currency"`
	OpeningHours    json.RawMessage `json:"opening_hours"`
	Status          TenantStatus    `json:"status"`
	MaxUsers        int             `json:"max_users"`
	WhatsAppEnabled bool            `json:"whatsapp_enabled"`
	CreatedAt       time.Time       `json:"created_at"`
	UpdatedAt       time.Time       `json:"updated_at"`
}

// TenantSummary is a tenant row enriched for the platform admin list.
type TenantSummary struct {
	Tenant
	UserCount      int    `json:"user_count"`
	MemberCount    int    `json:"member_count"`
	WhatsAppStatus string `json:"whatsapp_status"`
}

type PlatformStats struct {
	TotalTenants       int `json:"total_tenants"`
	ActiveTenants      int `json:"active_tenants"`
	TotalUsers         int `json:"total_users"`
	TotalMembers       int `json:"total_members"`
	WhatsAppConnected  int `json:"whatsapp_connected"`
	MessagesLast30Days int `json:"messages_last_30_days"`
}

type AuditEntry struct {
	ID          string          `json:"id"`
	TenantID    *string         `json:"tenant_id"`
	ActorUserID *string         `json:"actor_user_id"`
	Action      string          `json:"action"`
	EntityType  string          `json:"entity_type"`
	EntityID    string          `json:"entity_id"`
	Metadata    json.RawMessage `json:"metadata"`
	IP          string          `json:"ip"`
	CreatedAt   time.Time       `json:"created_at"`
}
