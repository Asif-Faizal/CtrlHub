// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => _UserInfo(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  dashboard: json['dashboard'] as String,
  tenantId: json['tenant_id'] as String?,
  tenantCode: json['tenant_code'] as String?,
  tenantName: json['tenant_name'] as String?,
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$UserInfoToJson(_UserInfo instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role': instance.role,
  'dashboard': instance.dashboard,
  'tenant_id': instance.tenantId,
  'tenant_code': instance.tenantCode,
  'tenant_name': instance.tenantName,
  'permissions': instance.permissions,
};

_Session _$SessionFromJson(Map<String, dynamic> json) => _Session(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
  tokenType: json['token_type'] as String,
  expiresIn: (json['expires_in'] as num).toInt(),
  user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SessionToJson(_Session instance) => <String, dynamic>{
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
  'token_type': instance.tokenType,
  'expires_in': instance.expiresIn,
  'user': instance.user,
};

_PageResult _$PageResultFromJson(Map<String, dynamic> json) => _PageResult(
  items: (json['items'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  total: (json['total'] as num?)?.toInt() ?? 0,
  page: (json['page'] as num?)?.toInt() ?? 1,
  pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
);

Map<String, dynamic> _$PageResultToJson(_PageResult instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'page': instance.page,
      'page_size': instance.pageSize,
    };

_TenantSummary _$TenantSummaryFromJson(Map<String, dynamic> json) =>
    _TenantSummary(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      ownerName: json['owner_name'] as String? ?? '',
      contactNumber: json['contact_number'] as String? ?? '',
      email: json['email'] as String? ?? '',
      city: json['city'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      userCount: (json['user_count'] as num?)?.toInt() ?? 0,
      memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
      whatsappStatus: json['whatsapp_status'] as String? ?? 'NOT_CONNECTED',
    );

Map<String, dynamic> _$TenantSummaryToJson(_TenantSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'owner_name': instance.ownerName,
      'contact_number': instance.contactNumber,
      'email': instance.email,
      'city': instance.city,
      'status': instance.status,
      'user_count': instance.userCount,
      'member_count': instance.memberCount,
      'whatsapp_status': instance.whatsappStatus,
    };

_PlatformStats _$PlatformStatsFromJson(Map<String, dynamic> json) =>
    _PlatformStats(
      totalTenants: (json['total_tenants'] as num?)?.toInt() ?? 0,
      activeTenants: (json['active_tenants'] as num?)?.toInt() ?? 0,
      totalUsers: (json['total_users'] as num?)?.toInt() ?? 0,
      totalMembers: (json['total_members'] as num?)?.toInt() ?? 0,
      whatsappConnected: (json['whatsapp_connected'] as num?)?.toInt() ?? 0,
      messagesLast30Days: (json['messages_last_30_days'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PlatformStatsToJson(_PlatformStats instance) =>
    <String, dynamic>{
      'total_tenants': instance.totalTenants,
      'active_tenants': instance.activeTenants,
      'total_users': instance.totalUsers,
      'total_members': instance.totalMembers,
      'whatsapp_connected': instance.whatsappConnected,
      'messages_last_30_days': instance.messagesLast30Days,
    };

_Member _$MemberFromJson(Map<String, dynamic> json) => _Member(
  id: json['id'] as String,
  fullName: json['full_name'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String? ?? '',
  status: json['status'] as String? ?? 'ACTIVE',
  whatsappOptIn: json['whatsapp_opt_in'] as bool? ?? false,
  marketingOptIn: json['marketing_opt_in'] as bool? ?? false,
  membershipStatus: json['membership_status'] as String? ?? 'NONE',
  currentPlan: json['current_plan'] as String? ?? '',
  expiresOn: json['expires_on'] as String?,
);

Map<String, dynamic> _$MemberToJson(_Member instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'phone': instance.phone,
  'email': instance.email,
  'status': instance.status,
  'whatsapp_opt_in': instance.whatsappOptIn,
  'marketing_opt_in': instance.marketingOptIn,
  'membership_status': instance.membershipStatus,
  'current_plan': instance.currentPlan,
  'expires_on': instance.expiresOn,
};

_MembershipPlan _$MembershipPlanFromJson(Map<String, dynamic> json) =>
    _MembershipPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      durationType: json['duration_type'] as String,
      durationDays: (json['duration_days'] as num?)?.toInt(),
      priceMinor: (json['price_minor'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$MembershipPlanToJson(_MembershipPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'duration_type': instance.durationType,
      'duration_days': instance.durationDays,
      'price_minor': instance.priceMinor,
      'is_active': instance.isActive,
    };

_Membership _$MembershipFromJson(Map<String, dynamic> json) => _Membership(
  id: json['id'] as String,
  memberId: json['member_id'] as String,
  memberName: json['member_name'] as String? ?? '',
  planId: json['plan_id'] as String,
  planName: json['plan_name'] as String? ?? '',
  startDate: json['start_date'] as String,
  endDate: json['end_date'] as String,
  totalAmountMinor: (json['total_amount_minor'] as num?)?.toInt() ?? 0,
  paidAmountMinor: (json['paid_amount_minor'] as num?)?.toInt() ?? 0,
  pendingAmountMinor: (json['pending_amount_minor'] as num?)?.toInt() ?? 0,
  status: json['status'] as String? ?? 'ACTIVE',
  paymentStatus: json['payment_status'] as String? ?? 'UNPAID',
);

Map<String, dynamic> _$MembershipToJson(_Membership instance) =>
    <String, dynamic>{
      'id': instance.id,
      'member_id': instance.memberId,
      'member_name': instance.memberName,
      'plan_id': instance.planId,
      'plan_name': instance.planName,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'total_amount_minor': instance.totalAmountMinor,
      'paid_amount_minor': instance.paidAmountMinor,
      'pending_amount_minor': instance.pendingAmountMinor,
      'status': instance.status,
      'payment_status': instance.paymentStatus,
    };

_Payment _$PaymentFromJson(Map<String, dynamic> json) => _Payment(
  id: json['id'] as String,
  memberId: json['member_id'] as String,
  memberName: json['member_name'] as String? ?? '',
  amountMinor: (json['amount_minor'] as num).toInt(),
  method: json['method'] as String,
  reference: json['reference'] as String? ?? '',
  paidAt: json['paid_at'] as String,
);

Map<String, dynamic> _$PaymentToJson(_Payment instance) => <String, dynamic>{
  'id': instance.id,
  'member_id': instance.memberId,
  'member_name': instance.memberName,
  'amount_minor': instance.amountMinor,
  'method': instance.method,
  'reference': instance.reference,
  'paid_at': instance.paidAt,
};

_Attendance _$AttendanceFromJson(Map<String, dynamic> json) => _Attendance(
  id: json['id'] as String,
  memberId: json['member_id'] as String,
  memberName: json['member_name'] as String? ?? '',
  attendanceDate: json['attendance_date'] as String,
  checkInAt: json['check_in_at'] as String,
);

Map<String, dynamic> _$AttendanceToJson(_Attendance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'member_id': instance.memberId,
      'member_name': instance.memberName,
      'attendance_date': instance.attendanceDate,
      'check_in_at': instance.checkInAt,
    };

_Holiday _$HolidayFromJson(Map<String, dynamic> json) => _Holiday(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  holidayDate: json['holiday_date'] as String,
  notifyEnabled: json['notify_enabled'] as bool? ?? true,
  notifyDaysBefore: (json['notify_days_before'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$HolidayToJson(_Holiday instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'holiday_date': instance.holidayDate,
  'notify_enabled': instance.notifyEnabled,
  'notify_days_before': instance.notifyDaysBefore,
};

_Lead _$LeadFromJson(Map<String, dynamic> json) => _Lead(
  id: json['id'] as String,
  fullName: json['full_name'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String? ?? '',
  source: json['source'] as String? ?? '',
  status: json['status'] as String? ?? 'NEW',
  whatsappOptIn: json['whatsapp_opt_in'] as bool? ?? false,
  marketingOptIn: json['marketing_opt_in'] as bool? ?? false,
);

Map<String, dynamic> _$LeadToJson(_Lead instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'phone': instance.phone,
  'email': instance.email,
  'source': instance.source,
  'status': instance.status,
  'whatsapp_opt_in': instance.whatsappOptIn,
  'marketing_opt_in': instance.marketingOptIn,
};

_Campaign _$CampaignFromJson(Map<String, dynamic> json) => _Campaign(
  id: json['id'] as String,
  name: json['name'] as String,
  message: json['message'] as String,
  audience: json['audience'] as String,
  status: json['status'] as String? ?? 'DRAFT',
  recipientsTotal: (json['recipients_total'] as num?)?.toInt() ?? 0,
  sentCount: (json['sent_count'] as num?)?.toInt() ?? 0,
  failedCount: (json['failed_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CampaignToJson(_Campaign instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'message': instance.message,
  'audience': instance.audience,
  'status': instance.status,
  'recipients_total': instance.recipientsTotal,
  'sent_count': instance.sentCount,
  'failed_count': instance.failedCount,
};

_WhatsAppSession _$WhatsAppSessionFromJson(Map<String, dynamic> json) =>
    _WhatsAppSession(
      tenantId: json['tenant_id'] as String? ?? '',
      tenantName: json['tenant_name'] as String? ?? '',
      sessionName: json['session_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      status: json['status'] as String? ?? 'NOT_CONNECTED',
    );

Map<String, dynamic> _$WhatsAppSessionToJson(_WhatsAppSession instance) =>
    <String, dynamic>{
      'tenant_id': instance.tenantId,
      'tenant_name': instance.tenantName,
      'session_name': instance.sessionName,
      'phone_number': instance.phoneNumber,
      'status': instance.status,
    };

_QRCode _$QRCodeFromJson(Map<String, dynamic> json) => _QRCode(
  mimetype: json['mimetype'] as String? ?? 'image/png',
  data: json['data'] as String? ?? '',
);

Map<String, dynamic> _$QRCodeToJson(_QRCode instance) => <String, dynamic>{
  'mimetype': instance.mimetype,
  'data': instance.data,
};

_DailyReport _$DailyReportFromJson(Map<String, dynamic> json) => _DailyReport(
  date: json['date'] as String,
  activeMembers: (json['active_members'] as num?)?.toInt() ?? 0,
  newMembers: (json['new_members'] as num?)?.toInt() ?? 0,
  expiringNext7Days: (json['expiring_next_7_days'] as num?)?.toInt() ?? 0,
  expiredToday: (json['expired_today'] as num?)?.toInt() ?? 0,
  renewals: (json['renewals'] as num?)?.toInt() ?? 0,
  pendingPaymentsMinor: (json['pending_payments_minor'] as num?)?.toInt() ?? 0,
  revenueMinor: (json['revenue_minor'] as num?)?.toInt() ?? 0,
  attendance: (json['attendance'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$DailyReportToJson(_DailyReport instance) =>
    <String, dynamic>{
      'date': instance.date,
      'active_members': instance.activeMembers,
      'new_members': instance.newMembers,
      'expiring_next_7_days': instance.expiringNext7Days,
      'expired_today': instance.expiredToday,
      'renewals': instance.renewals,
      'pending_payments_minor': instance.pendingPaymentsMinor,
      'revenue_minor': instance.revenueMinor,
      'attendance': instance.attendance,
    };

_TenantUser _$TenantUserFromJson(Map<String, dynamic> json) => _TenantUser(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String? ?? '',
  role: json['role'] as String,
  status: json['status'] as String? ?? 'ACTIVE',
  isPrimary: json['is_primary'] as bool? ?? false,
);

Map<String, dynamic> _$TenantUserToJson(_TenantUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'role': instance.role,
      'status': instance.status,
      'is_primary': instance.isPrimary,
    };

_MessageLog _$MessageLogFromJson(Map<String, dynamic> json) => _MessageLog(
  id: json['id'] as String,
  recipientPhone: json['recipient_phone'] as String,
  recipientName: json['recipient_name'] as String? ?? '',
  category: json['category'] as String,
  body: json['body'] as String,
  status: json['status'] as String,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$MessageLogToJson(_MessageLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipient_phone': instance.recipientPhone,
      'recipient_name': instance.recipientName,
      'category': instance.category,
      'body': instance.body,
      'status': instance.status,
      'created_at': instance.createdAt,
    };

_AutomationSettings _$AutomationSettingsFromJson(Map<String, dynamic> json) =>
    _AutomationSettings(
      expiryEnabled: json['expiry_enabled'] as bool? ?? true,
      expiryDaysBefore: (json['expiry_days_before'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      holidayEnabled: json['holiday_enabled'] as bool? ?? true,
      birthdayEnabled: json['birthday_enabled'] as bool? ?? true,
      campaignsEnabled: json['campaigns_enabled'] as bool? ?? true,
      dailyReportEnabled: json['daily_report_enabled'] as bool? ?? true,
      dailyReportPhone: json['daily_report_phone'] as String? ?? '',
    );

Map<String, dynamic> _$AutomationSettingsToJson(_AutomationSettings instance) =>
    <String, dynamic>{
      'expiry_enabled': instance.expiryEnabled,
      'expiry_days_before': instance.expiryDaysBefore,
      'holiday_enabled': instance.holidayEnabled,
      'birthday_enabled': instance.birthdayEnabled,
      'campaigns_enabled': instance.campaignsEnabled,
      'daily_report_enabled': instance.dailyReportEnabled,
      'daily_report_phone': instance.dailyReportPhone,
    };
