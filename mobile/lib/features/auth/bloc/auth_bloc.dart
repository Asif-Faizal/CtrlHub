import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/core/network/api_exception.dart';
import 'package:ctrlhub_mobile/core/storage/token_storage.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required ApiClient api, required TokenStorage tokens})
      : _api = api,
        _tokens = tokens,
        super(const AuthState.unknown()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthSessionExpired>(_onExpired);
    on<AuthUserRefreshed>(_onRefreshed);
    api.onSessionExpired = () => add(const AuthSessionExpired());
  }

  final ApiClient _api;
  final TokenStorage _tokens;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final access = await _tokens.access();
    if (access == null || access.isEmpty) {
      emit(const AuthState.unauthenticated());
      return;
    }
    try {
      final user = await _api.me();
      emit(AuthState.authenticated(user));
    } catch (_) {
      await _tokens.clear();
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));
    try {
      final session = await _api.login(event.email.trim(), event.password);
      await _tokens.set(session.accessToken, session.refreshToken);
      emit(AuthState.authenticated(session.user));
    } on ApiException catch (e) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, error: e.toString()));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, error: e.toString()));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    final refresh = await _tokens.refresh();
    if (refresh != null) await _api.logout(refresh);
    await _tokens.clear();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onExpired(AuthSessionExpired event, Emitter<AuthState> emit) async {
    await _tokens.clear();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onRefreshed(AuthUserRefreshed event, Emitter<AuthState> emit) async {
    try {
      final user = await _api.me();
      emit(AuthState.authenticated(user));
    } catch (_) {}
  }
}
