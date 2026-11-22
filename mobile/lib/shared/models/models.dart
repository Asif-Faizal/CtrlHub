import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class UserInfo with _$UserInfo {
  const factory UserInfo({
    required String id,
    required String name,
    required String email,
    required String role,
    required String dashboard,
    @JsonKey(name: 'tenant_id') String? tenantId,
    @JsonKey(name: 'tenant_code') String? tenantCode,
    @JsonKey(name: 'tenant_name') String? tenantName,
    required List<String> permissions,
  }) = _UserInfo;

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class Session with _$Session {
  const factory Session({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'token_type') required String tokenType,
    @JsonKey(name: 'expires_in') required int expiresIn,
    required UserInfo user,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class PageResult with _$PageResult {
  const factory PageResult({
    required List<Map<String, dynamic>> items,
    @Default(0) int total,
    @Default(1) int page,
    @JsonKey(name: 'page_size') @Default(20) int pageSize,
  }) = _PageResult;

  factory PageResult.fromJson(Map<String, dynamic> json) => _$PageResultFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class TenantSummary with _$TenantSummary {
  const factory TenantSummary({
    required String id,
    required String code,
    required String name,
    @JsonKey(name: 'owner_name') @Default('') String ownerName,
    @JsonKey(name: 'contact_number') @Default('') String contactNumber,
    @Default('') String email,
    @Default('') String city,
    @Default('ACTIVE') String status,
    @JsonKey(name: 'user_count') @Default(0) int userCount,
    @JsonKey(name: 'member_count') @Default(0) int memberCount,
    @JsonKey(name: 'whatsapp_status') @Default('NOT_CONNECTED') String whatsappStatus,
  }) = _TenantSummary;

  factory TenantSummary.fromJson(Map<String, dynamic> json) => _$TenantSummaryFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class PlatformStats with _$PlatformStats {
  const factory PlatformStats({
    @JsonKey(name: 'total_tenants') @Default(0) int totalTenants,
    @JsonKey(name: 'active_tenants') @Default(0) int activeTenants,
    @JsonKey(name: 'total_users') @Default(0) int totalUsers,
    @JsonKey(name: 'total_members') @Default(0) int totalMembers,
    @JsonKey(name: 'whatsapp_connected') @Default(0) int whatsappConnected,
    @JsonKey(name: 'messages_last_30_days') @Default(0) int messagesLast30Days,
  }) = _PlatformStats;

  factory PlatformStats.fromJson(Map<String, dynamic> json) => _$PlatformStatsFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class Member with _$Member {
  const factory Member({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    required String phone,
    @Default('') String email,
    @Default('ACTIVE') String status,
    @JsonKey(name: 'whatsapp_opt_in') @Default(false) bool whatsappOptIn,
    @JsonKey(name: 'marketing_opt_in') @Default(false) bool marketingOptIn,
    @JsonKey(name: 'membership_status') @Default('NONE') String membershipStatus,
    @JsonKey(name: 'current_plan') @Default('') String currentPlan,
    @JsonKey(name: 'expires_on') String? expiresOn,
  }) = _Member;

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class MembershipPlan with _$MembershipPlan {
  const factory MembershipPlan({
    required String id,
    required String name,
    @Default('') String description,
    @JsonKey(name: 'duration_type') required String durationType,
    @JsonKey(name: 'duration_days') int? durationDays,
    @JsonKey(name: 'price_minor') @Default(0) int priceMinor,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _MembershipPlan;

  factory MembershipPlan.fromJson(Map<String, dynamic> json) => _$MembershipPlanFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class Membership with _$Membership {
  const factory Membership({
    required String id,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'member_name') @Default('') String memberName,
    @JsonKey(name: 'plan_id') required String planId,
    @JsonKey(name: 'plan_name') @Default('') String planName,
    @JsonKey(name: 'start_date') required String startDate,
    @JsonKey(name: 'end_date') required String endDate,
    @JsonKey(name: 'total_amount_minor') @Default(0) int totalAmountMinor,
    @JsonKey(name: 'paid_amount_minor') @Default(0) int paidAmountMinor,
    @JsonKey(name: 'pending_amount_minor') @Default(0) int pendingAmountMinor,
    @Default('ACTIVE') String status,
    @JsonKey(name: 'payment_status') @Default('UNPAID') String paymentStatus,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) => _$MembershipFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class Payment with _$Payment {
  const factory Payment({
    required String id,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'member_name') @Default('') String memberName,
    @JsonKey(name: 'amount_minor') required int amountMinor,
    required String method,
    @Default('') String reference,
    @JsonKey(name: 'paid_at') required String paidAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class Attendance with _$Attendance {
  const factory Attendance({
    required String id,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'member_name') @Default('') String memberName,
    @JsonKey(name: 'attendance_date') required String attendanceDate,
    @JsonKey(name: 'check_in_at') required String checkInAt,
  }) = _Attendance;

  factory Attendance.fromJson(Map<String, dynamic> json) => _$AttendanceFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class Holiday with _$Holiday {
  const factory Holiday({
    required String id,
    required String title,
    @Default('') String description,
    @JsonKey(name: 'holiday_date') required String holidayDate,
    @JsonKey(name: 'notify_enabled') @Default(true) bool notifyEnabled,
    @JsonKey(name: 'notify_days_before') required List<int> notifyDaysBefore,
  }) = _Holiday;

  factory Holiday.fromJson(Map<String, dynamic> json) => _$HolidayFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class Lead with _$Lead {
  const factory Lead({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    required String phone,
    @Default('') String email,
    @Default('') String source,
    @Default('NEW') String status,
    @JsonKey(name: 'whatsapp_opt_in') @Default(false) bool whatsappOptIn,
    @JsonKey(name: 'marketing_opt_in') @Default(false) bool marketingOptIn,
  }) = _Lead;

  factory Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class Campaign with _$Campaign {
  const factory Campaign({
    required String id,
    required String name,
    required String message,
    required String audience,
    @Default('DRAFT') String status,
    @JsonKey(name: 'recipients_total') @Default(0) int recipientsTotal,
    @JsonKey(name: 'sent_count') @Default(0) int sentCount,
    @JsonKey(name: 'failed_count') @Default(0) int failedCount,
  }) = _Campaign;

  factory Campaign.fromJson(Map<String, dynamic> json) => _$CampaignFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class WhatsAppSession with _$WhatsAppSession {
  const factory WhatsAppSession({
    @JsonKey(name: 'tenant_id') @Default('') String tenantId,
    @JsonKey(name: 'tenant_name') @Default('') String tenantName,
    @JsonKey(name: 'session_name') @Default('') String sessionName,
    @JsonKey(name: 'phone_number') @Default('') String phoneNumber,
    @Default('NOT_CONNECTED') String status,
  }) = _WhatsAppSession;

  factory WhatsAppSession.fromJson(Map<String, dynamic> json) => _$WhatsAppSessionFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class QRCode with _$QRCode {
  const factory QRCode({
    @Default('image/png') String mimetype,
    @Default('') String data,
  }) = _QRCode;

  factory QRCode.fromJson(Map<String, dynamic> json) => _$QRCodeFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class DailyReport with _$DailyReport {
  const factory DailyReport({
    required String date,
    @JsonKey(name: 'active_members') @Default(0) int activeMembers,
    @JsonKey(name: 'new_members') @Default(0) int newMembers,
    @JsonKey(name: 'expiring_next_7_days') @Default(0) int expiringNext7Days,
    @JsonKey(name: 'expired_today') @Default(0) int expiredToday,
    @Default(0) int renewals,
    @JsonKey(name: 'pending_payments_minor') @Default(0) int pendingPaymentsMinor,
    @JsonKey(name: 'revenue_minor') @Default(0) int revenueMinor,
    @Default(0) int attendance,
  }) = _DailyReport;

  factory DailyReport.fromJson(Map<String, dynamic> json) => _$DailyReportFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class TenantUser with _$TenantUser {
  const factory TenantUser({
    required String id,
    required String name,
    required String email,
    @Default('') String phone,
    required String role,
    @Default('ACTIVE') String status,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
  }) = _TenantUser;

  factory TenantUser.fromJson(Map<String, dynamic> json) => _$TenantUserFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class MessageLog with _$MessageLog {
  const factory MessageLog({
    required String id,
    @JsonKey(name: 'recipient_phone') required String recipientPhone,
    @JsonKey(name: 'recipient_name') @Default('') String recipientName,
    required String category,
    required String body,
    required String status,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _MessageLog;

  factory MessageLog.fromJson(Map<String, dynamic> json) => _$MessageLogFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class AutomationSettings with _$AutomationSettings {
  const factory AutomationSettings({
    @JsonKey(name: 'expiry_enabled') @Default(true) bool expiryEnabled,
    @JsonKey(name: 'expiry_days_before') required List<int> expiryDaysBefore,
    @JsonKey(name: 'holiday_enabled') @Default(true) bool holidayEnabled,
    @JsonKey(name: 'birthday_enabled') @Default(true) bool birthdayEnabled,
    @JsonKey(name: 'campaigns_enabled') @Default(true) bool campaignsEnabled,
    @JsonKey(name: 'daily_report_enabled') @Default(true) bool dailyReportEnabled,
    @JsonKey(name: 'daily_report_phone') @Default('') String dailyReportPhone,
  }) = _AutomationSettings;

  factory AutomationSettings.fromJson(Map<String, dynamic> json) =>
      _$AutomationSettingsFromJson(json);
}
