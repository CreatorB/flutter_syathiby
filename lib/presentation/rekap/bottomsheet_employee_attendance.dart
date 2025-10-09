import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/staff/kinerja.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

class BottomsheetEmployeeAttendance extends HookConsumerWidget {
  final List<Kinerja> employees;

  const BottomsheetEmployeeAttendance({
    super.key,
    required this.employees,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = employees.firstOrNull;
    return Scaffold(
      appBar: AppBar(
        title: Text('${employee?.nameStore}'),
        leading: Container(),
        actions: [
          IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final item = employees[index];
          final statusColor = item.status == 'Ontime'
              ? context.colorPrimary
              : item.status == 'Izin'
                  ? context.colorSecondary
                  : context.colorError;
          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            visualDensity: const VisualDensity(
              horizontal: 0,
              vertical: -4,
            ),
            title: Text(
              '${item.fullName}',
              style: context.bodyMedium,
            ),
            trailing: Text(
              '${item.status}',
              style: TextStyle(
                color: statusColor,
                fontSize: 14,
              ),
            ),
          );
        },
      ),
    );
  }
}
