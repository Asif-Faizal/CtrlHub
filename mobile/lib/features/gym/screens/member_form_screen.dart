import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class MemberFormScreen extends StatefulWidget {
  const MemberFormScreen({super.key, this.id});
  final String? id;
  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _wa = true;
  bool _mkt = false;
  bool _busy = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final m = await sl<ApiClient>().getMember(widget.id!);
      _name.text = m.fullName;
      _phone.text = m.phone;
      _email.text = m.email;
      _wa = m.whatsappOptIn;
      _mkt = m.marketingOptIn;
    } catch (e) {
      if (mounted) await showAppError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final body = {
      'full_name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'email': _email.text.trim(),
      'whatsapp_opt_in': _wa,
      'marketing_opt_in': _mkt,
    };
    try {
      final m = widget.id == null
          ? await sl<ApiClient>().createMember(body)
          : await sl<ApiClient>().updateMember(widget.id!, body);
      if (!mounted) return;
      context.go('/gym/members/${m.id}');
    } catch (e) {
      if (mounted) await showAppError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full name'), validator: (v) => v!.isEmpty ? 'Required' : null),
          TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone'), validator: (v) => v!.isEmpty ? 'Required' : null),
          TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          SwitchListTile(title: const Text('WhatsApp opt-in'), value: _wa, onChanged: (v) => setState(() => _wa = v)),
          SwitchListTile(title: const Text('Marketing opt-in'), value: _mkt, onChanged: (v) => setState(() { _mkt = v; if (v) _wa = true; })),
          const SizedBox(height: 12),
          FilledButton(onPressed: _busy ? null : _save, child: Text(widget.id == null ? 'Create member' : 'Save')),
        ],
      ),
    );
  }
}
