import 'package:flutter/material.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class GymOverviewScreen extends StatefulWidget {
  const GymOverviewScreen({super.key});
  @override
  State<GymOverviewScreen> createState() => _GymOverviewScreenState();
}

class _GymOverviewScreenState extends State<GymOverviewScreen> {
  late Future<DailyReport> _future;
  @override
  void initState() {
    super.initState();
    _future = sl<ApiClient>().dailyReport();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const LoadingView();
        if (snap.hasError) return ErrorView(message: '${snap.error}', onRetry: () => setState(() => _future = sl<ApiClient>().dailyReport()));
        final r = snap.data!;
        return GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 3 : 2,
          childAspectRatio: 1.35,
          children: [
            StatCard(label: 'Active members', value: '${r.activeMembers}'),
            StatCard(label: 'New today', value: '${r.newMembers}'),
            StatCard(label: 'Expiring (7d)', value: '${r.expiringNext7Days}'),
            StatCard(label: 'Expired today', value: '${r.expiredToday}'),
            StatCard(label: 'Renewals', value: '${r.renewals}'),
            StatCard(label: 'Attendance', value: '${r.attendance}'),
            StatCard(label: 'Revenue', value: formatMoney(r.revenueMinor)),
            StatCard(label: 'Pending', value: formatMoney(r.pendingPaymentsMinor)),
          ],
        );
      },
    );
  }
}
