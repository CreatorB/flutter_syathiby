import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/permit/permit.dart';
import 'package:syathiby/presentation/izin_santri/student_permit_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DetailStudentPermitScreen extends HookConsumerWidget {
  final String permitId;

  const DetailStudentPermitScreen({
    super.key,
    required this.permitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(studentPermitControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final fetchStudentPermitDetail = ref.watch(
      fetchDetailStudentPermitProvider(key: key, id: permitId),
    );
    final permit = fetchStudentPermitDetail.valueOrNull?.firstOrNull;
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
    final canDelete = permit != null &&
        permit.status != 'Dibatalkan' &&
        permit.status != 'Disetujui';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Izin Santri'),
        actions: [
          if (canDelete)
            IconButton(
              icon: Icon(Icons.delete_outline, color: context.colorError),
              tooltip: 'Hapus Izin',
              onPressed: () => _confirmAndDelete(context, ref, key, permitId),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchDetailStudentPermitProvider(key: key, id: permitId).future,
        ),
        child: Skeletonizer(
          enabled: fetchStudentPermitDetail.isLoading,
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
                    'Kelas',
                    '${permit?.kelas}',
                  ),
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
                  const SizedBox(height: 16.0),
                  if (permit?.tapHistory != null &&
                      permit!.tapHistory!.isNotEmpty)
                    _buildTapHistorySection(context, ref, permit.tapHistory!),
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

  Widget _buildTapHistorySection(
    BuildContext context,
    WidgetRef ref,
    List<TapHistory> history,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, color: context.colorPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Riwayat Tap (${history.length})',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: context.colorPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        ...history.asMap().entries.map((entry) {
          final idx = entry.key;
          final tap = entry.value;
          final isLatest = idx == 0;
          final tapKeluarFmt = _formatDateTime(tap.tapKeluar) ?? '-';
          final tapMasukFmt = _formatDateTime(tap.tapMasuk);
          final jamFromFmt = _formatDateTime(tap.jamIzinFrom);
          final jamUntilFmt = _formatDateTime(tap.jamIzinUntil);
          final statusColor = switch (tap.status) {
            'masuk' => Colors.green,
            'terlambat' => Colors.red,
            _ => Colors.orange,
          };
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isLatest ? 'Tap Terakhir' : 'Tap #${history.length - idx}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (tap.status ?? '-').toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildTapRow('Tap Keluar', tapKeluarFmt),
                  _buildTapRow('Tap Masuk', tapMasukFmt ?? '-'),
                  if (jamFromFmt != null && jamUntilFmt != null)
                    _buildTapRow('Izin', '$jamFromFmt → $jamUntilFmt'),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTapRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String? _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final parsed = DateFormat('yyyy-MM-dd HH:mm:ss').parse(raw);
      return DateFormat('dd MMM yyyy HH:mm').format(parsed);
    } catch (_) {
      try {
        final parsed = DateFormat('yyyy-MM-dd HH:mm').parse(raw);
        return DateFormat('dd MMM yyyy HH:mm').format(parsed);
      } catch (_) {
        return raw;
      }
    }
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
    final result =
        await ref.read(studentPermitControllerProvider.notifier).onApprove(
              key: key,
              permitId: permitId,
              value: 'reject',
              reason: reason,
            );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(
      'Alasan berhasil dikirim',
    );
    ref.invalidate(fetchDetailStudentPermitProvider(
      key: key,
      id: permitId,
    ));
  }

  Future<void> showAccaptedMessage(
    BuildContext context,
    WidgetRef ref,
    String key,
    String permitId,
  ) async {
    final input = await showTextInputDialog(
      context: context,
      title: 'Info',
      message: 'Apakah Anda menyetujui Izin ini?',
      okLabel: 'Setuju',
      cancelLabel: 'Kembali',
      textFields: [
        const DialogTextField(
          hintText: 'Ketik Info Tambahan Anda',
          keyboardType: TextInputType.text,
        ),
      ],
    );
    final reason = input?.firstOrNull;
    if (reason == null) return;
    final result =
        await ref.read(studentPermitControllerProvider.notifier).onApprove(
              key: key,
              permitId: permitId,
              value: 'aprove',
              reason: reason,
            );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(
      'Berhasil memberikan izin',
    );
    ref.invalidate(fetchDetailStudentPermitProvider(
      key: key,
      id: permitId,
    ));
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    String key,
    String permitId,
  ) async {
    final confirm = await showOkCancelAlertDialog(
      context: context,
      title: 'Hapus Izin',
      message:
          'Yakin ingin membatalkan izin ini? Tindakan ini tidak dapat dibatalkan.',
      okLabel: 'Hapus',
      cancelLabel: 'Batal',
      isDestructiveAction: true,
    );
    if (confirm != OkCancelResult.ok) return;
    if (!context.mounted) return;
    try {
      final result = await ref
          .read(studentPermitControllerProvider.notifier)
          .deletePermit(key: key, permitId: permitId);
      if (!context.mounted) return;
      if (result != null && (result.status == true || result.status == 'true')) {
        context.showSuccessMessage(result.msg);
        context.pop(true);
      } else if (result != null) {
        context.showErrorMessage(result.msg);
        ref.invalidate(fetchDetailStudentPermitProvider(
          key: key,
          id: permitId,
        ));
      }
    } catch (e) {
      if (!context.mounted) return;
      context.showErrorMessage(e);
    }
  }
}
