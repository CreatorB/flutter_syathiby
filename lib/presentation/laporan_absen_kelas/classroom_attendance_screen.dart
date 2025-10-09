import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/laporan_absen_kelas/report_class_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ClassroomAttendanceScreen extends HookConsumerWidget {
  final String? date;
  final String? classId;
  final String? className;
  final String? hostelId, hostelName;

  const ClassroomAttendanceScreen({
    super.key,
    this.date,
    this.classId,
    this.className,
    this.hostelId,
    this.hostelName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final dateSelected = useState<String?>(date);
    ref.listen(
      fetchClassroomAttendanceProvider(
        key: key,
        classId: '$classId',
        date: '${dateSelected.value}',
      ),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllClassroom = ref.watch(fetchClassroomAttendanceProvider(
      key: key,
      classId: '$classId',
      date: '${dateSelected.value}',
    ));
    final itemCount = fetchAllClassroom.isLoading
        ? 10
        : fetchAllClassroom.valueOrNull?.length ?? 0;

    final dateFormat = ref.watch(
      formatDateProvider(
        '${dateSelected.value}',
        format: 'EEEE, dd MMMM yyyy',
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jadwal Kelas $className',
              style: context.titleMedium,
            ),
            Text(
              '$dateFormat',
              style: context.titleSmall,
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () async {
                final initialDate = DateTime.tryParse('${dateSelected.value}');
                final selected = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  initialDate: initialDate ?? DateTime.now(),
                  lastDate: DateTime.now(),
                );
                if (selected == null) return;
                final dateFormat = DateFormat('yyyy-MM-dd').format(selected);
                dateSelected.value = dateFormat;
              },
              icon: const Icon(Icons.today)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchClassroomAttendanceProvider(
            key: key,
            classId: '$classId',
            date: '${dateSelected.value}',
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllClassroom.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final schedule =
                  fetchAllClassroom.valueOrNull?.elementAtOrNull(index);

              final isNotAbsence =
                  schedule?.today == schedule?.hari && schedule?.absense == "0";
              final isAlreadyAbsence =
                  schedule?.today == schedule?.hari && schedule?.absense == "1";

              final textColor = isNotAbsence
                  ? context.colorOnError
                  : isAlreadyAbsence
                      ? context.colorOnPrimary
                      : context.colorOnSurface;
              final backgroundColor = isNotAbsence
                  ? context.colorError
                  : isAlreadyAbsence
                      ? context.colorPrimary
                      : context.colorSurface;

              return Card.outlined(
                color: backgroundColor,
                margin: const EdgeInsets.all(8),
                child: InkWell(
                  onTap: null,
                  // () { TODO
                  // debugPrint('SCHEDU:E" $schedule');
                  // context.goNamed(
                  //   AppRoute.detailJournalClass.name,
                  //   extra: schedule,
                  //   queryParameters: {
                  //     'date': date,
                  //     'classId': classId,
                  //     'className': className,
                  //     'hostelId': hostelId,
                  //     'hostelName': hostelName,
                  //   },
                  // );
                  // },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4),
                    child: ListTile(
                      title: Text(
                        '${schedule?.mata_pelajaran} - ${schedule?.nama_kelas}',
                        style: context.titleMediumBold?.copyWith(
                          color: textColor,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            'Pengajar: ${schedule?.staff}',
                            style: context.bodyMedium?.copyWith(
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Jam: ${schedule?.jam}',
                            style: context.bodyMedium?.copyWith(
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
