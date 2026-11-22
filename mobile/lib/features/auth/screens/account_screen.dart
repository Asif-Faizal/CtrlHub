import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _change() async {
    setState(() => _busy = true);
    try {
      await sl<ApiClient>().changePassword(_current.text, _next.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed')));
      _current.clear();
      _next.clear();
    } catch (e) {
      if (mounted) await showAppError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    return AppScaffold(
      title: 'Account',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: const Text('Name'), subtitle: Text(user?.name ?? '')),
          ListTile(title: const Text('Email'), subtitle: Text(user?.email ?? '')),
          ListTile(title: const Text('Role'), subtitle: Text(user?.role ?? '')),
          const Divider(),
          Text('Change password', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(controller: _current, obscureText: true, decoration: const InputDecoration(labelText: 'Current password')),
          const SizedBox(height: 8),
          TextField(controller: _next, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
          const SizedBox(height: 12),
          FilledButton(onPressed: _busy ? null : _change, child: const Text('Update password')),
        ],
      ),
    );
  }
}
