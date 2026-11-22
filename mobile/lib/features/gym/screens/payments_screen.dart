import 'package:flutter/material.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});
  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late Future<PageResult> _future;
  @override
  void initState() {
    super.initState();
    _future = sl<ApiClient>().listPayments();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const LoadingView();
        if (snap.hasError) return ErrorView(message: '${snap.error}', onRetry: () => setState(() => _future = sl<ApiClient>().listPayments()));
        final items = snap.data!.items.map(Payment.fromJson).toList();
        if (items.isEmpty) return const PageStateView(message: 'No payments recorded.');
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final p = items[i];
            return ListTile(
              title: Text(p.memberName.isEmpty ? p.memberId : p.memberName),
              subtitle: Text('${p.method} · ${p.paidAt}'),
              trailing: Text(formatMoney(p.amountMinor)),
            );
          },
        );
      },
    );
  }
}
