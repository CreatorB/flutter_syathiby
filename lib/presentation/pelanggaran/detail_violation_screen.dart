import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/presentation/pelanggaran/violation_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class DetailViolationScreen extends HookConsumerWidget {
  final String violationId;

  const DetailViolationScreen({
    super.key,
    required this.violationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(violationControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final fetchDetailViolation = ref.watch(fetchDetailViolationProvider(
      key: key,
      violationId: violationId,
    ));
    final violation = fetchDetailViolation.valueOrNull?.firstOrNull;
    final dateFormat = ref.watch(formatDateProvider(
      '${violation?.date}',
      format: 'EEEE, dd MMMM yyyy',
    ));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelanggaran'),
      ),
      body: Skeletonizer(
        enabled: fetchDetailViolation.isLoading,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(
            fetchDetailViolationProvider(
              key: key,
              violationId: violationId,
            ).future,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${violation?.namaSiswa}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildDetailItem(
                    'Kelas',
                    '${violation?.kelas}',
                  ),
                  _buildDetailItem('Pelapor', '${violation?.staff}'),
                  _buildDetailItem(
                    'Nama Pelanggaran',
                    '${violation?.namaPelanggaran}',
                  ),
                  _buildDetailItem(
                    'Tanggal Pelanggaran',
                    '$dateFormat',
                    onClick: () async {
                      _updateDateViolation(context, ref, key);
                    },
                  ),
                  _buildDetailItem('Jam Pelanggaran', '${violation?.hour}'),
                  _buildDetailItem(
                    'Jenis Pelanggaran',
                    '${violation?.penindak}',
                  ),
                  _buildDetailItem(
                    'Lokasi Pelanggaran',
                    '${violation?.location}',
                  ),
                  _buildDetailItem(
                    'Status',
                    _getStatusMessage(violation?.status, violation?.alasan),
                  ),
                  _buildDetailItem(
                    'Detail Pelanggaran',
                    '${violation?.detail}',
                  ),
                  const SizedBox(height: 4.0),
                  CachedNetworkImage(
                    imageUrl: '${violation?.img}',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Text('Tidak ada foto'),
                  ),
                  // Provide your image path here
                  const SizedBox(height: 16.0),
                  Visibility(
                    visible: violation?.kabag == "YES" &&
                        violation?.status == "Laporan Masuk",
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              showRejectMessage(context, ref, key, violationId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colorError,
                            ),
                            child: const Text(
                              'Tolak',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              showAccaptedMessage(
                                  context, ref, key, violationId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colorPrimary,
                            ),
                            child: const Text(
                              'Proses',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusMessage(String? status, String? reason) {
    if (status == "Laporan Ditolak") {
      return "$status dengan alasan: $reason";
    } else if (status == "Selesai") {
      return "$status dengan hukuman: $reason";
    } else {
      return '$status';
    }
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
          violationId: violationId,
          date: formatDate,
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
}
