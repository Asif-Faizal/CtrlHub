package domain

import (
	"fmt"
	"strings"
	"time"
)

// WhatsApp session statuses. The WAHA statuses are STOPPED, STARTING,
// SCAN_QR_CODE, WORKING and FAILED; NOT_CONNECTED means no session exists yet.
const (
	SessionNotConnected = "NOT_CONNECTED"
	SessionStopped      = "STOPPED"
	SessionStarting     = "STARTING"
	SessionScanQR       = "SCAN_QR_CODE"
	SessionWorking      = "WORKING"
	SessionFailed       = "FAILED"
)

type WhatsAppSession struct {
	TenantID     string     `json:"tenant_id"`
	TenantName   string     `json:"tenant_name,omitempty"`
	SessionName  string     `json:"session_name"`
	PhoneNumber  string     `json:"phone_number"`
	Status       string     `json:"status"`
	LastStatusAt *time.Time `json:"last_status_at"`
}

// Message categories recorded in message_logs.
const (
	CategoryTest        = "TEST"
	CategoryExpiry      = "EXPIRY_REMINDER"
	CategoryHoliday     = "HOLIDAY"
	CategoryCampaign    = "CAMPAIGN"
	CategoryBirthday    = "BIRTHDAY"
	CategoryDailyReport = "DAILY_REPORT"
)

type MessageLog struct {
	ID                string    `json:"id"`
	TenantID          string    `json:"-"`
	SessionName       string    `json:"session_name"`
	RecipientPhone    string    `json:"recipient_phone"`
	RecipientName     string    `json:"recipient_name"`
	Category          string    `json:"category"`
	Body              string    `json:"body"`
	Provider          string    `json:"provider"`
	ProviderMessageID string    `json:"provider_message_id"`
	Status            string    `json:"status"`
	Error             string    `json:"error"`
	NotificationLogID *string   `json:"notification_log_id"`
	SentBy            *string   `json:"sent_by"`
	CreatedAt         time.Time `json:"created_at"`
}

type MessagingPreferences struct {
	ExpiryTemplate    string `json:"expiry_template"`
	HolidayTemplate   string `json:"holiday_template"`
	BirthdayTemplate  string `json:"birthday_template"`
	DailyMessageLimit int    `json:"daily_message_limit"`
}

var DefaultMessagingPreferences = MessagingPreferences{
	ExpiryTemplate:    "Hi {{name}}, your {{plan}} membership at {{gym}} expires on {{date}} ({{days_text}}). Please renew to keep training without a break.",
	HolidayTemplate:   "Hi {{name}}, {{gym}} will be closed on {{date}} for {{holiday}}. {{description}}",
	BirthdayTemplate:  "Happy birthday {{name}}! Wishing you a strong and healthy year ahead from all of us at {{gym}}.",
	DailyMessageLimit: 500,
}

type AutomationSettings struct {
	ExpiryEnabled      bool   `json:"expiry_enabled"`
	ExpiryDaysBefore   []int  `json:"expiry_days_before"`
	HolidayEnabled     bool   `json:"holiday_enabled"`
	BirthdayEnabled    bool   `json:"birthday_enabled"`
	CampaignsEnabled   bool   `json:"campaigns_enabled"`
	DailyReportEnabled bool   `json:"daily_report_enabled"`
	DailyReportPhone   string `json:"daily_report_phone"`
}

var DefaultExpiryDaysBefore = []int{7, 3, 1, 0}

// Notification types handled by the automation API.
const (
	NotifyExpiry      = "expiry"
	NotifyHoliday     = "holiday"
	NotifyBirthday    = "birthday"
	NotifyDailyReport = "daily_report"
	NotifyCampaign    = "campaign"
)

func ExpiryKey(membershipID string, daysBefore int) string {
	return fmt.Sprintf("expiry:%s:%dd", membershipID, daysBefore)
}

func HolidayKey(holidayID, memberID string, daysBefore int) string {
	return fmt.Sprintf("holiday:%s:%s:%dd", holidayID, memberID, daysBefore)
}

func BirthdayKey(memberID string, year int) string {
	return fmt.Sprintf("birthday:%s:%d", memberID, year)
}

func DailyReportKey(d Date) string { return "daily_report:" + d.String() }

func CampaignKey(campaignID, recipientID string) string {
	return fmt.Sprintf("campaign:%s:%s", campaignID, recipientID)
}

// RenderTemplate replaces {{placeholder}} tokens with values.
func RenderTemplate(tpl string, vars map[string]string) string {
	pairs := make([]string, 0, len(vars)*2)
	for k, v := range vars {
		pairs = append(pairs, "{{"+k+"}}", v)
	}
	return strings.TrimSpace(strings.NewReplacer(pairs...).Replace(tpl))
}

// DueNotification is a single eligible notification returned to n8n.
type DueNotification struct {
	TenantID       string `json:"tenant_id"`
	TenantCode     string `json:"tenant_code"`
	Type           string `json:"type"`
	DedupeKey      string `json:"dedupe_key"`
	RecipientName  string `json:"recipient_name"`
	RecipientPhone string `json:"recipient_phone"`
	Preview        string `json:"preview"`
}

// SendResult reports what happened to one delivery request.
type SendResult struct {
	DedupeKey string `json:"dedupe_key"`
	Status    string `json:"status"` // SENT, FAILED, SKIPPED
	Reason    string `json:"reason,omitempty"`
	MessageID string `json:"message_log_id,omitempty"`
}

type CampaignAudience string

const (
	AudienceActive       CampaignAudience = "ACTIVE_MEMBERS"
	AudienceExpired      CampaignAudience = "EXPIRED_MEMBERS"
	AudienceNewLeads     CampaignAudience = "NEW_LEADS"
	AudienceExpiringSoon CampaignAudience = "EXPIRING_SOON"
	AudienceSelected     CampaignAudience = "SELECTED_MEMBERS"
)

const (
	CampaignDraft           = "DRAFT"
	CampaignPendingApproval = "PENDING_APPROVAL"
	CampaignApproved        = "APPROVED"
	CampaignSending         = "SENDING"
	CampaignCompleted       = "COMPLETED"
	CampaignRejected        = "REJECTED"
	CampaignCancelled       = "CANCELLED"
)

type CampaignAudienceParams struct {
	MemberIDs        []string `json:"member_ids,omitempty"`
	ExpiringInDays   int      `json:"expiring_in_days,omitempty"`
	LeadsCreatedDays int      `json:"leads_created_days,omitempty"`
}

type Campaign struct {
	ID              string                 `json:"id"`
	TenantID        string                 `json:"-"`
	Name            string                 `json:"name"`
	Message         string                 `json:"message"`
	Audience        CampaignAudience       `json:"audience"`
	AudienceParams  CampaignAudienceParams `json:"audience_params"`
	Status          string                 `json:"status"`
	ScheduledAt     *time.Time             `json:"scheduled_at"`
	CreatedBy       *string                `json:"created_by"`
	ApprovedBy      *string                `json:"approved_by"`
	ApprovedAt      *time.Time             `json:"approved_at"`
	RejectionReason string                 `json:"rejection_reason"`
	RecipientsTotal int                    `json:"recipients_total"`
	SentCount       int                    `json:"sent_count"`
	FailedCount     int                    `json:"failed_count"`
	SkippedCount    int                    `json:"skipped_count"`
	CreatedAt       time.Time              `json:"created_at"`
	UpdatedAt       time.Time              `json:"updated_at"`
}

type CampaignRecipient struct {
	ID            string     `json:"id"`
	TenantID      string     `json:"tenant_id"`
	CampaignID    string     `json:"campaign_id"`
	RecipientType string     `json:"recipient_type"`
	RecipientID   string     `json:"recipient_id"`
	Name          string     `json:"name"`
	Phone         string     `json:"phone"`
	Status        string     `json:"status"`
	Error         string     `json:"error"`
	SentAt        *time.Time `json:"sent_at"`
}

// NormalizePhone strips formatting and prefixes the default country code for
// bare 10-digit numbers. The result is digits only (WhatsApp chatId format).
func NormalizePhone(raw, defaultCC string) (string, error) {
	var b strings.Builder
	for _, r := range raw {
		if r >= '0' && r <= '9' {
			b.WriteRune(r)
		}
	}
	d := strings.TrimLeft(b.String(), "0")
	if len(d) == 10 && defaultCC != "" {
		d = defaultCC + d
	}
	if len(d) < 8 || len(d) > 15 {
		return "", InvalidField("phone", "must be a valid phone number with country code")
	}
	return d, nil
}
