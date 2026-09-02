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

    final hasParams =
        (date ?? '').isNotEmpty && (time ?? '').isNotEmpty;

    if (hasParams) {
      ref.listen(
        fetchTeacherTahfidzScheduleProvider(
            key: key, date: '$date', time: '$time'),
        (previous, next) {
          next.showToastOnError(context);
        },
      );
    }

    final fetchTahfidzSchedule = hasParams
        ? ref.watch(
            fetchTeacherTahfidzScheduleProvider(
                key: key, date: '$date', time: '$time'),
          )
        : const AsyncValue<List<Siswa>>.data(<Siswa>[]);
    final tahfidzSchedule = fetchTahfidzSchedule.valueOrNull?.firstOrNull;
    final teachers = fetchTahfidzSchedule.valueOrNull ?? const <Siswa>[];
    final itemCount = fetchTahfidzSchedule.isLoading ? 10 : teachers.length;
    final isEmpty = hasParams &&
        !fetchTahfidzSchedule.isLoading &&
        !fetchTahfidzSchedule.hasError &&
        teachers.isEmpty;
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
        onRefresh: () async {
          if (!hasParams) return;
          return ref.refresh(
            fetchTeacherTahfidzScheduleProvider(
              key: key,
              date: '$date',
              time: '$time',
            ).future,
          );
        },
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
                      (tahfidzSchedule?.staff?.isNotEmpty ?? false)
                          ? tahfidzSchedule!.staff!
                          : (currentUser?.user?.isNotEmpty == true
                              ? currentUser!.user!
                              : 'Pengampu'),
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
              child: isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24, vertical: 32),
                      child: _EmptyTeacherHint(),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: itemCount, // Replace with your item count
                      itemBuilder: (context, index) {
                        final teacher = teachers.elementAtOrNull(index);

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
                                value:
                                    const ['hadir', 'sakit', 'izin', 'alfa']
                                            .contains(teacher?.statusAbsen)
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
                                      'Sakit',
                                      style: context.bodyMedium,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "izin",
                                    child: Text(
                                      'Izin',
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
    if (student == null || '${student.nis}'.isEmpty) {
      context.showErrorMessage('Data staff tidak valid.');
      return;
    }
    final result = await ref
        .read(tahfidzPresenceControllerProvider.notifier)
        .addTahfidzTeacherPresence(
          key: key,
          id: '${student.nis}',
          date: '${student.date}',
          time: '${student.type}',
          status: status,
        );
    if (!context.mounted) return;
    if (result == null) {
      // Error sudah ditampilkan oleh listener `ref.listen(...showToastOnError)`
      return;
    }
    context.showSuccessMessage(
      result.msg.isNotEmpty
          ? result.msg
          : 'Absensi ${student.namaLengkap ?? "staff"} tersimpan.',
    );
  }
}

class _EmptyTeacherHint extends StatelessWidget {
  const _EmptyTeacherHint();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.people_outline,
          size: 56,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 12),
        Text(
          'Belum ada data staff pengampu',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Pastikan jadwal halaqah sudah terdaftar untuk tanggal dan waktu yang dipilih.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
