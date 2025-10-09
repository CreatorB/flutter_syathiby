import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

class PresenceReportScreen extends HookConsumerWidget {
  const PresenceReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Kehadiran'),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () async {
              final monthSelected = await showMonthPicker(
                context: context,
                initialDate: DateTime.now(),
                lastDate: DateTime.now(),
              );
              if (monthSelected == null || !context.mounted) return;
              final startDate = DateFormat('yyyy-MM-dd').format(monthSelected);
              final endDayOfMonth = monthSelected.copyWith(
                  month: monthSelected.month + 1, day: 0);
              final endDate = DateFormat('yyyy-MM-dd').format(endDayOfMonth);
              context.goNamed(
                AppRoute.attendanceReport.name,
                queryParameters: {"startDate": startDate, "endDate": endDate},
              );
            },
            leading: Icon(
              Icons.access_time,
              size: 32,
              color: context.colorPrimary,
            ),
            title: Text(
              'Daftar Kehadiran',
              style: context.titleMediumBold,
            ),
            subtitle: Text(
              'Cek daftar kehadiran harian Anda',
              style: context.bodyMedium,
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),
          ListTile(
            onTap: () async {
              final monthSelected = await showMonthPicker(
                context: context,
                initialDate: DateTime.now(),
                lastDate: DateTime.now(),
              );
              if (monthSelected == null || !context.mounted) return;
              final startDate = DateFormat('yyyy-MM-dd').format(monthSelected);
              final endDayOfMonth = monthSelected.copyWith(
                  month: monthSelected.month + 1, day: 0);
              final endDate = DateFormat('yyyy-MM-dd').format(endDayOfMonth);
              context.goNamed(
                AppRoute.attendanceRecap.name,
                queryParameters: {"startDate": startDate, "endDate": endDate},
              );
            },
            leading: Icon(
              Icons.insert_chart,
              size: 32,
              color: context.colorPrimary,
            ),
            title: Text(
              'Rekapitulasi Kehadiran',
              style: context.titleMediumBold,
            ),
            subtitle: Text(
              'Cek laporan absensi Anda',
              style: context.bodyMedium,
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
