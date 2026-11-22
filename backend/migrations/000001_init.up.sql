-- Platform and authentication

CREATE TABLE roles (
  id TINYINT UNSIGNED NOT NULL PRIMARY KEY,
  name VARCHAR(32) NOT NULL,
  description VARCHAR(255) NOT NULL DEFAULT '',
  UNIQUE KEY uq_roles_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO roles (id, name, description) VALUES
  (1, 'PLATFORM_ADMIN', 'Owns and manages the whole platform'),
  (2, 'GYM_ADMIN', 'Primary administrator of a gym'),
  (3, 'GYM_MANAGER', 'Manages day-to-day gym operations'),
  (4, 'RECEPTIONIST', 'Front desk: members, renewals, payments, attendance'),
  (5, 'TRAINER', 'Views members and records attendance');

CREATE TABLE tenants (
  id CHAR(36) NOT NULL PRIMARY KEY,
  seq BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(40) NOT NULL,
  name VARCHAR(150) NOT NULL,
  owner_name VARCHAR(150) NOT NULL,
  contact_number VARCHAR(20) NOT NULL,
  email VARCHAR(190) NOT NULL,
  address VARCHAR(255) NOT NULL DEFAULT '',
  city VARCHAR(100) NOT NULL DEFAULT '',
  state VARCHAR(100) NOT NULL DEFAULT '',
  country VARCHAR(100) NOT NULL DEFAULT '',
  timezone VARCHAR(64) NOT NULL DEFAULT 'Asia/Kolkata',
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  opening_hours JSON NULL,
  status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  max_users INT NOT NULL DEFAULT 10,
  whatsapp_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_tenants_seq (seq),
  UNIQUE KEY uq_tenants_code (code),
  KEY idx_tenants_status (status),
  KEY idx_tenants_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE users (
  id CHAR(36) NOT NULL PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(190) NOT NULL,
  phone VARCHAR(20) NOT NULL DEFAULT '',
  password_hash VARCHAR(255) NULL,
  is_platform_admin BOOLEAN NOT NULL DEFAULT FALSE,
  status ENUM('ACTIVE','INACTIVE','PENDING_SETUP') NOT NULL DEFAULT 'PENDING_SETUP',
  last_login_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- A gym user belongs to exactly one tenant in the MVP (uq_tenant_users_user).
CREATE TABLE tenant_users (
  id CHAR(36) NOT NULL PRIMARY KEY,
  tenant_id CHAR(36) NOT NULL,
  user_id CHAR(36) NOT NULL,
  role_id TINYINT UNSIGNED NOT NULL,
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_tenant_users_user (user_id),
  KEY idx_tenant_users_tenant (tenant_id, role_id),
  CONSTRAINT fk_tenant_users_tenant FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_tenant_users_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_tenant_users_role FOREIGN KEY (role_id) REFERENCES roles (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE refresh_tokens (
  id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at DATETIME(3) NOT NULL,
  revoked_at DATETIME(3) NULL,
  replaced_by CHAR(36) NULL,
  user_agent VARCHAR(255) NOT NULL DEFAULT '',
  ip VARCHAR(64) NOT NULL DEFAULT '',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_refresh_tokens_hash (token_hash),
  KEY idx_refresh_tokens_user (user_id),
  CONSTRAINT fk_refresh_tokens_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE password_setup_tokens (
  id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  token_hash CHAR(64) NOT NULL,
  purpose ENUM('SETUP','RESET') NOT NULL,
  expires_at DATETIME(3) NOT NULL,
  used_at DATETIME(3) NULL,
  created_by CHAR(36) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_password_setup_tokens_hash (token_hash),
  KEY idx_password_setup_tokens_user (user_id),
  CONSTRAINT fk_password_setup_tokens_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Gym management. Child tables reference (tenant_id, id) of their parent so a
-- row can never point at a parent that belongs to a different tenant.

CREATE TABLE members (
  id CHAR(36) NOT NULL PRIMARY KEY,
  tenant_id CHAR(36) NOT NULL,
  full_name VARCHAR(150) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  email VARCHAR(190) NOT NULL DEFAULT '',
  gender ENUM('MALE','FEMALE','OTHER','') NOT NULL DEFAULT '',
  date_of_birth DATE NULL,
  address VARCHAR(255) NOT NULL DEFAULT '',
  emergency_contact VARCHAR(100) NOT NULL DEFAULT '',
  notes TEXT NULL,
  joined_on DATE NOT NULL,
  status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  whatsapp_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
  marketing_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
  consent_updated_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_members_tenant_phone (tenant_id, phone),
  UNIQUE KEY uq_members_tenant_id (tenant_id, id),
  KEY idx_members_tenant_name (tenant_id, full_name),
  KEY idx_members_tenant_joined (tenant_id, joined_on),
  CONSTRAINT fk_members_tenant FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE membership_plans (
  id CHAR(36) NOT NULL PRIMARY KEY,
  tenant_id CHAR(36) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(500) NOT NULL DEFAULT '',
  duration_type ENUM('MONTHLY','QUARTERLY','HALF_YEARLY','YEARLY','CUSTOM') NOT NULL,
  duration_days INT NULL,
  price_minor BIGINT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_membership_plans_tenant_name (tenant_id, name),
  UNIQUE KEY uq_membership_plans_tenant_id (tenant_id, id),
  CONSTRAINT fk_membership_plans_tenant FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE memberships (
  id CHAR(36) NOT NULL PRIMARY KEY,
  tenant_id CHAR(36) NOT NULL,
  member_id CHAR(36) NOT NULL,
  plan_id CHAR(36) NOT NULL,
  plan_name VARCHAR(100) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  total_amount_minor BIGINT NOT NULL,
  status ENUM('ACTIVE','CANCELLED') NOT NULL DEFAULT 'ACTIVE',
  renewed_from_id CHAR(36) NULL,
  notes VARCHAR(500) NOT NULL DEFAULT '',
  created_by CHAR(36) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_memberships_tenant_id (tenant_id, id),
  KEY idx_memberships_tenant_member (tenant_id, member_id, end_date),
  KEY idx_memberships_tenant_end (tenant_id, end_date),
  CONSTRAINT fk_memberships_member FOREIGN KEY (tenant_id, member_id) REFERENCES members (tenant_id, id) ON DELETE CASCADE,
  CONSTRAINT fk_memberships_plan FOREIGN KEY (tenant_id, plan_id) REFERENCES membership_plans (tenant_id, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE payments (
  id CHAR(36) NOT NULL PRIMARY KEY,
  tenant_id CHAR(36) NOT NULL,
  member_id CHAR(36) NOT NULL,
  membership_id CHAR(36) NULL,
  amount_minor BIGINT NOT NULL,
  method ENUM('CASH','UPI','CARD','BANK_TRANSFER','OTHER') NOT NULL,
  reference VARCHAR(100) NOT NULL DEFAULT '',
  notes VARCHAR(500) NOT NULL DEFAULT '',
  paid_at DATETIME(3) NOT NULL,
  recorded_by CHAR(36) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  KEY idx_payments_tenant_paid (tenant_id, paid_at),
  KEY idx_payments_tenant_member (tenant_id, member_id),
  KEY idx_payments_tenant_membership (tenant_id, membership_id),
  CONSTRAINT fk_payments_member FOREIGN KEY (tenant_id, member_id) REFERENCES members (tenant_id, id) ON DELETE CASCADE,
  CONSTRAINT fk_payments_membership FOREIGN KEY (tenant_id, membership_id) REFERENCES memberships (tenant_id, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE attendance (
  id CHAR(36) NOT NULL PRIMARY KEY,
  tenant_id CHAR(36) NOT NULL,
  member_id CHAR(36) NOT NULL,
  attendance_date DATE NOT NULL,
  check_in_at DATETIME(3) NOT NULL,
  recorded_by CHAR(36) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_attendance_member_day (tenant_id, member_id, attendance_date),
  KEY idx_attendance_tenant_date (tenant_id, attendance_date),
  CONSTRAINT fk_attendance_member FOREIGN KEY (tenant_id, member_id) REFERENCES members (tenant_id, id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE holidays (
  id CHAR(36) NOT NULL PRIMARY KEY,
  tenant_id CHAR(36) NOT NULL,
  title VARCHAR(150) NOT NULL,
  description VARCHAR(500) NOT NULL DEFAULT '',
  holiday_date DATE NOT NULL,
  notify_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  notify_days_before JSON NOT NULL,
  created_by CHAR(36) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  KEY idx_holidays_tenant_date (tenant_id, holiday_date),
  CONSTRAINT fk_holidays_tenant FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE leads (
  id CHAR(36) NOT NULL PRIMARY KEY,
  tenant_id CHAR(36) NOT NULL,
  full_name VARCHAR(150) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  email VARCHAR(190) NOT NULL DEFAULT '',
  source VARCHAR(50) NOT NULL DEFAULT '',
  status ENUM('NEW','CONTACTED','CONVERTED','LOST') NOT NULL DEFAULT 'NEW',
  whatsapp_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
  marketing_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
  notes VARCHAR(500) NOT NULL DEFAULT '',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_leads_tenant_phone (tenant_id, phone),
  KEY idx_leads_tenant_status (tenant_id, status),
  CONSTRAINT fk_leads_tenant FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- WhatsApp and automation

CREATE TABLE whatsapp_sessions (
  id CHAR(36) NOT NULL PRIMARY KEY,
  tenant_id CHAR(36) NOT NULL,
  session_name VARCHAR(64) NOT NULL,
  phone_number VARCHAR(32) NOT NULL DEFAULT '',
  status VARCHAR(32) NOT NULL DEFAULT 'NOT_CONNECTED',
  last_status_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_whatsapp_sessions_tenant (tenant_id),
  UNIQUE KEY uq_whatsapp_sessions_name (session_name),
  CONSTRAINT fk_whatsapp_sessions_tenant FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Tenant-level messaging templates and limits.
CREATE TABLE messaging_preferences (
  tenant_id CHAR(36) NOT NULL PRIMARY KEY,
  expiry_template TEXT NOT NULL,
  holiday_template TEXT NOT NULL,
  birthday_template TEXT NOT NULL,
  daily_message_limit INT NOT NULL DEFAULT 500,
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_messaging_preferences_tenant FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE automation_settings (
  tenant_id CHAR(36) NOT NULL PRIMARY KEY,
  expiry_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  expiry_days_before JSON NOT NULL,
  holiday_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  birthday_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  campaigns_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  daily_report_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  daily_report_phone VARCHAR(20) NOT NULL DEFAULT '',
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_automation_settings_tenant FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE campaigns (
  id CHAR(36) NOT NULL PRIMARY KEY,
  tenant_id CHAR(36) NOT NULL,
  name VARCHAR(150) NOT NULL,
  message TEXT NOT NULL,
  audience ENUM('ACTIVE_MEMBERS','EXPIRED_MEMBERS','NEW_LEADS','EXPIRING_SOON','SELECTED_MEMBERS') NOT NULL,
  audience_params JSON NULL,
  status ENUM('DRAFT','PENDING_APPROVAL','APPROVED','SENDING','COMPLETED','REJECTED','CANCELLED') NOT NULL DEFAULT 'DRAFT',
  scheduled_at DATETIME(3) NULL,
  created_by CHAR(36) NULL,
  approved_by CHAR(36) NULL,
  approved_at DATETIME(3) NULL,
  rejection_reason VARCHAR(500) NOT NULL DEFAULT '',
  recipients_total INT NOT NULL DEFAULT 0,
  sent_count INT NOT NULL DEFAULT 0,
  failed_count INT NOT NULL DEFAULT 0,
  skipped_count INT NOT NULL DEFAULT 0,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_campaigns_tenant_id (tenant_id, id),
  KEY idx_campaigns_tenant_status (tenant_id, status),
  KEY idx_campaigns_status (status),
  CONSTRAINT fk_campaigns_tenant FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE campaign_recipients (
  id CHAR(36) NOT NULL PRIMARY KEY,
  tenant_id CHAR(36) NOT NULL,
  campaign_id CHAR(36) NOT NULL,
  recipient_type ENUM('MEMBER','LEAD') NOT NULL,
  recipient_id CHAR(36) NOT NULL,
  name VARCHAR(150) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  status ENUM('PENDING','SENT','FAILED','SKIPPED') NOT NULL DEFAULT 'PENDING',
  error VARCHAR(500) NOT NULL DEFAULT '',
  sent_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_campaign_recipients (campaign_id, recipient_type, recipient_id),
  KEY idx_campaign_recipients_status (tenant_id, campaign_id, status),
  CONSTRAINT fk_campaign_recipients_campaign FOREIGN KEY (tenant_id, campaign_id) REFERENCES campaigns (tenant_id, id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Duplicate prevention for automated notifications: one row per (tenant, dedupe_key).
CREATE TABLE notification_logs (
  id CHAR(36) NOT NULL PRIMARY KEY,
  tenant_id CHAR(36) NOT NULL,
  dedupe_key VARCHAR(191) NOT NULL,
  type VARCHAR(32) NOT NULL,
  recipient_phone VARCHAR(20) NOT NULL DEFAULT '',
  status ENUM('PENDING','SENT','FAILED','SKIPPED') NOT NULL DEFAULT 'PENDING',
  attempts INT NOT NULL DEFAULT 1,
  last_error VARCHAR(500) NOT NULL DEFAULT '',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_notification_logs_key (tenant_id, dedupe_key),
  KEY idx_notification_logs_tenant_created (tenant_id, created_at),
  CONSTRAINT fk_notification_logs_tenant FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE message_logs (
  id CHAR(36) NOT NULL PRIMARY KEY,
  tenant_id CHAR(36) NOT NULL,
  session_name VARCHAR(64) NOT NULL,
  recipient_phone VARCHAR(20) NOT NULL,
  recipient_name VARCHAR(150) NOT NULL DEFAULT '',
  category VARCHAR(32) NOT NULL,
  body TEXT NOT NULL,
  provider VARCHAR(16) NOT NULL,
  provider_message_id VARCHAR(191) NOT NULL DEFAULT '',
  status ENUM('SENT','FAILED') NOT NULL,
  error VARCHAR(500) NOT NULL DEFAULT '',
  notification_log_id CHAR(36) NULL,
  sent_by CHAR(36) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  KEY idx_message_logs_tenant_created (tenant_id, created_at),
  KEY idx_message_logs_tenant_category (tenant_id, category),
  CONSTRAINT fk_message_logs_tenant FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Platform administration

CREATE TABLE audit_logs (
  id CHAR(36) NOT NULL PRIMARY KEY,
  tenant_id CHAR(36) NULL,
  actor_user_id CHAR(36) NULL,
  action VARCHAR(64) NOT NULL,
  entity_type VARCHAR(64) NOT NULL,
  entity_id VARCHAR(64) NOT NULL DEFAULT '',
  metadata JSON NULL,
  ip VARCHAR(64) NOT NULL DEFAULT '',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  KEY idx_audit_logs_tenant_created (tenant_id, created_at),
  KEY idx_audit_logs_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
