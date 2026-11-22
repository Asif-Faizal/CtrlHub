import 'package:flutter/material.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class PlatformOverviewScreen extends StatefulWidget {
  const PlatformOverviewScreen({super.key});
  @override
  State<PlatformOverviewScreen> createState() => _PlatformOverviewScreenState();
}

class _PlatformOverviewScreenState extends State<PlatformOverviewScreen> {
  late Future<PlatformStats> _future;

  @override
  void initState() {
    super.initState();
    _future = sl<ApiClient>().platformStats();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlatformStats>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const LoadingView();
        if (snap.hasError) return ErrorView(message: '${snap.error}', onRetry: () => setState(() => _future = sl<ApiClient>().platformStats()));
        final s = snap.data!;
        return GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 3 : 2,
          childAspectRatio: 1.4,
          children: [
            StatCard(label: 'Gyms', value: '${s.totalTenants}'),
            StatCard(label: 'Active gyms', value: '${s.activeTenants}'),
            StatCard(label: 'Users', value: '${s.totalUsers}'),
            StatCard(label: 'Members', value: '${s.totalMembers}'),
            StatCard(label: 'WhatsApp connected', value: '${s.whatsappConnected}'),
            StatCard(label: 'Messages (30d)', value: '${s.messagesLast30Days}'),
          ],
        );
      },
    );
  }
}
