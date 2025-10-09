import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MeetingScanQrScreen extends HookConsumerWidget {
  const MeetingScanQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
      ),
    );
  }
}
