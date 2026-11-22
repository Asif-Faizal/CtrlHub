import 'package:flutter/material.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});
  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  late Future<List<Lead>> _future;
  @override
  void initState() {
    super.initState();
    _future = sl<ApiClient>().listLeads();
  }

  Future<void> _create() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New lead'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone')),
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
      await sl<ApiClient>().createLead({
        'full_name': name.text.trim(),
        'phone': phone.text.trim(),
        'whatsapp_opt_in': true,
        'marketing_opt_in': true,
      });
      setState(() => _future = sl<ApiClient>().listLeads());
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
          if (snap.hasError) return ErrorView(message: '${snap.error}');
          final items = snap.data!;
          if (items.isEmpty) return const PageStateView(message: 'No leads.');
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final l = items[i];
              return ListTile(title: Text(l.fullName), subtitle: Text(l.phone), trailing: StatusChip(l.status));
            },
          );
        },
      ),
    );
  }
}
