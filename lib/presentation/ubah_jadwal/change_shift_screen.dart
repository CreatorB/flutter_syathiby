import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/presentation/ubah_jadwal/change_shift_admin_screen.dart';
import 'package:syathiby/presentation/ubah_jadwal/tab_shift_screen.dart';

class ChangeShiftScreen extends HookConsumerWidget {
  final String? level;

  const ChangeShiftScreen({
    super.key,
    this.level,
  });

  static const int pagedSize = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNotLeader = level == 'staff' || level == 'pengabdian';
    if (isNotLeader) {
      final tabController = useTabController(initialLength: 2);
      return buildShiftScreenNotLeader(tabController, level);
    }
    return ChangeShiftAdminScreen(level: level);
  }

  Widget buildShiftScreenNotLeader(TabController tabController, String? level) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tukar Shift'),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Permintaan Masuk'),
            Tab(text: 'Permintaan Keluar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          TabShiftScreen(status: 'masuk', level: level),
          TabShiftScreen(status: 'keluar', level: level),
        ],
      ),
    );
  }
}
