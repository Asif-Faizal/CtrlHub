import 'package:flutter/material.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class GymSettingsScreen extends StatefulWidget {
  const GymSettingsScreen({super.key});
  @override
  State<GymSettingsScreen> createState() => _GymSettingsScreenState();
}

class _GymSettingsScreenState extends State<GymSettingsScreen> {
  final _name = TextEditingController();
  final _owner = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController();
  String _timezone = 'Asia/Kolkata';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final t = await sl<ApiClient>().gymProfile();
      _name.text = '${t['name'] ?? ''}';
      _owner.text = '${t['owner_name'] ?? ''}';
      _phone.text = '${t['contact_number'] ?? ''}';
      _email.text = '${t['email'] ?? ''}';
      _city.text = '${t['city'] ?? ''}';
      _timezone = '${t['timezone'] ?? 'Asia/Kolkata'}';
    } catch (e) {
      if (mounted) await showAppError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    try {
      await sl<ApiClient>().updateGymProfile({
        'name': _name.text.trim(),
        'owner_name': _owner.text.trim(),
        'contact_number': _phone.text.trim(),
        'email': _email.text.trim(),
        'city': _city.text.trim(),
        'timezone': _timezone,
        'address': '',
        'state': '',
        'country': 'India',
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
    } catch (e) {
      if (mounted) await showAppError(context, e);
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _owner, _phone, _email, _city]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(controller: _name, decoration: const InputDecoration(labelText: 'Gym name')),
        TextField(controller: _owner, decoration: const InputDecoration(labelText: 'Owner')),
        TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
        TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
        TextField(controller: _city, decoration: const InputDecoration(labelText: 'City')),
        DropdownButtonFormField(
          initialValue: _timezone,
          items: const [
            DropdownMenuItem(value: 'Asia/Kolkata', child: Text('Asia/Kolkata')),
            DropdownMenuItem(value: 'UTC', child: Text('UTC')),
          ],
          onChanged: (v) => setState(() => _timezone = v as String),
          decoration: const InputDecoration(labelText: 'Timezone'),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
