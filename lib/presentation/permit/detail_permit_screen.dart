import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/permit/permit_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DetailPermitScreen extends HookConsumerWidget {
  final String permitId;

  const DetailPermitScreen({
    super.key,
    required this.permitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(permitControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final fetchPermitDetail = ref.watch(
      fetchPermitDetailProvider(key: key, id: permitId),
    );
    final permit = fetchPermitDetail.valueOrNull?.firstOrNull;
    final dateFormat = ref.watch(formatDateProvider(
      '${permit?.date}',
      format: 'EEEE, dd MMMM yyyy',
    ));
    final lastDateFormat = ref.watch(formatDateProvider(
      '${permit?.lastDate}',
      format: 'EEEE, dd MMMM yyyy',
    ));
    final isPermitRejected = permit?.status == "Ditolak";
    final isPermitWaiting = permit?.status == "Menunggu Persetujuan";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Izin'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchPermitDetailProvider(key: key, id: permitId).future,
        ),
        child: Skeletonizer(
          enabled: fetchPermitDetail.isLoading,
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
                    permit?.staff ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildDetailItem(
                    context,
                    'Tanggal Izin',
                    dateFormat ?? '',
                  ),
                  _buildDetailItem(
                      context, 'Alasan Izin', permit?.namePermit ?? ''),
                  _buildDetailItem(
                      context, 'Jumlah Hari Izin', permit?.day ?? ''),
                  _buildDetailItem(
                      context, 'Izin Berakhir', lastDateFormat ?? ''),
                  _buildDetailItem(
                    context,
                    'Status',
                    isPermitRejected
                        ? '${permit?.status} dengan alasan ${permit?.alasan}'
                        : '${permit?.status}',
                  ),
                  _buildDetailItem(
                    context,
                    'Detail Izin',
                    permit?.detail ?? '',
                  ),
                  _buildDetailItem(
                    context,
                    'Disetujui Oleh',
                    permit?.aproval ?? '',
                  ),
                  Text(
                    'Dokumen Pendukung',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: context.colorOnSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  CachedNetworkImage(
                    imageUrl: '${permit?.doc}',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Text('Tidak ada dokumen'),
                  ),
                  const SizedBox(height: 16.0),
                  Visibility(
                    visible: isPermitWaiting && permit?.kabag == "YES",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              showRejectMessage(context, ref, key, permitId);
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
                              showAccaptedMessage(context, ref, key, permitId);
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

  Future<void> showRejectMessage(
    BuildContext context,
    WidgetRef ref,
    String key,
    String permitId,
  ) async {
    final input = await showTextInputDialog(
      context: context,
      title: 'Info',
      message: 'Anda menolak izin ini, Silahkan isi Alasan Anda',
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
    final result = await ref.read(permitControllerProvider.notifier).onApprove(
          key: key,
          permitId: permitId,
          value: 'reject',
          reason: reason,
        );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(
      'Alasan berhasil dikirim',
    );
    ref.invalidate(fetchPermitDetailProvider(
      key: key,
      id: permitId,
    ));
  }

  Future<void> showAccaptedMessage(
      BuildContext context, WidgetRef ref, String key, String permitId) async {
    final input = await showOkCancelAlertDialog(
        context: context,
        title: 'Info',
        message: 'Apakah Anda menyetujui Izin ini?',
        okLabel: 'Setuju',
        cancelLabel: 'Kembali');
    final approved = input == OkCancelResult.ok;
    if (!approved) return;
    final result = await ref.read(permitControllerProvider.notifier).onApprove(
          key: key,
          permitId: permitId,
          value: 'aprove',
          reason: '',
        );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(
      'Berhasil memberikan izin',
    );
    ref.invalidate(fetchPermitDetailProvider(
      key: key,
      id: permitId,
    ));
  }
}
