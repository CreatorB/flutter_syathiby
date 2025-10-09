import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/models/staff/kinerja.dart';
import 'package:syathiby/presentation/rekap/bottomsheet_employee_attendance.dart';
import 'package:syathiby/presentation/rekap/recap_controller.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class DataPresenceScreen extends HookConsumerWidget {
  const DataPresenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final dateSelected = useState<DateTime>(
      DateTime.now(),
    );
    final dateFormat = DateFormat('yyyy-MM-dd').format(
      dateSelected.value,
    );
    final dateFullFormat = DateFormat('EEEE, dd MMMM yyyy', 'id').format(
      dateSelected.value,
    );
    final fetchDataPresence = ref.watch(
      fetchAllDataPresenceProvider(
        key: key,
        dateStart: dateFormat,
        dateEnd: dateFormat,
        division: 'kepegawaian',
      ),
    );
    ref.listen(
      fetchAllDataPresenceProvider(
        key: key,
        dateStart: dateFormat,
        dateEnd: dateFormat,
        division: 'kepegawaian',
      ),
          (previous, next) => next.showToastOnError(context),
    );
    final dataPresenceList = fetchDataPresence.valueOrNull;
    final itemCount =
    fetchDataPresence.isLoading ? 10 : dataPresenceList?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Presensi',
              style: context.titleMedium,
            ),
            Text(
              dateFullFormat,
              style: context.bodyMedium,
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () async {
              final selected = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                initialDate: dateSelected.value,
                lastDate: DateTime.now(),
              );
              if (selected == null) return;
              dateSelected.value = selected;
            },
            icon: const Icon(Icons.today),
          ),
        ],
      ),
      body: RefreshIndicator(
        child: Skeletonizer(
          enabled: fetchDataPresence.isLoading,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final presence = dataPresenceList?.elementAtOrNull(index);
              return Card(
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      '${presence?.namaAsrama}',
                      style: context.titleMediumBold,
                      textAlign: TextAlign.center,
                    ),
                    const Divider(),
                    buildItemPresence(
                      context,
                      ref,
                      key,
                      dateFormat,
                      '${presence?.idAsrama}',
                      'Jumlah Pegawai',
                      '${presence?.dikembalikan}',
                    ),
                    buildItemPresence(
                      context,
                      ref,
                      key,
                      dateFormat,
                      '${presence?.idAsrama}',
                      'Presensi Masuk',
                      '${presence?.jumlahSantri}',
                    ),
                    buildItemPresence(
                      context,
                      ref,
                      key,
                      dateFormat,
                      '${presence?.idAsrama}',
                      'Presensi Ontime',
                      '${presence?.ontime}',
                    ),
                    buildItemPresence(
                      context,
                      ref,
                      key,
                      dateFormat,
                      '${presence?.idAsrama}',
                      'Tidak Presensi',
                      '${presence?.dijemput}',
                    ),
                    buildItemPresence(
                      context,
                      ref,
                      key,
                      dateFormat,
                      '${presence?.idAsrama}',
                      'Telat Masuk',
                      '${presence?.belumpulang}',
                    ),
                    buildItemPresence(
                      context,
                      ref,
                      key,
                      dateFormat,
                      '${presence?.idAsrama}',
                      'Pulang Sebelum Waktunya',
                      '${presence?.belumkembali}',
                    ),
                    buildItemPresence(
                      context,
                      ref,
                      key,
                      dateFormat,
                      '${presence?.idAsrama}',
                      'Izin Kerja',
                      '${presence?.musrif}',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        onRefresh: () => ref.refresh(
          fetchAllDataPresenceProvider(
            key: key,
            dateStart: dateFormat,
            dateEnd: dateFormat,
            division: 'kepegawaian',
          ).future,
        ),
      ),
    );
  }

  Widget buildItemPresence(
      BuildContext context,
      WidgetRef ref,
      String key,
      String dateSelected,
      String id,
      String title,
      String count,
      ) {
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
        title,
        style: context.bodyMedium,
      ),
      trailing: Text(
        '$count Pegawai ➤',
        style: context.bodyMedium,
      ),
      onTap: () {
        _showEmployeeAttendance(
          context,
          ref,
          key,
          dateSelected,
          id,
          title,
        );
      },
    );
  }

  void _showEmployeeAttendance(
      BuildContext context,
      WidgetRef ref,
      String key,
      String date,
      String id,
      String title,
      ) async {
    try {
      final employees = await _fetchEmployeeAttendance(
        context,
        ref,
        key,
        date,
        id,
        title,
      );

      if (!context.mounted) return;

      await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        isScrollControlled: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.9,
          child: BottomsheetEmployeeAttendance(
            employees: employees,
          ),
        ),
      );
    } catch (error) {
      context.showErrorMessage('No Data');
    }
  }

  Future<List<Kinerja>> _fetchEmployeeAttendance(
      BuildContext context,
      WidgetRef ref,
      String key,
      String date,
      String id,
      String title,
      ) async {
    if (title == 'Presensi Masuk') {
      return ref.read(
        fetchPresenceFilterProvider(
          key: key,
          startDate: date,
          endDate: date,
          id: id,
          value: 'masuk',
        ).future,
      );
    }

    if (title == 'Presensi Ontime') {
      return ref.read(
        fetchPresenceFilterProvider(
          key: key,
          startDate: date,
          endDate: date,
          id: id,
          value: 'ontime',
        ).future,
      );
    }

    if (title == 'Tidak Presensi') {
      return ref.read(
        fetchPresenceFilterProvider(
          key: key,
          startDate: date,
          endDate: date,
          id: id,
          value: 'tidak_masuk',
        ).future,
      );
    }

    if (title == 'Telat Masuk') {
      return ref.read(
        fetchPresenceFilterProvider(
          key: key,
          startDate: date,
          endDate: date,
          id: id,
          value: 'late',
        ).future,
      );
    }

    if (title == 'Pulang Sebelum Waktunya') {
      return ref.read(
        fetchPresenceFilterProvider(
          key: key,
          startDate: date,
          endDate: date,
          id: id,
          value: 'before the time',
        ).future,
      );
    }

    if (title == 'Izin Kerja') {
      return ref.read(
        fetchPermitAttendanceProvider(
          key: key,
          startDate: date,
          endDate: date,
          id: id,
        ).future,
      );
    }

    return ref.read(
      fetchPresenceGroupProvider(
        key: key,
        startDate: date,
        endDate: date,
        id: id,
      ).future,
    );
  }
}
