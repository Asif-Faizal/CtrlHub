import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});
  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _search = TextEditingController();
  String _status = '';
  late Future<PageResult> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = sl<ApiClient>().listMembers(search: _search.text, status: _status);

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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(labelText: 'Search', prefixIcon: Icon(Icons.search)),
                  onSubmitted: (_) => setState(_reload),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: '', child: Text('All')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'expired', child: Text('Expired')),
                  DropdownMenuItem(value: 'none', child: Text('No plan')),
                ],
                onChanged: (v) => setState(() { _status = v ?? ''; _reload(); }),
              ),
              IconButton(onPressed: () => context.push('/gym/members/new'), icon: const Icon(Icons.add)),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) return const LoadingView();
              if (snap.hasError) return ErrorView(message: '${snap.error}', onRetry: () => setState(_reload));
              final items = snap.data!.items.map(Member.fromJson).toList();
              if (items.isEmpty) return const PageStateView(message: 'No members found.');
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final m = items[i];
                  return ListTile(
                    title: Text(m.fullName),
                    subtitle: Text('${m.phone} · ${m.currentPlan.isEmpty ? 'No plan' : m.currentPlan}'),
                    trailing: StatusChip(m.membershipStatus),
                    onTap: () => context.push('/gym/members/${m.id}'),
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
