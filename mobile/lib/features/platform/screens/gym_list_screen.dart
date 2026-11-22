import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class GymListScreen extends StatefulWidget {
  const GymListScreen({super.key});
  @override
  State<GymListScreen> createState() => _GymListScreenState();
}

class _GymListScreenState extends State<GymListScreen> {
  final _search = TextEditingController();
  late Future<PageResult> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = sl<ApiClient>().listTenants(search: _search.text);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(labelText: 'Search gyms', prefixIcon: Icon(Icons.search)),
                  onSubmitted: (_) => setState(_reload),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => context.push('/platform/gyms/new'),
                icon: const Icon(Icons.add),
                label: const Text('Onboard'),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<PageResult>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) return const LoadingView();
              if (snap.hasError) return ErrorView(message: '${snap.error}', onRetry: () => setState(_reload));
              final items = snap.data!.items.map(TenantSummary.fromJson).toList();
              if (items.isEmpty) return const PageStateView(message: 'No gyms yet.');
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final t = items[i];
                  return ListTile(
                    title: Text(t.name),
                    subtitle: Text('${t.code} · ${t.city} · ${t.memberCount} members'),
                    trailing: StatusChip(t.status),
                    onTap: () => context.push('/platform/gyms/${t.id}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
