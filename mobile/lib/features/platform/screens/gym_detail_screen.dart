import 'package:flutter/material.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class GymDetailScreen extends StatefulWidget {
  const GymDetailScreen({super.key, required this.id});
  final String id;
  @override
  State<GymDetailScreen> createState() => _GymDetailScreenState();
}

class _GymDetailScreenState extends State<GymDetailScreen> {
  late Future<Map<String, dynamic>> _tenant;
  late Future<List<TenantUser>> _users;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _tenant = sl<ApiClient>().getTenant(widget.id);
    _users = sl<ApiClient>().platformUsers(widget.id);
  }

  Future<void> _toggle(String status) async {
    final next = status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    if (!await confirm(context, 'Change status', 'Set gym to $next?')) return;
    try {
      await sl<ApiClient>().setTenantStatus(widget.id, next);
      setState(_reload);
    } catch (e) {
      if (mounted) await showAppError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_tenant, _users]),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const LoadingView();
        if (snap.hasError) return ErrorView(message: '${snap.error}', onRetry: () => setState(_reload));
        final t = snap.data![0] as Map<String, dynamic>;
        final users = snap.data![1] as List<TenantUser>;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(t['name']?.toString() ?? '', style: Theme.of(context).textTheme.headlineSmall),
            Text('${t['code']} · ${t['city']} · ${t['timezone']}'),
            const SizedBox(height: 8),
            Row(children: [
              StatusChip('${t['status']}'),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: () => _toggle('${t['status']}'), child: Text(t['status'] == 'ACTIVE' ? 'Deactivate' : 'Activate')),
            ]),
            const Divider(height: 32),
            Text('Users', style: Theme.of(context).textTheme.titleMedium),
            ...users.map((u) => ListTile(
                  title: Text(u.name),
                  subtitle: Text('${u.email} · ${u.role}'),
                  trailing: StatusChip(u.status),
                )),
          ],
        );
      },
    );
  }
}
