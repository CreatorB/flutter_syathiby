import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/presentation/presensi_tahfidz/tahfidz_presence_controller.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';
import '../../models/student/siswa.dart';
import '../../utils/custom_avatar_widget.dart';

class TahfidzTeacherPresenceScreen extends HookConsumerWidget {
  final String? date, time;

  const TahfidzTeacherPresenceScreen({
    super.key,
    this.date,
    this.time,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(tahfidzPresenceControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final tahfidzPresenceController =
        ref.watch(tahfidzPresenceControllerProvider);
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchTeacherTahfidzScheduleProvider(
          key: key, date: '$date', time: '$time'),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchTahfidzSchedule = ref.watch(
      fetchTeacherTahfidzScheduleProvider(
          key: key, date: '$date', time: '$time'),
    );
    final tahfidzSchedule = fetchTahfidzSchedule.valueOrNull?.firstOrNull;
    final itemCount = fetchTahfidzSchedule.isLoading
        ? 10
        : fetchTahfidzSchedule.valueOrNull?.length ?? 0;
    final formatDate = ref.watch(
      formatDateProvider(
        '${tahfidzSchedule?.date}',
        format: 'EEEE, dd MMMM yyyy',
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Halaqah $time',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchTeacherTahfidzScheduleProvider(
            key: key,
            date: '$date',
            time: '$time',
          ).future,
        ),
        child: ListView(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      tahfidzSchedule?.staff ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      formatDate ?? '$date',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Waktu Halaqah: ${tahfidzSchedule?.type ?? '$time'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Skeletonizer(
              enabled: fetchTahfidzSchedule.isLoading ||
                  tahfidzPresenceController.isLoading,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount, // Replace with your item count
                itemBuilder: (context, index) {
                  final teacher =
                      fetchTahfidzSchedule.valueOrNull?.elementAtOrNull(index);

                  return ListTile(
                    leading: CustomAvatar(
                      name: '${teacher?.namaLengkap}',
                      imageUrl: '${teacher?.img}',
                      size: 40,
                    ),
                    title: Text(
                      '${index + 1}. ${teacher?.namaLengkap}',
                      style: context.bodyMediumBold,
                    ),
                    subtitle: Text('No HP: ${teacher?.nis}'),
                    trailing: Transform.translate(
                      offset: const Offset(12, 0),
                      child: IntrinsicWidth(
                        child: DropdownButtonFormField<String>(
                          value: teacher?.statusAbsen != "Belum Absen"
                              ? teacher?.statusAbsen
                              : null,
                          items: [
                            DropdownMenuItem(
                              value: "hadir",
                              child: Text(
                                'Hadir',
                                style: context.bodyMedium,
                              ),
                            ),
                            DropdownMenuItem(
                              value: "sakit",
                              child: Text(
                                'Izin',
                                style: context.bodyMedium,
                              ),
                            ),
                            DropdownMenuItem(
                              value: "izin",
                              child: Text(
                                'Sakit',
                                style: context.bodySmall,
                              ),
                            ),
                            DropdownMenuItem(
                              value: "alfa",
                              child: Text(
                                'Alfa',
                                style: context.bodySmall,
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            _addTeacherPresence(
                              context,
                              ref,
                              key,
                              teacher,
                              '$value',
                            );
                          },
                          isDense: true,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTeacherPresence(
    BuildContext context,
    WidgetRef ref,
    String key,
    Siswa? student,
    String status,
  ) async {
    final result = await ref
        .read(tahfidzPresenceControllerProvider.notifier)
        .addTahfidzTeacherPresence(
          key: key,
          id: '${student?.nis}',
          date: '${student?.date}',
          time: '${student?.type}',
          status: status,
        );
    if (result == null || !context.mounted) {
      return;
    }
    context.showSuccessMessage(result.msg);
  }
}
