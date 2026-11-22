import 'package:flutter/material.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class RenewalsScreen extends StatefulWidget {
  const RenewalsScreen({super.key});
  @override
  State<RenewalsScreen> createState() => _RenewalsScreenState();
}

class _RenewalsScreenState extends State<RenewalsScreen> {
  String _view = 'expiring';
  late Future<PageResult> _future;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = sl<ApiClient>().listMemberships(view: _view, days: _view == 'expiring' ? 7 : 0);

  Future<void> _renew(Membership m) async {
    if (!await confirm(context, 'Renew', 'Renew ${m.memberName} on ${m.planName}?')) return;
    try {
      await sl<ApiClient>().renewMembership(m.id, {
        'initial_payment_minor': m.totalAmountMinor,
        'payment_method': 'CASH',
      });
      setState(_reload);
    } catch (e) {
      if (mounted) await showAppError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'expiring', label: Text('Expiring')),
              ButtonSegment(value: 'expired', label: Text('Expired')),
              ButtonSegment(value: 'active', label: Text('Active')),
            ],
            selected: {_view},
            onSelectionChanged: (s) => setState(() { _view = s.first; _reload(); }),
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) return const LoadingView();
              if (snap.hasError) return ErrorView(message: '${snap.error}', onRetry: () => setState(_reload));
              final items = snap.data!.items.map(Membership.fromJson).toList();
              if (items.isEmpty) return const PageStateView(message: 'Nothing here.');
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final m = items[i];
                  return ListTile(
                    title: Text(m.memberName),
                    subtitle: Text('${m.planName} · ${m.startDate} → ${m.endDate}'),
                    trailing: IconButton(icon: const Icon(Icons.autorenew), onPressed: () => _renew(m)),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
