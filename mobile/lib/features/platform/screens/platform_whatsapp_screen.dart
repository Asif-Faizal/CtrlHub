import 'package:flutter/material.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class PlatformWhatsAppScreen extends StatefulWidget {
  const PlatformWhatsAppScreen({super.key});
  @override
  State<PlatformWhatsAppScreen> createState() => _PlatformWhatsAppScreenState();
}

class _PlatformWhatsAppScreenState extends State<PlatformWhatsAppScreen> {
  late Future<List<WhatsAppSession>> _future;
  @override
  void initState() {
    super.initState();
    _future = sl<ApiClient>().platformWhatsApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const LoadingView();
        if (snap.hasError) {
          return ErrorView(message: '${snap.error}', onRetry: () => setState(() => _future = sl<ApiClient>().platformWhatsApp()));
        }
        final items = snap.data!;
        if (items.isEmpty) return const PageStateView(message: 'No WhatsApp sessions yet.');
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final s = items[i];
            return ListTile(
              title: Text(s.tenantName.isEmpty ? s.sessionName : s.tenantName),
              subtitle: Text('${s.sessionName} · ${s.phoneNumber}'),
              trailing: StatusChip(s.status),
            );
          },
        );
      },
    );
  }
}
