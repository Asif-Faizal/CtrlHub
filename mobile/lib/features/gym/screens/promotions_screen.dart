import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});
  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  late Future<List<Campaign>> _future;
  @override
  void initState() {
    super.initState();
    _future = sl<ApiClient>().listCampaigns();
  }

  Future<void> _create() async {
    final name = TextEditingController();
    final message = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New promotion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: message, decoration: const InputDecoration(labelText: 'Message'), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final c = await sl<ApiClient>().createCampaign({
        'name': name.text.trim(),
        'message': message.text.trim(),
        'audience': 'ACTIVE_MEMBERS',
        'audience_params': {},
      });
      if (mounted) context.push('/gym/promotions/${c.id}');
    } catch (e) {
      if (mounted) await showAppError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _create, child: const Icon(Icons.add)),
      body: FutureBuilder(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const LoadingView();
          if (snap.hasError) return ErrorView(message: '${snap.error}', onRetry: () => setState(() => _future = sl<ApiClient>().listCampaigns()));
          final items = snap.data!;
          if (items.isEmpty) return const PageStateView(message: 'No promotions yet.');
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = items[i];
              return ListTile(
                title: Text(c.name),
                subtitle: Text('${c.audience} · sent ${c.sentCount}/${c.recipientsTotal}'),
                trailing: StatusChip(c.status),
                onTap: () => context.push('/gym/promotions/${c.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
