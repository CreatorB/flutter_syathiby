import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/schedule/schedule.dart';
import 'package:syathiby/presentation/jadwal/teaching_controller.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class JournalClassScreen extends HookConsumerWidget {
  final Jadwal schedule;

  const JournalClassScreen({super.key, required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(teachingControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final teachingController = ref.watch(teachingControllerProvider);
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchDetailTeaching = ref.watch(fetchDetailTeachingScheduleProvider(
      key: key,
      timetableId: '${schedule.id_timetable}',
      subjectId: '${schedule.id_mapel}',
      classroomId: '${schedule.id_kelas}',
    ));
    final detailTeaching = fetchDetailTeaching.valueOrNull;
    final formatDate = ref.watch(
      formatDateProvider('${detailTeaching?.date}',
          format: 'EEEE, dd MMMM yyyy'),
    );
    final chapter = useTextEditingController();
    final description =
        useTextEditingController(text: detailTeaching?.detail ?? '');
    final totalPresence = detailTeaching?.jumlahabsen;
    final totalData = detailTeaching?.jumlah;

    useEffect(() {
      if (detailTeaching == null) return;
      chapter.text = detailTeaching.bab ?? '';
      description.text = detailTeaching.detail ?? '';
      return null;
    }, [detailTeaching]);

    Future<void> addJournalClass() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      if (totalPresence != totalData) {
        context.showErrorMessage('Anda belum mengabsen semua siswa');
        return;
      }
      final result = await ref
          .read(teachingControllerProvider.notifier)
          .addJournalClass(
              key: key,
              classroomId: '${schedule.id_kelas}',
              subjectId: '${schedule.id_mapel}',
              chapter: chapter.text,
              description: description.text,
              timetableId: '${schedule.id_timetable}');
      if (result == null || !context.mounted) return;
      context.showSuccessMessage(
        'Berhasil menyimpan data',
        onComplete: () {
          context.pop();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Jurnal Kelas'.hardcoded),
      ),
      body: Skeletonizer(
        enabled: fetchDetailTeaching.isLoading,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(
            fetchDetailTeachingScheduleProvider(
              key: key,
              timetableId: '${schedule.id_timetable}',
              subjectId: '${schedule.id_mapel}',
              classroomId: '${schedule.id_kelas}',
            ).future,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    Center(
                      child: Text(
                        '${detailTeaching?.nama_kelas}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    _buildInfoRow(
                      context,
                      'Nama Guru',
                      '${detailTeaching?.staff}',
                    ),
                    _buildInfoRow(
                      context,
                      'Mata Pelajaran',
                      '${detailTeaching?.mata_pelajaran}',
                    ),
                    _buildInfoRow(
                      context,
                      'Tanggal Pelajaran',
                      '$formatDate',
                    ),
                    _buildInfoRow(
                      context,
                      'Jumlah Siswa',
                      '${detailTeaching?.jumlah} siswa',
                    ),
                    _buildInfoRow(
                      context,
                      'Siswa Hadir',
                      '${detailTeaching?.hadir} siswa',
                    ),
                    _buildInfoRow(
                      context,
                      'Siswa Sakit',
                      '${detailTeaching?.sakit} siswa',
                    ),
                    _buildInfoRow(
                      context,
                      'Siswa Izin',
                      '${detailTeaching?.izin} siswa',
                    ),
                    _buildInfoRow(
                      context,
                      'Siswa Alfa',
                      '${detailTeaching?.alfa} siswa',
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Bab',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: chapter,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan bab...',
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Keterangan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: description,
                      maxLines: 10,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan keterangan...',
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: teachingController.isLoading
                            ? null
                            : addJournalClass,
                        child: teachingController.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Simpan'),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: context.bodyMedium),
          ),
          Text(value, style: context.bodyMediumBold),
        ],
      ),
    );
  }
}
