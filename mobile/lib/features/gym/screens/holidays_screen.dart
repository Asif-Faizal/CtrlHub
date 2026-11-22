import 'package:flutter/material.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class HolidaysScreen extends StatefulWidget {
  const HolidaysScreen({super.key});
  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> {
  late Future<List<Holiday>> _future;
  @override
  void initState() {
    super.initState();
    _future = sl<ApiClient>().listHolidays();
  }

  Future<void> _create() async {
    final title = TextEditingController();
    final date = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New holiday'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: date, decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)')),
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
      await sl<ApiClient>().createHoliday({
        'title': title.text.trim(),
        'holiday_date': date.text.trim(),
        'notify_enabled': true,
        'notify_days_before': [1, 3],
      });
      setState(() => _future = sl<ApiClient>().listHolidays());
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
          if (items.isEmpty) return const PageStateView(message: 'No holidays.');
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final h = items[i];
              return ListTile(title: Text(h.title), subtitle: Text(h.holidayDate), trailing: StatusChip(h.notifyEnabled ? 'Notify' : 'Silent'));
            },
          );
        },
      ),
    );
  }
}
