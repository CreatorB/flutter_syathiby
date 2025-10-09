import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/keuangan/student_savings_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DetailSpendingScreen extends HookConsumerWidget {
  final String? invoiceId;

  const DetailSpendingScreen({
    super.key,
    this.invoiceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final screenshotController = useMemoized(() => ScreenshotController());
    ref.listen(
      studentSavingsControllerProvider,
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchDetailSpending = ref.watch(
      fetchDetailSpendingProvider(
        key: key,
        invoiceId: '$invoiceId',
      ),
    );
    final detailSpending = fetchDetailSpending.valueOrNull;
    final invoice = detailSpending?.info;
    final data = detailSpending?.data;
    final parseNominal = double.tryParse('${invoice?.totalNominal}') ?? 0;
    final nominal = currencyFormat.format(parseNominal);

    final formatDate = ref.watch(
      formatDateProvider('${invoice?.date}', format: 'EEE, dd MMMM yyyy'),
    );

    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Permohonan'),
          actions: [
            IconButton(
              onPressed: () async {
                try {
                  final result = await screenshotController.capture();
                  if (result == null) {
                    context.showErrorMessage('Gagal menyimpan screenshot');
                    return;
                  }
                  // Save the image temporarily in the device's temp directory
                  final tempDir = await getTemporaryDirectory();
                  final file =
                  await File('${tempDir.path}/screenshot.png').create();
                  await file.writeAsBytes(result);

                  await Share.shareXFiles(
                    [
                      XFile(
                        file.path,
                        name: 'screenshot.png',
                        mimeType: 'image/png',
                      ),
                    ],
                  );
                } catch (error) {
                  context.showErrorMessage('Gagal membagikan screenshot');
                }
              },
              icon: const Icon(Icons.share),
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.refresh(
            fetchDetailSpendingProvider(
              key: key,
              invoiceId: '$invoiceId',
            ).future,
          ),
          child: Skeletonizer(
            enabled: fetchDetailSpending.isLoading,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          nominal,
                          style: context.titleLargeBold,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'ID Transaksi: ${invoice?.noInvoice ?? ''}',
                          style: context.titleSmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tanggal',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            formatDate ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Penanggung Jawab',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            invoice?.oleh ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 8,
                  ),
                  child: Text(
                    'Daftar Pengeluaran ',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: data?.length ?? 0,
                  itemBuilder: (context, index) {
                    final product = data?.elementAtOrNull(index);
                    final parseNominal =
                        double.tryParse('${product?.nominal}') ?? 0;
                    final nominal = currencyFormat.format(parseNominal);
                    return ListTile(
                      visualDensity:
                          const VisualDensity(horizontal: 0, vertical: -4),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${product?.nameSpending}',
                            style: context.bodyMediumBold,
                          ),
                          Text(
                            '${product?.note}',
                            style: context.bodySmall,
                          ),
                        ],
                      ),
                      trailing: Transform.translate(
                        offset: const Offset(16, 0),
                        child: Text(
                          nominal,
                          style: context.bodyMedium?.copyWith(
                            color: context.colorPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(nominal, style: context.bodyMediumBold),
                    ],
                  ),
                ),
                // const Divider(),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            _showDialogDeleteSpending(context, ref, key);
          },
          label: const Text('Batalkan Transaksi'),
          icon: const Icon(Icons.delete),
        ),
      ),
    );
  }

  Future<void> _showDialogDeleteSpending(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) async {
    final dialog = await showOkCancelAlertDialog(
      context: context,
      title: 'Info',
      message: 'Apakah Anda yakin ingin membatalkan transaksi ini?',
    );
    if (dialog == OkCancelResult.cancel) return;

    final result = await ref
        .read(studentSavingsControllerProvider.notifier)
        .deleteSpending(
          key: key,
          invoiceId: '$invoiceId',
        );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(
      result.msg,
    );
    ref.invalidate(fetchDetailSpendingProvider);
    context.pop();
  }
}
