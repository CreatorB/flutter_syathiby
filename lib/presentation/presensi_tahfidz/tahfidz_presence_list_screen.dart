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

    final hasParams =
        (date ?? '').isNotEmpty && (time ?? '').isNotEmpty;

    if (hasParams) {
      ref.listen(
        fetchScheduleTahfidzProvider(key: key, date: '$date', time: '$time'),
        (previous, next) {
          next.showToastOnError(context);
        },
      );
    }

    final fetchTahfidzSchedule = hasParams
        ? ref.watch(
            fetchScheduleTahfidzProvider(key: key, date: '$date', time: '$time'),
          )
        : const AsyncValue<List<Siswa>>.data(<Siswa>[]);
    final tahfidzSchedule = fetchTahfidzSchedule.valueOrNull?.firstOrNull;
    final students = fetchTahfidzSchedule.valueOrNull ?? const <Siswa>[];
    final itemCount = fetchTahfidzSchedule.isLoading ? 10 : students.length;
    final isEmpty = hasParams &&
        !fetchTahfidzSchedule.isLoading &&
        !fetchTahfidzSchedule.hasError &&
        students.isEmpty;
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
        onRefresh: () async {
          if (!hasParams) return;
          return ref.refresh(
            fetchScheduleTahfidzProvider(
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
                    const SizedBox(height: 10.0),
                    OutlinedButton(
                      onPressed: (tahfidzPresenceController.isLoading ||
                              !hasParams)
                          ? null
                          : () async {
                              _addTeacherPresence(
                                context,
                                ref,
                                key,
                                tahfidzSchedule?.date ?? date ?? '',
                                tahfidzSchedule?.type ?? time ?? '',
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
              child: isEmpty
                  ? _EmptyHalaqahHint(
                      onAdd: () => _focusAddStudent(context, ref),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: itemCount, // Replace with your item count
                      itemBuilder: (context, index) {
                        final student = students.elementAtOrNull(index);

                        return ListTile(
                          onTap: () async {
                            if ((student?.statusAbsen == 'sakit' ||
                                    student?.keteranganSakit != null) &&
                                student?.idKesehatan != null) {
                              _showSakitDetail(context, student!);
                              return;
                            }
                            if (student?.izinId != null &&
                                '${student?.izinId}'.isNotEmpty) {
                              _showIzinDetail(context, student!);
                              return;
                            }
                            showRemoveDialog(context, ref, key, student);
                          },
                          leading: CustomAvatar(
                            name: '${student?.namaLengkap}',
                            imageUrl: '${student?.img}',
                            size: 40,
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${index + 1}. ${student?.namaLengkap}',
                                  style: context.bodyMediumBold,
                                ),
                              ),
                              if ((student?.statusAbsen == 'sakit' ||
                                      student?.keteranganSakit != null) &&
                                  student?.idKesehatan != null) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                              ] else if (student?.izinId != null &&
                                  '${student?.izinId}'.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: Colors.blueAccent,
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text('NIS: ${student?.nis}'),
                          trailing: Transform.translate(
                            offset: const Offset(12, 0),
                            child: IntrinsicWidth(
                              child: DropdownButtonFormField<String>(
                                value:
                                    const ['hadir', 'sakit', 'izin', 'alfa']
                                            .contains(student?.statusAbsen)
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
                                      'Sakit',
                                      style: context.bodyMedium,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "izin",
                                    child: Text(
                                      'Izin',
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
    if (date.isEmpty || time.isEmpty) {
      context.showErrorMessage(
        'Tanggal atau waktu halaqah belum dipilih. Silakan kembali ke halaman Pilih Jadwal.',
      );
      return;
    }
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

    if (!context.mounted) return;
    if (result == null) {
      // Error sudah ditampilkan oleh listener `ref.listen(...showToastOnError)`
      // di controller `tahfidzPresenceControllerProvider`.
      return;
    }
    context.showSuccessMessage(result.msg.isNotEmpty
        ? result.msg
        : 'Mulai Tahfidz berhasil dicatat.');
    ref.invalidate(
      fetchScheduleTahfidzProvider(key: key, date: date, time: time),
    );
  }

  // ignore: body_might_complete_normally
  Future<void> _showSakitDetail(BuildContext context, Siswa student) {
    final istirahatHari = student.kesehatanIstirahat != null &&
            '${student.kesehatanIstirahat}'.isNotEmpty
        ? '${student.kesehatanIstirahat} hari'
        : '-';
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.medical_services_outlined,
                        color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Text(
                      'Info Kesehatan Santri',
                      style: context.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SakitInfoRow(
                  icon: Icons.person,
                  label: 'Nama Siswa',
                  value: student.namaLengkap ?? '-',
                ),
                _SakitInfoRow(
                  icon: Icons.warning_amber_rounded,
                  label: 'Jenis Penyakit',
                  value: student.kesehatanDiagnosa ?? '-',
                ),
                _SakitInfoRow(
                  icon: Icons.question_answer_outlined,
                  label: 'Keluhan Siswa',
                  value: student.kesehatanKeluhan ?? '-',
                ),
                _SakitInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Tanggal Pemeriksaan',
                  value: student.kesehatanTanggal ?? '-',
                ),
                _SakitInfoRow(
                  icon: Icons.access_time,
                  label: 'Jam Pemeriksaan',
                  value: student.kesehatanJam ?? '-',
                ),
                _SakitInfoRow(
                  icon: Icons.numbers,
                  label: 'Jumlah Waktu Istirahat',
                  value: istirahatHari,
                ),
              ],
            ),
          ),
        );
      },
    );
  }


    // ignore: body_might_complete_normally
  Future<void> _showIzinDetail(BuildContext context, Siswa student) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Text(
                      'Info Izin Santri',
                      style: context.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SakitInfoRow(
                  icon: Icons.person,
                  label: 'Nama Siswa',
                  value: student.namaLengkap ?? '-',
                ),
                _SakitInfoRow(
                  icon: Icons.assignment_outlined,
                  label: 'Jenis Izin',
                  value: student.izinJenis ?? '-',
                ),
                _SakitInfoRow(
                  icon: Icons.notes_outlined,
                  label: 'Alasan',
                  value: student.izinAlasan ?? '-',
                ),
                _SakitInfoRow(
                  icon: Icons.event_outlined,
                  label: 'Tanggal Awal',
                  value: student.izinTanggalAwal ?? '-',
                ),
                _SakitInfoRow(
                  icon: Icons.event_available_outlined,
                  label: 'Tanggal Akhir',
                  value: student.izinTanggalAkhir ?? '-',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addStudentPresence(
    BuildContext context,
    WidgetRef ref,
    String key,
    Siswa? student,
    String status,
  ) async {
    if (student == null || '${student.nis}'.isEmpty) {
      context.showErrorMessage('Data siswa tidak valid.');

      return;
    }
    final result = await ref
        .read(tahfidzPresenceControllerProvider.notifier)
        .addStudentPresence(
          key: key,
          studentId: '${student.nis}',
          classId: '${student.idKelas}',
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
      result.msg.isNotEmpty ? result.msg : 'Absensi ${student.namaLengkap} tersimpan.',
    );
    ref.invalidate(
      fetchScheduleTahfidzProvider(key: key, date: '$date', time: '$time'),
    );
  }

  void _focusAddStudent(BuildContext context, WidgetRef ref) {
    // Gulir ke bawah supaya field "Tambah Murid" terlihat & bisa langsung diketuk.
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Belum ada murid. Ketuk field "Tambah Murid" di bawah untuk menambahkan.',
        ),
        duration: Duration(seconds: 4),
      ),
    );
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
          if (!context.mounted) return;
          if (result == null) {
            // Error sudah ditampilkan oleh listener `ref.listen(...showToastOnError)`
            return;
          }
          context.showSuccessMessage(
            result.msg.isNotEmpty
                ? result.msg
                : '${student.namaLengkap} berhasil ditambahkan ke halaqah.',
          );
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
    if (!context.mounted) return;
    if (result == null) {
      // Error sudah ditampilkan oleh listener `ref.listen(...showToastOnError)`
      return;
    }
    context.showSuccessMessage(
      result.msg.isNotEmpty
          ? result.msg
          : '${student?.namaLengkap ?? "Santri"} dihapus dari halaqah.',
    );
    ref.invalidate(
      fetchScheduleTahfidzProvider(
        key: key,
        date: '$date',
        time: '$time',
      ),
    );
  }
}

class _EmptyHalaqahHint extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyHalaqahHint({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.group_add_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada murid di halaqah ini',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan murid melalui kolom "Tambah Murid" di bawah halaman ini, '
            'lalu klik Mulai Tahfidz untuk memulai sesi.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Murid'),
          ),
        ],
      ),
    );
  }
}

class _SakitInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SakitInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: context.bodyMediumBold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
