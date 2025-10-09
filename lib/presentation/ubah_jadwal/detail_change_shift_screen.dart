import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/ubah_jadwal/change_shift_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DetailChangeShiftScreen extends HookConsumerWidget {
  final String? shiftId;

  const DetailChangeShiftScreen({
    super.key,
    this.shiftId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(changeShiftControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final fetchShiftDetail = ref.watch(
      fetchDetailChangeShiftProvider(key: key, id: '$shiftId'),
    );
    final shift = fetchShiftDetail.valueOrNull?.firstOrNull;
    final dateFormat = ref.watch(formatDateProvider(
      '${shift?.date}',
      format: 'EEEE, dd MMMM yyyy',
    ));

    final isShiftRejected = shift?.status == "Ditolak Pengganti" ||
        shift?.status == "Ditolak Pimpinan";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Izin'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchDetailChangeShiftProvider(key: key, id: '$shiftId').future,
        ),
        child: Skeletonizer(
          enabled: fetchShiftDetail.isLoading,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildDetailItem(
                    context,
                    'Pegawai Yang Mengajukan',
                    '${shift?.staff}',
                  ),
                  _buildDetailItem(
                    context,
                    'Pegawai Pengganti',
                    shift?.staff2 ?? '',
                  ),
                  _buildDetailItem(
                    context,
                    'Alasan Pergantian',
                    shift?.detail ?? '',
                  ),
                  _buildDetailItem(
                    context,
                    'Status',
                    isShiftRejected
                        ? '${shift?.status} dengan alasan ${shift?.alasan}'
                        : '${shift?.status}',
                  ),
                  _buildDetailItem(
                    context,
                    'Persetujuan Oleh',
                    shift?.aproval ?? '',
                  ),
                  const SizedBox(height: 16.0),
                  // Replacement
                  Visibility(
                    visible: _isVisibleApproveReplacement(
                      '${shift?.status}',
                      '${shift?.pengganti}',
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              showRejectMessage(context, ref, key, '$shiftId',
                                  'reject_pengganti');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colorError,
                            ),
                            child: Text(
                              'Tolak',
                              style: context.titleMedium?.copyWith(
                                color: context.colorOnError,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              showAccaptedMessage(
                                context,
                                ref,
                                key,
                                '$shiftId',
                                'aprove_pengganti',
                              );
                            },
                            child: const Text('Setujui'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _isVisibleApprove(
                      '${shift?.status}',
                      '${shift?.kabag}',
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              showRejectMessage(
                                  context, ref, key, '$shiftId', 'aprove');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colorError,
                            ),
                            child: Text(
                              'Tolak',
                              style: context.titleMedium?.copyWith(
                                color: context.colorOnError,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              showAccaptedMessage(
                                  context, ref, key, '$shiftId', 'reject');
                            },
                            child: const Text('Setujui'),
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

  Widget _buildDetailItem(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.0,
            color: context.colorOnSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          content,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12.0),
      ],
    );
  }

  bool _isVisibleApprove(
    String status,
    String position,
  ) {
    if (status == 'Menunggu Persetujuan Pimpinan') {
      return true;
    }
    if (status == 'Disetujui Pengganti' && position == 'YES') {
      return true;
    }
    return false;
  }

  bool _isVisibleApproveReplacement(
    String status,
    String replacement,
  ) {
    if (status == 'Menunggu Persetujuan Pengganti' && replacement == "YES") {
      return true;
    }
    return false;
  }

  Future<void> showRejectMessage(
    BuildContext context,
    WidgetRef ref,
    String key,
    String permitId,
    String value,
  ) async {
    final input = await showTextInputDialog(
      context: context,
      title: 'Info',
      message: 'Anda menolak Perubahan ini, Silahkan isi Alasan Anda',
      textFields: [
        DialogTextField(
          hintText: 'Alasan Anda',
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null) return 'tidak boleh kosong';
            return null;
          },
          autocorrect: true,
        ),
      ],
    );
    final reason = input?.firstOrNull;
    if (reason == null) return;
    final result = await ref
        .read(changeShiftControllerProvider.notifier)
        .approveChangeShift(
          key: key,
          id: permitId,
          data: value,
          reason: reason,
        );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(fetchDetailChangeShiftProvider);
  }

  Future<void> showAccaptedMessage(
    BuildContext context,
    WidgetRef ref,
    String key,
    String permitId,
    String value,
  ) async {
    final input = await showOkCancelAlertDialog(
      context: context,
      title: 'Info',
      message: 'Apakah Anda menyetujui Perubahan ini?',
      okLabel: 'Setuju',
      cancelLabel: 'Kembali',
    );
    final approved = input == OkCancelResult.ok;
    if (!approved) return;
    final result = await ref
        .read(changeShiftControllerProvider.notifier)
        .approveChangeShift(
          key: key,
          id: permitId,
          data: value,
          reason: '',
        );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(fetchDetailChangeShiftProvider);
  }
}
