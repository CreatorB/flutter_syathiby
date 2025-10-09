import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/presentation/kesehatan/student_health_controller.dart';
import 'package:syathiby/presentation/pelanggaran/violation_controller.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class DetailStudentHealthScreen extends HookConsumerWidget {
  final String studentHealthId;

  const DetailStudentHealthScreen({
    super.key,
    required this.studentHealthId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchDetailStudentHealth = ref.watch(fetchDetailStudentHealthProvider(
      key: key,
      studentHealthId: studentHealthId,
    ));
    final studentHealth = fetchDetailStudentHealth.valueOrNull?.firstOrNull;
    final dateFormat = ref.watch(formatDateProvider(
      '${studentHealth?.date}',
      format: 'EEEE, dd MMMM yyyy',
    ));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Penanganan'),
      ),
      body: Skeletonizer(
        enabled: fetchDetailStudentHealth.isLoading,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(
            fetchDetailStudentHealthProvider(
              key: key,
              studentHealthId: studentHealthId,
            ).future,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${studentHealth?.nama_siswa}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildDetailItem(
                    'Kelas',
                    '${studentHealth?.kelas}',
                  ),
                  _buildDetailItem('Diagnosa', '${studentHealth?.diagnosa}'),
                  _buildDetailItem(
                    'Tanggal Pemeriksaan',
                    '$dateFormat',
                  ),
                  _buildDetailItem(
                    'Jam Pemeriksaan',
                    '${studentHealth?.hour}',
                  ),
                  _buildDetailItem(
                      'Keluhan Siswa', '${studentHealth?.keluhan}'),
                  _buildDetailItem(
                    'Detail Penanganan',
                    '${studentHealth?.penanganan}',
                  ),
                  _buildDetailItem(
                    'Jumlah Waktu Istirahat',
                    '${studentHealth?.istirahat}',
                  ),
                  _buildDetailItem(
                    'Perlu Dijemput Orang Tua',
                    '${studentHealth?.dijemput}',
                  ),
                  _buildDetailItem('Informasi Untuk Orang Tua',
                      '${studentHealth?.info_ortu}'),
                  _buildDetailItem(
                    'Yang Menangani',
                    '${studentHealth?.staff}',
                  ),
                  const SizedBox(height: 4.0),
                  CachedNetworkImage(
                    imageUrl: '${studentHealth?.img}',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Text('Tidak ada foto'),
                  ),
                  // Provide your image path here
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value, {
    VoidCallback? onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Future<void> showRejectMessage(
    BuildContext context,
    WidgetRef ref,
    String key,
    String violationId,
  ) async {
    final input = await showTextInputDialog(
      context: context,
      title: 'Info',
      message: 'Anda menolak laporan ini, Silahkan isi Alasan Anda',
      textFields: [
        DialogTextField(
          hintText: 'Alasan Anda',
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null) return 'Anda Harus memasukkan Alasan...';
            return null;
          },
          autocorrect: true,
        ),
      ],
    );
    final reason = input?.firstOrNull;
    if (reason == null) return;
    final result = await ref
        .read(violationControllerProvider.notifier)
        .approveReportViolation(
          key: key,
          violationId: violationId,
          message: 'reject',
          reason: reason,
        );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(fetchDetailViolationProvider(
      key: key,
      violationId: violationId,
    ));
  }

  Future<void> showAccaptedMessage(
    BuildContext context,
    WidgetRef ref,
    String key,
    String violationId,
  ) async {
    final input = await showTextInputDialog(
      context: context,
      title: 'Info',
      message: 'Silahkan isi Penjelasan Hukumannya dan klik tombol diproses',
      okLabel: 'Diproses',
      cancelLabel: 'Kembali',
      textFields: [
        DialogTextField(
          hintText: 'Alasan Anda',
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null) return 'Anda Harus memasukkan Penjelasan...';
            return null;
          },
          autocorrect: true,
        ),
      ],
    );
    final reason = input?.firstOrNull;
    if (reason == null) return;

    final result = await ref
        .read(violationControllerProvider.notifier)
        .approveReportViolation(
          key: key,
          violationId: violationId,
          message: 'aprove',
          reason: reason,
        );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(
      fetchDetailViolationProvider(
        key: key,
        violationId: violationId,
      ),
    );
  }

  Future<void> _updateDateViolation(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) async {
    final dateSelected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (dateSelected == null) return;
    final formatDate = DateFormat('yyyy-mm-dd').format(dateSelected);
    final result = await ref
        .read(violationControllerProvider.notifier)
        .updateDateViolation(
          key: key,
          violationId: studentHealthId,
          date: formatDate,
        );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(
      fetchDetailViolationProvider(
        key: key,
        violationId: studentHealthId,
      ),
    );
  }
}
