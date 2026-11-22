import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class WhatsAppScreen extends StatefulWidget {
  const WhatsAppScreen({super.key});
  @override
  State<WhatsAppScreen> createState() => _WhatsAppScreenState();
}

class _WhatsAppScreenState extends State<WhatsAppScreen> {
  WhatsAppSession? _session;
  QRCode? _qr;
  String? _provider;
  String? _error;
  Timer? _timer;
  final _phone = TextEditingController();
  final _text = TextEditingController(text: 'CtrlHub test message');

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refresh(quiet: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _refresh({bool quiet = false}) async {
    try {
      final status = await sl<ApiClient>().whatsappStatus();
      final session = WhatsAppSession.fromJson(Map<String, dynamic>.from(status['session'] as Map? ?? {}));
      QRCode? qr;
      if (session.status == 'SCAN_QR_CODE' || session.status == 'STARTING') {
        try { qr = await sl<ApiClient>().whatsappQR(); } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _session = session;
        _provider = status['provider']?.toString();
        _qr = qr;
        _error = null;
      });
    } catch (e) {
      if (!quiet && mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _connect() async {
    try {
      await sl<ApiClient>().whatsappConnect();
      await _refresh();
    } catch (e) {
      if (mounted) await showAppError(context, e);
    }
  }

  Future<void> _disconnect() async {
    if (!await confirm(context, 'Disconnect', 'Disconnect this gym WhatsApp session?')) return;
    try {
      await sl<ApiClient>().whatsappDisconnect();
      await _refresh();
    } catch (e) {
      if (mounted) await showAppError(context, e);
    }
  }

  Future<void> _test() async {
    try {
      await sl<ApiClient>().whatsappTest(_phone.text.trim(), _text.text.trim());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test message sent')));
    } catch (e) {
      if (mounted) await showAppError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return ErrorView(message: _error!, onRetry: _refresh);
    final s = _session;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('WhatsApp', style: Theme.of(context).textTheme.headlineSmall),
        if (_provider != null) Text('Provider: $_provider'),
        const SizedBox(height: 8),
        if (s != null) ...[
          StatusChip(s.status),
          Text('Session: ${s.sessionName}'),
          if (s.phoneNumber.isNotEmpty) Text('Phone: ${s.phoneNumber}'),
        ],
        const SizedBox(height: 16),
        if (_qr != null && _qr!.data.isNotEmpty)
          Center(
            child: Image.memory(
              base64Decode(_qr!.data.contains(',') ? _qr!.data.split(',').last : _qr!.data),
              width: 240,
              height: 240,
            ),
          ),
        const SizedBox(height: 16),
        Wrap(spacing: 8, children: [
          FilledButton(onPressed: _connect, child: const Text('Connect')),
          OutlinedButton(onPressed: _disconnect, child: const Text('Disconnect')),
        ]),
        const Divider(height: 32),
        Text('Send test message', style: Theme.of(context).textTheme.titleMedium),
        TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
        TextField(controller: _text, decoration: const InputDecoration(labelText: 'Message')),
        const SizedBox(height: 8),
        FilledButton(onPressed: _test, child: const Text('Send test')),
      ],
    );
  }
}
