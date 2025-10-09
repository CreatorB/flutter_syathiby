import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/hostel/hostel.dart';
import 'package:syathiby/presentation/absen_asrama/hostel_controller.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AddHostelAttendanceScreen extends HookConsumerWidget {
  final Asrama hostel;

  const AddHostelAttendanceScreen({
    super.key,
    required this.hostel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(hostelControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final hostelController = ref.watch(hostelControllerProvider);
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchStudentHostel = ref.watch(
      fetchStudentHostelAttendanceProvider(
        key: key,
        hostelId: '${hostel.idAsrama}',
      ),
    );
    ref.listen(
        fetchStudentHostelAttendanceProvider(
          key: key,
          hostelId: '${hostel.idAsrama}',
        ), (previous, next) {
      next.showToastOnError(context);
    });

    final itemCount = fetchStudentHostel.isLoading
        ? 10
        : fetchStudentHostel.valueOrNull?.length ?? 0;

    final formatDate = ref.watch(
        formatDateProvider('${hostel.date}', format: 'EEEE, dd MMMM yyyy'));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${hostel.namaAsrama}',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchStudentHostelAttendanceProvider(
            key: key,
            hostelId: '${hostel.idAsrama}',
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
                      'Jumlah Santri: ${hostel.jumlahSantri}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Musyrif: ${hostel.musrif}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      '$formatDate',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    OutlinedButton(
                      onPressed: hostelController.isLoading
                          ? null
                          : () async {
                              _addHostelAttendance(context, ref, key);
                            },
                      child: hostelController.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : const Text(
                              'CEK SEKARANG',
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
              enabled: fetchStudentHostel.isLoading,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount, // Replace with your item count
                itemBuilder: (context, index) {
                  final student =
                      fetchStudentHostel.valueOrNull?.elementAtOrNull(index);
                  return ListTile(
                    leading: CustomAvatar(
                      name: '${student?.namaLengkap}',
                      imageUrl: '${student?.img}',
                      size: 40,
                    ),
                    title: Text(
                      '${index + 1}. ${student?.namaLengkap}',
                      style: context.bodyLargeBold,
                    ),
                    subtitle: Text('NIS: ${student?.nis}'),
                    trailing: Transform.translate(
                      offset: const Offset(12, 0),
                      child: IntrinsicWidth(
                        child: DropdownButtonFormField<String>(
                          value: student?.statusAbsen != "Belum Diperiksa"
                              ? student?.statusAbsen
                              : null,
                          alignment: Alignment.center,
                          items: [
                            DropdownMenuItem(
                              value: "Ada",
                              child: Text(
                                'Ada',
                                style: context.bodyMedium,
                              ),
                            ),
                            DropdownMenuItem(
                              value: "Tidak Ada",
                              child: Text(
                                'Tidak Ada',
                                style: context.bodyMedium,
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            _addStudentPresence(
                              context,
                              ref,
                              key,
                              '${student?.nis}',
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

  Future<void> _addHostelAttendance(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) async {
    final dialogResult = await showOkCancelAlertDialog(
      context: context,
      title: 'Info',
      message: 'Anda Sudah hadir dikamar dan siap memeriksa santri?',
      okLabel: 'SUDAH',
      cancelLabel: 'BELUM',
    );
    if (dialogResult == OkCancelResult.cancel) return;

    final result =
        await ref.read(hostelControllerProvider.notifier).addHostelAttendance(
              key: key,
              hostelId: '${hostel.idAsrama}',
            );
    if (result == null || !context.mounted) {
      return;
    }
    context.showSuccessMessage(result.msg);
    ref.invalidate(fetchStudentHostelAttendanceProvider);
  }

  Future<void> _addStudentPresence(
    BuildContext context,
    WidgetRef ref,
    String key,
    String studentId,
    String status,
  ) async {
    final result =
        await ref.read(hostelControllerProvider.notifier).addStudentPresence(
              key: key,
              studentId: studentId,
              hostelId: '${hostel.idAsrama}',
              status: status,
            );
    if (result == null || !context.mounted) {
      return;
    }
    context.showSuccessMessage(result.msg);
  }
}
