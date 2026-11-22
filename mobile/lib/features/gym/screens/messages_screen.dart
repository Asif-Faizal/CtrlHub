import 'package:flutter/material.dart';
import 'package:ctrlhub_mobile/core/di/injection.dart';
import 'package:ctrlhub_mobile/core/network/api_client.dart';
import 'package:ctrlhub_mobile/shared/models/models.dart';
import 'package:ctrlhub_mobile/shared/widgets/widgets.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late Future<PageResult> _future;
  @override
  void initState() {
    super.initState();
    _future = sl<ApiClient>().listMessages();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const LoadingView();
        if (snap.hasError) return ErrorView(message: '${snap.error}');
        final items = snap.data!.items.map(MessageLog.fromJson).toList();
        if (items.isEmpty) return const PageStateView(message: 'No messages logged.');
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final m = items[i];
            return ListTile(
              title: Text('${m.recipientName.isEmpty ? m.recipientPhone : m.recipientName} · ${m.category}'),
              subtitle: Text(m.body, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: StatusChip(m.status),
            );
          },
        );
      },
    );
  }
}
