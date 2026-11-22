import 'package:flutter/material.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});
  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  late Future<List<MembershipPlan>> _future;
  @override
  void initState() {
    super.initState();
    _future = sl<ApiClient>().listPlans();
  }

  Future<void> _create() async {
    final name = TextEditingController();
    final price = TextEditingController(text: '2000');
    String duration = 'MONTHLY';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: price, decoration: const InputDecoration(labelText: 'Price (INR)'), keyboardType: TextInputType.number),
            DropdownButtonFormField(
              initialValue: duration,
              items: const [
                DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly')),
                DropdownMenuItem(value: 'QUARTERLY', child: Text('Quarterly')),
                DropdownMenuItem(value: 'HALF_YEARLY', child: Text('Half yearly')),
                DropdownMenuItem(value: 'YEARLY', child: Text('Yearly')),
              ],
              onChanged: (v) => duration = v as String,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final rupees = int.tryParse(price.text) ?? 0;
      await sl<ApiClient>().createPlan({
        'name': name.text.trim(),
        'duration_type': duration,
        'price_minor': rupees * 100,
        'is_active': true,
      });
      setState(() => _future = sl<ApiClient>().listPlans());
    } catch (e) {
      if (mounted) await showAppError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _create, child: const Icon(Icons.add)),
      body: FutureBuilder(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const LoadingView();
          if (snap.hasError) return ErrorView(message: '${snap.error}');
          final items = snap.data!;
          if (items.isEmpty) return const PageStateView(message: 'No plans yet.');
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final p = items[i];
              return ListTile(
                title: Text(p.name),
                subtitle: Text(p.durationType),
                trailing: Text(formatMoney(p.priceMinor)),
              );
            },
          );
        },
      ),
    );
  }
}
