import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/student/siswa.dart';
import 'package:syathiby/presentation/wali_kelas/homeroom_teacher_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';

class ReportCardScreen extends HookConsumerWidget {
  final Siswa student;

  const ReportCardScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(homeroomTeacherControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final currentUser = ref.watch(getCurrentUserProvider);
    final homeroomController = ref.watch(homeroomTeacherControllerProvider);
    final key = '${currentUser?.key}';
    final rankNumber = useTextEditingController();
    final notes = useTextEditingController();
    final fetchReportCard = ref.watch(
      fetchHomeroomTeacherClassProvider(
        key: key,
        classId: '${student.idKelas}',
        studentId: '${student.nis}',
      ),
    );
    final report = fetchReportCard.valueOrNull?.firstOrNull;
    useEffect(() {
      if (report == null) return;
      rankNumber.text = '${report.rangking}';
      notes.text = '${report.keterangan}';
      return null;
    }, [fetchReportCard]);

    Future<void> updateReportCard() async {
      if (!formKey.currentState!.validate()) return;
      final result = await ref
          .read(homeroomTeacherControllerProvider.notifier)
          .updateReport(
            key: key,
            classId: '${student.idKelas}',
            studentId: '${student.nis}',
            rankNumber: rankNumber.text,
            description: notes.text,
          );
      if (result == null || !context.mounted) return;
      context.showSuccessMessage(result.msg);
      context.pop();
      ref.invalidate(fetchHomeroomTeacherProvider(key: key));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapor'),
      ),
      body: Form(
        key: formKey,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(
            fetchHomeroomTeacherClassProvider(
              key: key,
              classId: '${student.idKelas}',
              studentId: '${student.nis}',
            ).future,
          ),
          child: ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            children: [
              Text(
                student.namaLengkap ?? 'Nama Siswa',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Text(
                    'NIS:',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    student.nis ?? '',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Text(
                    'Kelas:',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    student.kelas ?? '',
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: context.colorOutline),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16),
                      child: Text(
                        'Rapor',
                        style: context.titleMediumBold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: rankNumber,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan Rangking',
                        // labelText: 'Rangking',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                      keyboardType: TextInputType.number,
                      validator: FormBuilderValidators.required(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: context.colorOutline),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16),
                      child: Text(
                        'Catatan',
                        style: context.titleMediumBold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: notes,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan Keterangan',
                        // labelText: 'Keterangan',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      validator: FormBuilderValidators.required(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 50.0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ElevatedButton(
          onPressed: updateReportCard,
          child: homeroomController.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : const Text('Update Rapor'),
        ),
      ),
    );
  }
}
