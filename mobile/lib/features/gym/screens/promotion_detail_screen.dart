import 'package:flutter/material.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class PromotionDetailScreen extends StatefulWidget {
  const PromotionDetailScreen({super.key, required this.id});
  final String id;
  @override
  State<PromotionDetailScreen> createState() => _PromotionDetailScreenState();
}

class _PromotionDetailScreenState extends State<PromotionDetailScreen> {
  late Future<Campaign> _future;
  @override
  void initState() {
    super.initState();
    _future = sl<ApiClient>().getCampaign(widget.id);
  }

  Future<void> _act(Future<Campaign> Function() fn) async {
    try {
      await fn();
      setState(() => _future = sl<ApiClient>().getCampaign(widget.id));
    } catch (e) {
      if (mounted) await showAppError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const LoadingView();
        if (snap.hasError) return ErrorView(message: '${snap.error}');
        final c = snap.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(c.name, style: Theme.of(context).textTheme.headlineSmall),
            StatusChip(c.status),
            const SizedBox(height: 12),
            Text(c.message),
            const SizedBox(height: 12),
            Text('Audience: ${c.audience}'),
            Text('Recipients: ${c.recipientsTotal} · sent ${c.sentCount} · failed ${c.failedCount}'),
            const SizedBox(height: 16),
            Wrap(spacing: 8, children: [
              if (c.status == 'DRAFT') FilledButton(onPressed: () => _act(() => sl<ApiClient>().submitCampaign(c.id)), child: const Text('Submit')),
              if (c.status == 'PENDING_APPROVAL') ...[
                FilledButton(onPressed: () => _act(() => sl<ApiClient>().approveCampaign(c.id)), child: const Text('Approve')),
                OutlinedButton(onPressed: () => _act(() => sl<ApiClient>().rejectCampaign(c.id, 'Rejected from mobile')), child: const Text('Reject')),
              ],
            ]),
          ],
        );
      },
    );
  }
}
