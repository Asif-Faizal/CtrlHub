import 'package:flutter/material.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late Future<List<TenantUser>> _future;
  @override
  void initState() {
    super.initState();
    _future = sl<ApiClient>().gymUsers();
  }

  Future<void> _create() async {
    final name = TextEditingController();
    final email = TextEditingController();
    String role = 'RECEPTIONIST';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add user'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            DropdownButtonFormField(
              initialValue: role,
              items: const [
                DropdownMenuItem(value: 'GYM_ADMIN', child: Text('Admin')),
                DropdownMenuItem(value: 'GYM_MANAGER', child: Text('Manager')),
                DropdownMenuItem(value: 'RECEPTIONIST', child: Text('Receptionist')),
                DropdownMenuItem(value: 'TRAINER', child: Text('Trainer')),
              ],
              onChanged: (v) => role = v as String,
            ),
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
      final res = await sl<ApiClient>().createGymUser({
        'name': name.text.trim(),
        'email': email.text.trim(),
        'role': role,
      });
      if (mounted) {
        final url = res['setup_url'];
        if (url != null) {
          await showDialog(context: context, builder: (ctx) => AlertDialog(
            title: const Text('Setup link'),
            content: SelectableText('$url'),
            actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
          ));
        }
      }
      setState(() => _future = sl<ApiClient>().gymUsers());
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
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final u = items[i];
              return ListTile(
                title: Text(u.name),
                subtitle: Text('${u.email} · ${u.role}'),
                trailing: StatusChip(u.status),
              );
            },
          );
        },
      ),
    );
  }
}
