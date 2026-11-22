import 'package:flutter/material.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});
  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  AutomationSettings? _settings;
  final _phone = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await sl<ApiClient>().automationSettings();
      if (!mounted) return;
      setState(() {
        _settings = s;
        _phone.text = s.dailyReportPhone;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      if (mounted) await showAppError(context, e);
    }
  }

  Future<void> _save() async {
    final s = _settings;
    if (s == null) return;
    try {
      final updated = await sl<ApiClient>().updateAutomationSettings({
        'expiry_enabled': s.expiryEnabled,
        'expiry_days_before': s.expiryDaysBefore,
        'holiday_enabled': s.holidayEnabled,
        'birthday_enabled': s.birthdayEnabled,
        'campaigns_enabled': s.campaignsEnabled,
        'daily_report_enabled': s.dailyReportEnabled,
        'daily_report_phone': _phone.text.trim(),
      });
      setState(() => _settings = updated);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
    } catch (e) {
      if (mounted) await showAppError(context, e);
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _settings == null) return const LoadingView();
    final s = _settings!;
    return ListView(
      children: [
        SwitchListTile(title: const Text('Expiry reminders'), value: s.expiryEnabled, onChanged: (v) => setState(() => _settings = s.copyWith(expiryEnabled: v))),
        SwitchListTile(title: const Text('Holiday announcements'), value: s.holidayEnabled, onChanged: (v) => setState(() => _settings = s.copyWith(holidayEnabled: v))),
        SwitchListTile(title: const Text('Birthday wishes'), value: s.birthdayEnabled, onChanged: (v) => setState(() => _settings = s.copyWith(birthdayEnabled: v))),
        SwitchListTile(title: const Text('Campaigns'), value: s.campaignsEnabled, onChanged: (v) => setState(() => _settings = s.copyWith(campaignsEnabled: v))),
        SwitchListTile(title: const Text('Daily report'), value: s.dailyReportEnabled, onChanged: (v) => setState(() => _settings = s.copyWith(dailyReportEnabled: v))),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Daily report phone')),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(onPressed: _save, child: const Text('Save settings')),
        ),
      ],
    );
  }
}
