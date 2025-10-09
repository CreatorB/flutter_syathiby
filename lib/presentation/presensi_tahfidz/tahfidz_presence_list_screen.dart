import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/presentation/pelanggaran/violation_controller.dart';
import 'package:syathiby/presentation/presensi_tahfidz/tahfidz_presence_controller.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';
import '../../models/student/siswa.dart';
import '../../utils/custom_avatar_widget.dart';

class TahfidzPresenceListScreen extends HookConsumerWidget {
  final String? date, time;

  const TahfidzPresenceListScreen({
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
      fetchScheduleTahfidzProvider(key: key, date: '$date', time: '$time'),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchTahfidzSchedule = ref.watch(
      fetchScheduleTahfidzProvider(key: key, date: '$date', time: '$time'),
    );
    final tahfidzSchedule = fetchTahfidzSchedule.valueOrNull?.firstOrNull;
    final itemCount = fetchTahfidzSchedule.isLoading
        ? 10
        : fetchTahfidzSchedule.valueOrNull?.length ?? 0;
    final formatDate = ref.watch(formatDateProvider('${tahfidzSchedule?.date}',
        format: 'EEEE, dd MMMM yyyy'));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Halaqah $time',
        ),
        actions: [
          IconButton(
            onPressed: () {
              showOkAlertDialog(
                context: context,
                title: 'Info',
                message:
                    'Cara menambahkan murid: Klik tampilan tambah murid dibawah\n\nCara menghapus murid: Klik tampilan siswa lalu tekan hapus',
              );
            },
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchScheduleTahfidzProvider(
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
                    const SizedBox(height: 10.0),
                    OutlinedButton(
                      onPressed: tahfidzPresenceController.isLoading
                          ? null
                          : () async {
                              _addTeacherPresence(
                                context,
                                ref,
                                key,
                                '${tahfidzSchedule?.date}',
                                '${tahfidzSchedule?.type}',
                              );
                            },
                      child: tahfidzPresenceController.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : const Text(
                              'Mulai Tahfidz',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Skeletonizer(
              enabled: fetchTahfidzSchedule.isLoading,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount, // Replace with your item count
                itemBuilder: (context, index) {
                  final student =
                      fetchTahfidzSchedule.valueOrNull?.elementAtOrNull(index);

                  return ListTile(
                    onTap: () async {
                      showRemoveDialog(context, ref, key, student);
                    },
                    leading: CustomAvatar(
                      name: '${student?.namaLengkap}',
                      imageUrl: '${student?.img}',
                      size: 40,
                    ),
                    title: Text(
                      '${index + 1}. ${student?.namaLengkap}',
                      style: context.bodyMediumBold,
                    ),
                    subtitle: Text('NIS: ${student?.nis}'),
                    trailing: Transform.translate(
                      offset: const Offset(12, 0),
                      child: IntrinsicWidth(
                        child: DropdownButtonFormField<String>(
                          value: student?.statusAbsen != "Belum Absen"
                              ? student?.statusAbsen
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
                                style: context.bodyMedium,
                              ),
                            ),
                            DropdownMenuItem(
                              value: "alfa",
                              child: Text(
                                'Alfa',
                                style: context.bodyMedium,
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            _addStudentPresence(
                              context,
                              ref,
                              key,
                              student,
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
      bottomNavigationBar: _buildAddStudentToClass(context, ref, key),
    );
  }

  Future<void> _addTeacherPresence(
    BuildContext context,
    WidgetRef ref,
    String key,
    String date,
    String time,
  ) async {
    final dialogResult = await showOkCancelAlertDialog(
        context: context,
        title: 'Info',
        message: 'Anda sudah hadir untuk memulai Tahfidz?',
        okLabel: 'SUDAH',
        cancelLabel: 'BELUM');
    if (dialogResult == OkCancelResult.cancel) return;

    final result = await ref
        .read(tahfidzPresenceControllerProvider.notifier)
        .teacherPresence(key: key, date: date, time: time);

    if (result == null || !context.mounted) {
      return;
    }
    ref.invalidate(
      fetchScheduleTahfidzProvider(key: key, date: date, time: time),
    );
  }

  Future<void> _addStudentPresence(
    BuildContext context,
    WidgetRef ref,
    String key,
    Siswa? student,
    String status,
  ) async {
    final result = await ref
        .read(tahfidzPresenceControllerProvider.notifier)
        .addStudentPresence(
          key: key,
          studentId: '${student?.nis}',
          classId: '${student?.idKelas}',
          date: '${student?.date}',
          time: '${student?.type}',
          status: status,
        );
    if (result == null || !context.mounted) {
      return;
    }
  }

  Widget _buildAddStudentToClass(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: DropdownSearch<Siswa>(
        asyncItems: (String filter) {
          return ref.watch(
            fetchSearchStudentProvider(
              key: key,
              query: filter,
            ).future,
          );
        },
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
              hintText: 'Pencarian...',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        itemAsString: (item) => '${item.namaLengkap}',
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            hintText: 'Tambah Murid',
            labelText: 'Tambah Murid',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            isDense: true,
            prefixIcon: const Icon(Icons.add),
          ),
        ),
        validator: FormBuilderValidators.required(),
        onChanged: (student) async {
          if (student == null) {
            return;
          }
          final result = await ref
              .read(tahfidzPresenceControllerProvider.notifier)
              .addStudentToClass(
                key: key,
                studentId: '${student.nis}',
                classId: '${student.idKelas}',
              );
          if (result == null || !context.mounted) return;
          context.showSuccessMessage(result.msg);
          ref.invalidate(
            fetchScheduleTahfidzProvider(
              key: key,
              date: '$date',
              time: '$time',
            ),
          );
        },
      ),
    );
  }

  Future<void> showRemoveDialog(
    BuildContext context,
    WidgetRef ref,
    String key,
    Siswa? student,
  ) async {
    final dialogResult = await showOkCancelAlertDialog(
      context: context,
      title: 'Hapus Data Ini?',
      message: '${student?.namaLengkap}',
      okLabel: 'HAPUS',
      cancelLabel: 'BATAL',
    );
    if (dialogResult == OkCancelResult.cancel) return;
    final result = await ref
        .read(tahfidzPresenceControllerProvider.notifier)
        .removeStudentTahfidz(
          key: key,
          studentId: '${student?.nis}',
          classId: '${student?.idKelas}',
        );
    if (result == null || !context.mounted) {
      return;
    }
    context.showSuccessMessage(result.msg);
    ref.invalidate(
      fetchScheduleTahfidzProvider(
        key: key,
        date: '$date',
        time: '$time',
      ),
    );
  }
}
