// Mirrors the backend JSON contracts (backend/api/openapi.yaml).

export type Role = "PLATFORM_ADMIN" | "GYM_ADMIN" | "GYM_MANAGER" | "RECEPTIONIST" | "TRAINER";
export const GYM_ROLES: Role[] = ["GYM_ADMIN", "GYM_MANAGER", "RECEPTIONIST", "TRAINER"];

export type Permission =
  | "tenant.read"
  | "tenant.update"
  | "users.manage"
  | "members.read"
  | "members.write"
  | "plans.read"
  | "plans.write"
  | "memberships.read"
  | "memberships.write"
  | "payments.read"
  | "payments.write"
  | "attendance.read"
  | "attendance.write"
  | "holidays.read"
  | "holidays.write"
  | "leads.read"
  | "leads.write"
  | "campaigns.read"
  | "campaigns.write"
  | "campaigns.approve"
  | "whatsapp.read"
  | "whatsapp.manage"
  | "automation.manage"
  | "messages.read"
  | "reports.read"
  | "platform.manage";

export interface UserInfo {
  id: string;
  name: string;
  email: string;
  role: Role;
  dashboard: "platform" | "gym";
  tenant_id?: string;
  tenant_code?: string;
  tenant_name?: string;
  permissions: Permission[];
}

export interface Session {
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
  user: UserInfo;
}

export interface Page<T> {
  items: T[];
  total: number;
  page: number;
  page_size: number;
}

export interface Tenant {
  id: string;
  code: string;
  name: string;
  owner_name: string;
  contact_number: string;
  email: string;
  address: string;
  city: string;
  state: string;
  country: string;
  timezone: string;
  currency: string;
  opening_hours: unknown;
  status: "ACTIVE" | "INACTIVE";
  max_users: number;
  whatsapp_enabled: boolean;
  created_at: string;
  updated_at: string;
}

export interface TenantSummary extends Tenant {
  user_count: number;
  member_count: number;
  whatsapp_status: string;
}

export interface PlatformStats {
  total_tenants: number;
  active_tenants: number;
  total_users: number;
  total_members: number;
  whatsapp_connected: number;
  messages_last_30_days: number;
}

export interface AuditEntry {
  id: string;
  tenant_id: string | null;
  actor_user_id: string | null;
  action: string;
  entity_type: string;
  entity_id: string;
  metadata: unknown;
  ip: string;
  created_at: string;
}

export type UserStatus = "ACTIVE" | "INACTIVE" | "PENDING_SETUP";

export interface TenantUser {
  id: string;
  name: string;
  email: string;
  phone: string;
  is_platform_admin: boolean;
  status: UserStatus;
  last_login_at: string | null;
  created_at: string;
  updated_at: string;
  tenant_id: string;
  role: Role;
  is_primary: boolean;
}

export interface CreatedUser {
  user: TenantUser;
  setup_url?: string;
}

export interface OnboardResult {
  tenant: Tenant;
  admin: TenantUser;
  setup_url?: string;
}

export type MembershipState = "ACTIVE" | "UPCOMING" | "EXPIRED" | "CANCELLED" | "NONE";
export type PaymentStatus = "UNPAID" | "PARTIAL" | "PAID";

export interface Member {
  id: string;
  full_name: string;
  phone: string;
  email: string;
  gender: string;
  date_of_birth: string | null;
  address: string;
  emergency_contact: string;
  notes: string;
  joined_on: string;
  status: "ACTIVE" | "INACTIVE";
  whatsapp_opt_in: boolean;
  marketing_opt_in: boolean;
  created_at: string;
  updated_at: string;
  membership_status: MembershipState;
  current_plan: string;
  expires_on: string | null;
}

export type DurationType = "MONTHLY" | "QUARTERLY" | "HALF_YEARLY" | "YEARLY" | "CUSTOM";

export interface Plan {
  id: string;
  name: string;
  description: string;
  duration_type: DurationType;
  duration_days: number | null;
  price_minor: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Membership {
  id: string;
  member_id: string;
  member_name?: string;
  plan_id: string;
  plan_name: string;
  start_date: string;
  end_date: string;
  total_amount_minor: number;
  paid_amount_minor: number;
  renewed_from_id: string | null;
  notes: string;
  created_at: string;
  status: MembershipState;
  payment_status: PaymentStatus;
  pending_amount_minor: number;
}

export const PAYMENT_METHODS = ["CASH", "UPI", "CARD", "BANK_TRANSFER", "OTHER"] as const;
export type PaymentMethod = (typeof PAYMENT_METHODS)[number];

export interface Payment {
  id: string;
  member_id: string;
  member_name?: string;
  membership_id: string | null;
  amount_minor: number;
  method: PaymentMethod;
  reference: string;
  notes: string;
  paid_at: string;
  recorded_by: string | null;
  created_at: string;
}

export interface Attendance {
  id: string;
  member_id: string;
  member_name?: string;
  attendance_date: string;
  check_in_at: string;
  recorded_by: string | null;
}

export interface Holiday {
  id: string;
  title: string;
  description: string;
  holiday_date: string;
  notify_enabled: boolean;
  notify_days_before: number[];
  created_at: string;
  updated_at: string;
}

export type LeadStatus = "NEW" | "CONTACTED" | "CONVERTED" | "LOST";

export interface Lead {
  id: string;
  full_name: string;
  phone: string;
  email: string;
  source: string;
  status: LeadStatus;
  whatsapp_opt_in: boolean;
  marketing_opt_in: boolean;
  notes: string;
  created_at: string;
  updated_at: string;
}

export interface DailyReport {
  date: string;
  active_members: number;
  new_members: number;
  expiring_next_7_days: number;
  expired_today: number;
  renewals: number;
  pending_payments_minor: number;
  revenue_minor: number;
  attendance: number;
}

export type SessionStatus = "NOT_CONNECTED" | "STOPPED" | "STARTING" | "SCAN_QR_CODE" | "WORKING" | "FAILED";

export interface WhatsAppSession {
  tenant_id: string;
  tenant_name?: string;
  session_name: string;
  phone_number: string;
  status: SessionStatus;
  last_status_at: string | null;
}

export interface WhatsAppStatusResponse {
  session: WhatsAppSession;
  provider: "mock" | "waha";
}

export interface QRCode {
  mimetype: string;
  data: string;
}

export interface MessageLog {
  id: string;
  session_name: string;
  recipient_phone: string;
  recipient_name: string;
  category: string;
  body: string;
  provider: string;
  provider_message_id: string;
  status: "SENT" | "FAILED";
  error: string;
  created_at: string;
}

export interface MessagingPreferences {
  expiry_template: string;
  holiday_template: string;
  birthday_template: string;
  daily_message_limit: number;
}

export interface AutomationSettings {
  expiry_enabled: boolean;
  expiry_days_before: number[];
  holiday_enabled: boolean;
  birthday_enabled: boolean;
  campaigns_enabled: boolean;
  daily_report_enabled: boolean;
  daily_report_phone: string;
}

export type CampaignAudience =
  | "ACTIVE_MEMBERS"
  | "EXPIRED_MEMBERS"
  | "NEW_LEADS"
  | "EXPIRING_SOON"
  | "SELECTED_MEMBERS";

export type CampaignStatus =
  | "DRAFT"
  | "PENDING_APPROVAL"
  | "APPROVED"
  | "SENDING"
  | "COMPLETED"
  | "REJECTED"
  | "CANCELLED";

export interface CampaignAudienceParams {
  member_ids?: string[];
  expiring_in_days?: number;
  leads_created_days?: number;
}

export interface Campaign {
  id: string;
  name: string;
  message: string;
  audience: CampaignAudience;
  audience_params: CampaignAudienceParams;
  status: CampaignStatus;
  scheduled_at: string | null;
  created_by: string | null;
  approved_by: string | null;
  approved_at: string | null;
  rejection_reason: string;
  recipients_total: number;
  sent_count: number;
  failed_count: number;
  skipped_count: number;
  created_at: string;
  updated_at: string;
}

export interface CampaignRecipient {
  id: string;
  recipient_type: "MEMBER" | "LEAD";
  recipient_id: string;
  name: string;
  phone: string;
  status: "PENDING" | "SENT" | "FAILED" | "SKIPPED";
  error: string;
  sent_at: string | null;
}

export interface ApiErrorBody {
  error: { code: string; message: string; details?: Record<string, string> };
}
