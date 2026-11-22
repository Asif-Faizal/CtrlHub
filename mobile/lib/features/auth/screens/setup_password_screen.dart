import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class SetupPasswordScreen extends StatefulWidget {
  const SetupPasswordScreen({super.key, required this.token});
  final String token;
  @override
  State<SetupPasswordScreen> createState() => _SetupPasswordScreenState();
}

class _SetupPasswordScreenState extends State<SetupPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_password.text.length < 8) {
      await showAppError(context, 'Password must be at least 8 characters');
      return;
    }
    if (_password.text != _confirm.text) {
      await showAppError(context, 'Passwords do not match');
      return;
    }
    setState(() => _busy = true);
    try {
      await sl<ApiClient>().setupPassword(widget.token, _password.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password set. Please sign in.')));
      context.go('/login');
    } catch (e) {
      if (mounted) await showAppError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
            const SizedBox(height: 12),
            TextField(controller: _confirm, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm password')),
            const SizedBox(height: 20),
            FilledButton(onPressed: _busy ? null : _submit, child: const Text('Save password')),
          ],
        ),
      ),
    );
  }
}
