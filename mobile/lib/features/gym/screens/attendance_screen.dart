import 'package:flutter/material.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Future<List<Attendance>> _future;
  final _memberId = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = sl<ApiClient>().listAttendance();
  }

  @override
  void dispose() {
    _memberId.dispose();
    super.dispose();
  }

  Future<void> _checkIn() async {
    if (_memberId.text.trim().isEmpty) return;
    try {
      await sl<ApiClient>().checkIn(_memberId.text.trim());
      _memberId.clear();
      setState(() => _future = sl<ApiClient>().listAttendance());
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
          child: Row(
            children: [
              Expanded(child: TextField(controller: _memberId, decoration: const InputDecoration(labelText: 'Member ID'))),
              const SizedBox(width: 8),
              FilledButton(onPressed: _checkIn, child: const Text('Check in')),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) return const LoadingView();
              if (snap.hasError) return ErrorView(message: '${snap.error}');
              final items = snap.data!;
              if (items.isEmpty) return const PageStateView(message: 'No check-ins today.');
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final a = items[i];
                  return ListTile(title: Text(a.memberName), subtitle: Text(a.checkInAt));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
