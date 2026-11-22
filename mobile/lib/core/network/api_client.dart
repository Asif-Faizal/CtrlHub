import 'dart:async';

import 'package:dio/dio.dart';
import 'package:ctrlhub_mobile/core/network/api_exception.dart';
import 'package:ctrlhub_mobile/core/storage/token_storage.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';

typedef SessionExpiredCallback = void Function();

class ApiClient {
  ApiClient({
    required TokenStorage tokens,
    required String baseUrl,
    Dio? dio,
  })  : _tokens = tokens,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokens.access();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final path = error.requestOptions.path;
        final retried = error.requestOptions.extra['_retried'] == true;
        final isAuth = path.contains('/auth/');
        if (status == 401 && !retried && !isAuth) {
          final access = await _refresh();
          if (access != null) {
            final req = error.requestOptions;
            req.headers['Authorization'] = 'Bearer $access';
            req.extra['_retried'] = true;
            try {
              final res = await _dio.fetch(req);
              return handler.resolve(res);
            } catch (e) {
              if (e is DioException) return handler.next(e);
              return handler.next(error);
            }
          }
          onSessionExpired?.call();
        }
        handler.next(error);
      },
    ));
  }

  final Dio _dio;
  final TokenStorage _tokens;
  SessionExpiredCallback? onSessionExpired;
  Future<String?>? _refreshing;

  Future<String?> _refresh() {
    _refreshing ??= () async {
      final refresh = await _tokens.refresh();
      if (refresh == null || refresh.isEmpty) {
        await _tokens.clear();
        return null;
      }
      try {
        final res = await _dio.post<Map<String, dynamic>>(
          '/auth/refresh',
          data: {'refresh_token': refresh},
        );
        final session = Session.fromJson(res.data!);
        await _tokens.set(session.accessToken, session.refreshToken);
        return session.accessToken;
      } catch (_) {
        await _tokens.clear();
        return null;
      } finally {
        _refreshing = null;
      }
    }();
    return _refreshing!;
  }

  Never _throw(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] is Map) {
      final err = data['error'] as Map;
      final details = <String, String>{};
      final raw = err['details'];
      if (raw is Map) {
        raw.forEach((k, v) => details['$k'] = '$v');
      }
      throw ApiException(
        '${err['message'] ?? 'Request failed'}',
        code: err['code']?.toString(),
        details: details,
        statusCode: e.response?.statusCode,
      );
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      throw ApiException('Cannot reach the server. Check your connection.');
    }
    throw ApiException('Request failed (${e.response?.statusCode ?? 'network'})');
  }

  Future<T> _get<T>(String path, T Function(dynamic) parse, {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      return parse(res.data);
    } on DioException catch (e) {
      _throw(e);
    }
  }

  Future<T> _send<T>(
    String method,
    String path,
    T Function(dynamic) parse, {
    Object? data,
  }) async {
    try {
      final res = await _dio.request(path, data: data, options: Options(method: method));
      return parse(res.data);
    } on DioException catch (e) {
      _throw(e);
    }
  }

  List<T> _list<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    final list = data is List ? data : (data is Map ? data['items'] as List? ?? [] : []);
    return list.map((e) => fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  // Auth
  Future<Session> login(String email, String password) => _send(
        'POST',
        '/auth/login',
        (d) => Session.fromJson(Map<String, dynamic>.from(d as Map)),
        data: {'email': email, 'password': password},
      );

  Future<UserInfo> me() => _get('/auth/me', (d) => UserInfo.fromJson(Map<String, dynamic>.from(d as Map)));

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post('/auth/logout', data: {'refresh_token': refreshToken});
    } catch (_) {}
  }

  Future<void> setupPassword(String token, String password) => _send(
        'POST',
        '/auth/setup-password',
        (_) {},
        data: {'token': token, 'password': password},
      );

  Future<void> changePassword(String current, String next) => _send(
        'POST',
        '/auth/change-password',
        (_) {},
        data: {'current_password': current, 'new_password': next},
      );

  // Platform
  Future<PlatformStats> platformStats() =>
      _get('/platform/stats', (d) => PlatformStats.fromJson(Map<String, dynamic>.from(d as Map)));

  Future<PageResult> listTenants({String? search, String? status, int page = 1}) => _get(
        '/platform/tenants',
        (d) => PageResult.fromJson(Map<String, dynamic>.from(d as Map)),
        query: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
          'page': page,
          'page_size': 20,
        },
      );

  Future<Map<String, dynamic>> getTenant(String id) =>
      _get('/platform/tenants/$id', (d) => Map<String, dynamic>.from(d as Map));

  Future<Map<String, dynamic>> onboardTenant(Map<String, dynamic> body) =>
      _send('POST', '/platform/tenants', (d) => Map<String, dynamic>.from(d as Map), data: body);

  Future<Map<String, dynamic>> updateTenant(String id, Map<String, dynamic> body) =>
      _send('PATCH', '/platform/tenants/$id', (d) => Map<String, dynamic>.from(d as Map), data: body);

  Future<Map<String, dynamic>> setTenantStatus(String id, String status) => _send(
        'PATCH',
        '/platform/tenants/$id/status',
        (d) => Map<String, dynamic>.from(d as Map),
        data: {'status': status},
      );

  Future<List<TenantUser>> platformUsers(String tenantId) =>
      _get('/platform/tenants/$tenantId/users', (d) => _list(d, TenantUser.fromJson));

  Future<List<WhatsAppSession>> platformWhatsApp() =>
      _get('/platform/whatsapp-sessions', (d) => _list(d, WhatsAppSession.fromJson));

  // Gym profile / report
  Future<Map<String, dynamic>> gymProfile() =>
      _get('/gym/profile', (d) => Map<String, dynamic>.from(d as Map));

  Future<Map<String, dynamic>> updateGymProfile(Map<String, dynamic> body) =>
      _send('PUT', '/gym/profile', (d) => Map<String, dynamic>.from(d as Map), data: body);

  Future<DailyReport> dailyReport({String? date}) => _get(
        '/gym/reports/daily',
        (d) => DailyReport.fromJson(Map<String, dynamic>.from(d as Map)),
        query: {if (date != null) 'date': date},
      );

  // Members
  Future<PageResult> listMembers({String? search, String? status, int page = 1}) => _get(
        '/gym/members',
        (d) => PageResult.fromJson(Map<String, dynamic>.from(d as Map)),
        query: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
          'page': page,
          'page_size': 20,
        },
      );

  Future<Member> getMember(String id) =>
      _get('/gym/members/$id', (d) => Member.fromJson(Map<String, dynamic>.from(d as Map)));

  Future<Member> createMember(Map<String, dynamic> body) =>
      _send('POST', '/gym/members', (d) => Member.fromJson(Map<String, dynamic>.from(d as Map)), data: body);

  Future<Member> updateMember(String id, Map<String, dynamic> body) =>
      _send('PUT', '/gym/members/$id', (d) => Member.fromJson(Map<String, dynamic>.from(d as Map)), data: body);

  // Plans / memberships / payments
  Future<List<MembershipPlan>> listPlans({bool activeOnly = false}) => _get(
        '/gym/plans',
        (d) => _list(d, MembershipPlan.fromJson),
        query: {if (activeOnly) 'active': 'true'},
      );

  Future<MembershipPlan> createPlan(Map<String, dynamic> body) => _send(
        'POST',
        '/gym/plans',
        (d) => MembershipPlan.fromJson(Map<String, dynamic>.from(d as Map)),
        data: body,
      );

  Future<MembershipPlan> updatePlan(String id, Map<String, dynamic> body) => _send(
        'PUT',
        '/gym/plans/$id',
        (d) => MembershipPlan.fromJson(Map<String, dynamic>.from(d as Map)),
        data: body,
      );

  Future<PageResult> listMemberships({String view = 'all', int page = 1, int days = 0}) => _get(
        '/gym/memberships',
        (d) => PageResult.fromJson(Map<String, dynamic>.from(d as Map)),
        query: {'view': view, 'page': page, 'page_size': 20, if (days > 0) 'days': days},
      );

  Future<Membership> assignMembership(Map<String, dynamic> body) => _send(
        'POST',
        '/gym/memberships',
        (d) => Membership.fromJson(Map<String, dynamic>.from(d as Map)),
        data: body,
      );

  Future<Membership> renewMembership(String id, Map<String, dynamic> body) => _send(
        'POST',
        '/gym/memberships/$id/renew',
        (d) => Membership.fromJson(Map<String, dynamic>.from(d as Map)),
        data: body,
      );

  Future<PageResult> listPayments({int page = 1}) => _get(
        '/gym/payments',
        (d) => PageResult.fromJson(Map<String, dynamic>.from(d as Map)),
        query: {'page': page, 'page_size': 20},
      );

  Future<Payment> recordPayment(Map<String, dynamic> body) => _send(
        'POST',
        '/gym/payments',
        (d) => Payment.fromJson(Map<String, dynamic>.from(d as Map)),
        data: body,
      );

  // Attendance / holidays / leads
  Future<List<Attendance>> listAttendance({String? date}) => _get(
        '/gym/attendance',
        (d) => _list(d, Attendance.fromJson),
        query: {if (date != null) 'date': date},
      );

  Future<Attendance> checkIn(String memberId, {bool allowExpired = false}) => _send(
        'POST',
        '/gym/attendance',
        (d) => Attendance.fromJson(Map<String, dynamic>.from(d as Map)),
        data: {'member_id': memberId, 'allow_expired': allowExpired},
      );

  Future<List<Holiday>> listHolidays() => _get('/gym/holidays', (d) => _list(d, Holiday.fromJson));

  Future<Holiday> createHoliday(Map<String, dynamic> body) =>
      _send('POST', '/gym/holidays', (d) => Holiday.fromJson(Map<String, dynamic>.from(d as Map)), data: body);

  Future<List<Lead>> listLeads({String? status}) => _get(
        '/gym/leads',
        (d) => _list(d, Lead.fromJson),
        query: {if (status != null && status.isNotEmpty) 'status': status},
      );

  Future<Lead> createLead(Map<String, dynamic> body) =>
      _send('POST', '/gym/leads', (d) => Lead.fromJson(Map<String, dynamic>.from(d as Map)), data: body);

  Future<Lead> updateLead(String id, Map<String, dynamic> body) =>
      _send('PUT', '/gym/leads/$id', (d) => Lead.fromJson(Map<String, dynamic>.from(d as Map)), data: body);

  // Campaigns
  Future<List<Campaign>> listCampaigns() => _get('/gym/campaigns', (d) => _list(d, Campaign.fromJson));

  Future<Campaign> getCampaign(String id) =>
      _get('/gym/campaigns/$id', (d) => Campaign.fromJson(Map<String, dynamic>.from(d as Map)));

  Future<Campaign> createCampaign(Map<String, dynamic> body) =>
      _send('POST', '/gym/campaigns', (d) => Campaign.fromJson(Map<String, dynamic>.from(d as Map)), data: body);

  Future<Campaign> submitCampaign(String id) =>
      _send('POST', '/gym/campaigns/$id/submit', (d) => Campaign.fromJson(Map<String, dynamic>.from(d as Map)));

  Future<Campaign> approveCampaign(String id) =>
      _send('POST', '/gym/campaigns/$id/approve', (d) => Campaign.fromJson(Map<String, dynamic>.from(d as Map)));

  Future<Campaign> rejectCampaign(String id, String reason) => _send(
        'POST',
        '/gym/campaigns/$id/reject',
        (d) => Campaign.fromJson(Map<String, dynamic>.from(d as Map)),
        data: {'reason': reason},
      );

  // WhatsApp / automation / messages / users
  Future<Map<String, dynamic>> whatsappStatus() =>
      _get('/gym/whatsapp', (d) => Map<String, dynamic>.from(d as Map));

  Future<WhatsAppSession> whatsappConnect() =>
      _send('POST', '/gym/whatsapp/connect', (d) => WhatsAppSession.fromJson(Map<String, dynamic>.from(d as Map)));

  Future<QRCode> whatsappQR() =>
      _get('/gym/whatsapp/qr', (d) => QRCode.fromJson(Map<String, dynamic>.from(d as Map)));

  Future<WhatsAppSession> whatsappDisconnect() => _send(
        'POST',
        '/gym/whatsapp/disconnect',
        (d) => WhatsAppSession.fromJson(Map<String, dynamic>.from(d as Map)),
      );

  Future<MessageLog> whatsappTest(String phone, String text) => _send(
        'POST',
        '/gym/whatsapp/test-message',
        (d) => MessageLog.fromJson(Map<String, dynamic>.from(d as Map)),
        data: {'phone': phone, 'text': text},
      );

  Future<AutomationSettings> automationSettings() => _get(
        '/gym/automation-settings',
        (d) => AutomationSettings.fromJson(Map<String, dynamic>.from(d as Map)),
      );

  Future<AutomationSettings> updateAutomationSettings(Map<String, dynamic> body) => _send(
        'PUT',
        '/gym/automation-settings',
        (d) => AutomationSettings.fromJson(Map<String, dynamic>.from(d as Map)),
        data: body,
      );

  Future<PageResult> listMessages({int page = 1}) => _get(
        '/gym/messages',
        (d) => PageResult.fromJson(Map<String, dynamic>.from(d as Map)),
        query: {'page': page, 'page_size': 20},
      );

  Future<List<TenantUser>> gymUsers() => _get('/gym/users', (d) => _list(d, TenantUser.fromJson));

  Future<Map<String, dynamic>> createGymUser(Map<String, dynamic> body) =>
      _send('POST', '/gym/users', (d) => Map<String, dynamic>.from(d as Map), data: body);
}
