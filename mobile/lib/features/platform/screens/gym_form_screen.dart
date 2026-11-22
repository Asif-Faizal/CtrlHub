import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class GymFormScreen extends StatefulWidget {
  const GymFormScreen({super.key});
  @override
  State<GymFormScreen> createState() => _GymFormScreenState();
}

class _GymFormScreenState extends State<GymFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _owner = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController();
  final _adminName = TextEditingController();
  final _adminEmail = TextEditingController();
  final _adminPhone = TextEditingController();
  String _timezone = 'Asia/Kolkata';
  bool _busy = false;
  String? _setupUrl;

  @override
  void dispose() {
    for (final c in [_name, _owner, _phone, _email, _city, _adminName, _adminEmail, _adminPhone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final res = await sl<ApiClient>().onboardTenant({
        'gym': {
          'name': _name.text.trim(),
          'owner_name': _owner.text.trim(),
          'contact_number': _phone.text.trim(),
          'email': _email.text.trim(),
          'city': _city.text.trim(),
          'timezone': _timezone,
          'country': 'India',
          'currency': 'INR',
        },
        'admin': {
          'name': _adminName.text.trim(),
          'email': _adminEmail.text.trim(),
          'phone': _adminPhone.text.trim(),
        },
      });
      if (!mounted) return;
      setState(() => _setupUrl = res['setup_url']?.toString());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gym onboarded')));
      if (_setupUrl == null) context.go('/platform/gyms');
    } catch (e) {
      if (mounted) await showAppError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_setupUrl != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share this one-time setup link with the gym admin:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SelectableText(_setupUrl!),
            const SizedBox(height: 20),
            FilledButton(onPressed: () => context.go('/platform/gyms'), child: const Text('Done')),
          ],
        ),
      );
    }
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Gym details', style: Theme.of(context).textTheme.titleMedium),
          TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Gym name'), validator: (v) => v!.isEmpty ? 'Required' : null),
          TextFormField(controller: _owner, decoration: const InputDecoration(labelText: 'Owner name'), validator: (v) => v!.isEmpty ? 'Required' : null),
          TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Contact number'), validator: (v) => v!.isEmpty ? 'Required' : null),
          TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v!.isEmpty ? 'Required' : null),
          TextFormField(controller: _city, decoration: const InputDecoration(labelText: 'City')),
          DropdownButtonFormField<String>(
            value: _timezone,
            items: const [
              DropdownMenuItem(value: 'Asia/Kolkata', child: Text('Asia/Kolkata')),
              DropdownMenuItem(value: 'UTC', child: Text('UTC')),
            ],
            onChanged: (v) => setState(() => _timezone = v ?? 'Asia/Kolkata'),
            decoration: const InputDecoration(labelText: 'Timezone'),
          ),
          const SizedBox(height: 16),
          Text('Primary admin', style: Theme.of(context).textTheme.titleMedium),
          TextFormField(controller: _adminName, decoration: const InputDecoration(labelText: 'Admin name'), validator: (v) => v!.isEmpty ? 'Required' : null),
          TextFormField(controller: _adminEmail, decoration: const InputDecoration(labelText: 'Admin email'), validator: (v) => v!.isEmpty ? 'Required' : null),
          TextFormField(controller: _adminPhone, decoration: const InputDecoration(labelText: 'Admin phone')),
          const SizedBox(height: 20),
          FilledButton(onPressed: _busy ? null : _submit, child: const Text('Create gym')),
        ],
      ),
    );
  }
}
