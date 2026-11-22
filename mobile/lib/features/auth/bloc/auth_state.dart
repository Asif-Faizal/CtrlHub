part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthState extends Equatable {
  const AuthState({required this.status, this.user, this.error});

  const AuthState.unknown() : this(status: AuthStatus.unknown);
  const AuthState.unauthenticated({String? error})
      : this(status: AuthStatus.unauthenticated, error: error);
  const AuthState.authenticated(UserInfo user)
      : this(status: AuthStatus.authenticated, user: user);

  final AuthStatus status;
  final UserInfo? user;
  final String? error;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool can(String permission) => user?.permissions.contains(permission) ?? false;

  AuthState copyWith({AuthStatus? status, UserInfo? user, String? error}) => AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error,
      );

  @override
  List<Object?> get props => [status, user, error];
}
