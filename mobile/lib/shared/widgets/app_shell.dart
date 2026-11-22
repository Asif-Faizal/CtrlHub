import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ctrlhub_mobile/features/auth/bloc/auth_bloc.dart';

class NavItem {
  const NavItem(this.label, this.path, this.icon, {this.permission});
  final String label;
  final String path;
  final IconData icon;
  final String? permission;
}

List<NavItem> platformNav() => const [
      NavItem('Overview', '/platform', Icons.dashboard_outlined),
      NavItem('Gyms', '/platform/gyms', Icons.fitness_center),
      NavItem('WhatsApp', '/platform/whatsapp', Icons.chat_outlined),
    ];

List<NavItem> gymNav(AuthState auth) {
  const all = [
    NavItem('Overview', '/gym', Icons.dashboard_outlined, permission: 'tenant.read'),
    NavItem('Members', '/gym/members', Icons.people_outline, permission: 'members.read'),
    NavItem('Plans', '/gym/plans', Icons.card_membership, permission: 'plans.read'),
    NavItem('Renewals', '/gym/renewals', Icons.autorenew, permission: 'memberships.read'),
    NavItem('Payments', '/gym/payments', Icons.payments_outlined, permission: 'payments.read'),
    NavItem('Attendance', '/gym/attendance', Icons.fact_check_outlined, permission: 'attendance.read'),
    NavItem('Holidays', '/gym/holidays', Icons.event_outlined, permission: 'holidays.read'),
    NavItem('Leads', '/gym/leads', Icons.person_search_outlined, permission: 'leads.read'),
    NavItem('Promotions', '/gym/promotions', Icons.campaign_outlined, permission: 'campaigns.read'),
    NavItem('WhatsApp', '/gym/whatsapp', Icons.chat_outlined, permission: 'whatsapp.read'),
    NavItem('Automation', '/gym/automation', Icons.smart_toy_outlined, permission: 'automation.manage'),
    NavItem('Messages', '/gym/messages', Icons.mail_outline, permission: 'messages.read'),
    NavItem('Users', '/gym/users', Icons.manage_accounts_outlined, permission: 'users.manage'),
    NavItem('Settings', '/gym/settings', Icons.settings_outlined, permission: 'tenant.read'),
  ];
  return all.where((n) => n.permission == null || auth.can(n.permission!)).toList();
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.area, required this.child});
  final String area;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final items = area == 'platform' ? platformNav() : gymNav(auth);
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(auth.user?.tenantName ?? (area == 'platform' ? 'CtrlHub Platform' : 'CtrlHub')),
        actions: [
          IconButton(
            tooltip: 'Account',
            onPressed: () => context.push('/account'),
            icon: const Icon(Icons.account_circle_outlined),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auth.user?.name ?? '', style: Theme.of(context).textTheme.titleLarge),
                    Text(auth.user?.email ?? ''),
                    Text(auth.user?.role ?? '', style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ),
              for (final item in items)
                ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.label),
                  selected: location == item.path || (item.path != '/gym' && item.path != '/platform' && location.startsWith(item.path)),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(item.path);
                  },
                ),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}
