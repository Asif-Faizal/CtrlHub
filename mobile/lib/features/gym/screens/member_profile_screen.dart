import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({super.key, required this.id});
  final String id;
  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  late Future<Member> _future;
  @override
  void initState() {
    super.initState();
    _future = sl<ApiClient>().getMember(widget.id);
  }

  Future<void> _assign() async {
    final plans = await sl<ApiClient>().listPlans(activeOnly: true);
    if (!mounted || plans.isEmpty) {
      await showAppError(context, 'Create an active plan first');
      return;
    }
    MembershipPlan? selected = plans.first;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign plan'),
        content: DropdownButtonFormField<MembershipPlan>(
          initialValue: selected,
          items: plans.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (${formatMoney(p.priceMinor)})'))).toList(),
          onChanged: (v) => selected = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Assign')),
        ],
      ),
    );
    if (ok != true || selected == null) return;
    try {
      await sl<ApiClient>().assignMembership({
        'member_id': widget.id,
        'plan_id': selected!.id,
        'initial_payment_minor': selected!.priceMinor,
        'payment_method': 'CASH',
      });
      setState(() => _future = sl<ApiClient>().getMember(widget.id));
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
        final m = snap.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(child: Text(m.fullName, style: Theme.of(context).textTheme.headlineSmall)),
                IconButton(onPressed: () => context.push('/gym/members/${m.id}/edit'), icon: const Icon(Icons.edit)),
              ],
            ),
            Text(m.phone),
            if (m.email.isNotEmpty) Text(m.email),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              StatusChip(m.membershipStatus),
              if (m.currentPlan.isNotEmpty) StatusChip(m.currentPlan),
              if (m.expiresOn != null) StatusChip('Expires ${m.expiresOn}'),
            ]),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _assign, icon: const Icon(Icons.card_membership), label: const Text('Assign membership')),
          ],
        );
      },
    );
  }
}
