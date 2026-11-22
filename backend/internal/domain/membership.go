package domain

import "time"

type DurationType string

const (
	DurationMonthly    DurationType = "MONTHLY"
	DurationQuarterly  DurationType = "QUARTERLY"
	DurationHalfYearly DurationType = "HALF_YEARLY"
	DurationYearly     DurationType = "YEARLY"
	DurationCustom     DurationType = "CUSTOM"
)

type MembershipPlan struct {
	ID           string       `json:"id"`
	TenantID     string       `json:"-"`
	Name         string       `json:"name"`
	Description  string       `json:"description"`
	DurationType DurationType `json:"duration_type"`
	DurationDays *int         `json:"duration_days"`
	PriceMinor   int64        `json:"price_minor"`
	IsActive     bool         `json:"is_active"`
	CreatedAt    time.Time    `json:"created_at"`
	UpdatedAt    time.Time    `json:"updated_at"`
}

// EndDate returns the last valid day of a plan starting on start (inclusive).
func (p MembershipPlan) EndDate(start Date) Date {
	switch p.DurationType {
	case DurationMonthly:
		return Date{start.AddDate(0, 1, -1)}
	case DurationQuarterly:
		return Date{start.AddDate(0, 3, -1)}
	case DurationHalfYearly:
		return Date{start.AddDate(0, 6, -1)}
	case DurationYearly:
		return Date{start.AddDate(1, 0, -1)}
	default:
		days := 1
		if p.DurationDays != nil && *p.DurationDays > 0 {
			days = *p.DurationDays
		}
		return start.AddDays(days - 1)
	}
}

func ValidateDuration(t DurationType, days *int) error {
	switch t {
	case DurationMonthly, DurationQuarterly, DurationHalfYearly, DurationYearly:
		return nil
	case DurationCustom:
		if days == nil || *days < 1 || *days > 3660 {
			return InvalidField("duration_days", "required for CUSTOM plans (1-3660)")
		}
		return nil
	}
	return InvalidField("duration_type", "must be MONTHLY, QUARTERLY, HALF_YEARLY, YEARLY or CUSTOM")
}

type MembershipState string

const (
	MembershipActive    MembershipState = "ACTIVE"
	MembershipUpcoming  MembershipState = "UPCOMING"
	MembershipExpired   MembershipState = "EXPIRED"
	MembershipCancelled MembershipState = "CANCELLED"
	MembershipNone      MembershipState = "NONE"
)

type PaymentStatus string

const (
	PaymentUnpaid  PaymentStatus = "UNPAID"
	PaymentPartial PaymentStatus = "PARTIAL"
	PaymentPaid    PaymentStatus = "PAID"
)

type Membership struct {
	ID               string          `json:"id"`
	TenantID         string          `json:"-"`
	MemberID         string          `json:"member_id"`
	MemberName       string          `json:"member_name,omitempty"`
	PlanID           string          `json:"plan_id"`
	PlanName         string          `json:"plan_name"`
	StartDate        Date            `json:"start_date"`
	EndDate          Date            `json:"end_date"`
	TotalAmountMinor int64           `json:"total_amount_minor"`
	PaidAmountMinor  int64           `json:"paid_amount_minor"`
	Cancelled        bool            `json:"-"`
	RenewedFromID    *string         `json:"renewed_from_id"`
	Notes            string          `json:"notes"`
	CreatedAt        time.Time       `json:"created_at"`
	State            MembershipState `json:"status"`
	PaymentStatus    PaymentStatus   `json:"payment_status"`
	PendingMinor     int64           `json:"pending_amount_minor"`
}

// Derive fills in the computed status fields relative to today.
func (m *Membership) Derive(today Date) {
	m.State = MembershipStateOn(m.StartDate, m.EndDate, m.Cancelled, today)
	m.PendingMinor = max(m.TotalAmountMinor-m.PaidAmountMinor, 0)
	m.PaymentStatus = PaymentStatusFor(m.TotalAmountMinor, m.PaidAmountMinor)
}

func MembershipStateOn(start, end Date, cancelled bool, today Date) MembershipState {
	switch {
	case cancelled:
		return MembershipCancelled
	case today.Before(start):
		return MembershipUpcoming
	case today.After(end):
		return MembershipExpired
	default:
		return MembershipActive
	}
}

func PaymentStatusFor(total, paid int64) PaymentStatus {
	switch {
	case paid <= 0 && total > 0:
		return PaymentUnpaid
	case paid < total:
		return PaymentPartial
	default:
		return PaymentPaid
	}
}

// RenewalStart is the first day of a renewal: the day after the latest expiry,
// or today if the member has already lapsed.
func RenewalStart(latestEnd Date, today Date) Date {
	next := latestEnd.AddDays(1)
	if next.Before(today) {
		return today
	}
	return next
}
