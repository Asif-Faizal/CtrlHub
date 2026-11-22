import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/core/storage/token_storage.dart';
import 'package:ctrlhub_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';

class _MockApi extends Mock implements ApiClient {}

class _MockTokens extends Mock implements TokenStorage {}

void main() {
  late _MockApi api;
  late _MockTokens tokens;

  const user = UserInfo(
    id: 'u1',
    name: 'Admin',
    email: 'admin@ctrlhub.local',
    role: 'PLATFORM_ADMIN',
    dashboard: 'platform',
    permissions: ['platform.manage'],
  );

  setUp(() {
    api = _MockApi();
    tokens = _MockTokens();
  });

  blocTest<AuthBloc, AuthState>(
    'starts unauthenticated when no tokens',
    build: () {
      when(() => tokens.access()).thenAnswer((_) async => null);
      return AuthBloc(api: api, tokens: tokens);
    },
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => [const AuthState.unauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'login stores tokens and authenticates',
    build: () {
      when(() => tokens.set(any(), any())).thenAnswer((_) async {});
      when(() => api.login(any(), any())).thenAnswer(
        (_) async => const Session(
          accessToken: 'a',
          refreshToken: 'r',
          tokenType: 'Bearer',
          expiresIn: 900,
          user: user,
        ),
      );
      return AuthBloc(api: api, tokens: tokens);
    },
    act: (bloc) => bloc.add(const AuthLoginRequested('admin@ctrlhub.local', 'secret')),
    expect: () => [
      isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
      isA<AuthState>()
          .having((s) => s.status, 'status', AuthStatus.authenticated)
          .having((s) => s.user?.email, 'email', 'admin@ctrlhub.local'),
    ],
  );
}
