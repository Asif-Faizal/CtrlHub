import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ctrlhub_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:ctrlhub_mobile/features/auth/screens/account_screen.dart';
import 'package:ctrlhub_mobile/features/auth/screens/login_screen.dart';
import 'package:ctrlhub_mobile/features/auth/screens/setup_password_screen.dart';
import 'package:ctrlhub_mobile/features/gym/screens/screens.dart';
import 'package:ctrlhub_mobile/features/platform/screens/screens.dart';
import 'package:ctrlhub_mobile/shared/widgets/app_shell.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class GoRouterRefresh extends ChangeNotifier {
  GoRouterRefresh(AuthBloc bloc) {
    _sub = bloc.stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<AuthState> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthBloc authBloc) {
  final refresh = GoRouterRefresh(authBloc);
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = authBloc.state;
      final loc = state.matchedLocation;
      final loggingIn = loc == '/login' || loc == '/setup-password';

      if (auth.status == AuthStatus.unknown) return null;
      if (!auth.isAuthenticated) return loggingIn ? null : '/login';
      if (loggingIn) {
        return auth.user!.dashboard == 'platform' ? '/platform' : '/gym';
      }
      if (loc.startsWith('/platform') && auth.user!.dashboard != 'platform') return '/gym';
      if (loc.startsWith('/gym') && auth.user!.dashboard != 'gym') return '/platform';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/setup-password', builder: (_, state) {
        final token = state.uri.queryParameters['token'] ?? '';
        return SetupPasswordScreen(token: token);
      }),
      ShellRoute(
        builder: (context, state, child) => child,
        routes: [
          GoRoute(path: '/account', builder: (_, _) => const AccountScreen()),
          ShellRoute(
            builder: (context, state, child) => AppShell(area: 'platform', child: child),
            routes: [
              GoRoute(path: '/platform', builder: (_, _) => const PlatformOverviewScreen()),
              GoRoute(path: '/platform/gyms', builder: (_, _) => const GymListScreen()),
              GoRoute(path: '/platform/gyms/new', builder: (_, _) => const GymFormScreen()),
              GoRoute(path: '/platform/gyms/:id', builder: (_, state) => GymDetailScreen(id: state.pathParameters['id']!)),
              GoRoute(path: '/platform/whatsapp', builder: (_, _) => const PlatformWhatsAppScreen()),
            ],
          ),
          ShellRoute(
            builder: (context, state, child) => AppShell(area: 'gym', child: child),
            routes: [
              GoRoute(path: '/gym', builder: (_, _) => const GymOverviewScreen()),
              GoRoute(path: '/gym/members', builder: (_, _) => const MembersScreen()),
              GoRoute(path: '/gym/members/new', builder: (_, _) => const MemberFormScreen()),
              GoRoute(path: '/gym/members/:id', builder: (_, state) => MemberProfileScreen(id: state.pathParameters['id']!)),
              GoRoute(path: '/gym/members/:id/edit', builder: (_, state) => MemberFormScreen(id: state.pathParameters['id'])),
              GoRoute(path: '/gym/plans', builder: (_, _) => const PlansScreen()),
              GoRoute(path: '/gym/renewals', builder: (_, _) => const RenewalsScreen()),
              GoRoute(path: '/gym/payments', builder: (_, _) => const PaymentsScreen()),
              GoRoute(path: '/gym/attendance', builder: (_, _) => const AttendanceScreen()),
              GoRoute(path: '/gym/holidays', builder: (_, _) => const HolidaysScreen()),
              GoRoute(path: '/gym/leads', builder: (_, _) => const LeadsScreen()),
              GoRoute(path: '/gym/promotions', builder: (_, _) => const PromotionsScreen()),
              GoRoute(path: '/gym/promotions/:id', builder: (_, state) => PromotionDetailScreen(id: state.pathParameters['id']!)),
              GoRoute(path: '/gym/whatsapp', builder: (_, _) => const WhatsAppScreen()),
              GoRoute(path: '/gym/automation', builder: (_, _) => const AutomationScreen()),
              GoRoute(path: '/gym/messages', builder: (_, _) => const MessagesScreen()),
              GoRoute(path: '/gym/users', builder: (_, _) => const UsersScreen()),
              GoRoute(path: '/gym/settings', builder: (_, _) => const GymSettingsScreen()),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (_, _) => const Scaffold(body: PageStateView(message: 'Page not found.')),
  );
}
