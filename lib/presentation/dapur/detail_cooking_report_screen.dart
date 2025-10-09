import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/dapur/kitchen_controller.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DetailCookingReportScreen extends HookConsumerWidget {
  final String? invoiceId;
  final String? status;

  const DetailCookingReportScreen({
    super.key,
    this.invoiceId,
    this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      kitchenControllerProvider,
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final screenshotController = useMemoized(() => ScreenshotController());
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';

    final fetchDetailReport = ref.watch(
      fetchDetailReportCookingProvider(
        key: key,
        id: '$invoiceId',
      ),
    );
    final detailCookingReport = fetchDetailReport.valueOrNull;
    final invoice = detailCookingReport?.struk;
    final data = detailCookingReport?.data;
    final formatDate = ref.watch(
      formatDateProvider('${invoice?.date}', format: 'EEE, dd MMMM yyyy'),
    );
    final total = ref.watch(formatCurrencyProvider('${invoice?.totalOrder}'));

    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Masak'),
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
            fetchDetailReportCookingProvider(
              key: key,
              id: '$invoiceId',
            ).future,
          ),
          child: Skeletonizer(
            enabled: fetchDetailReport.isLoading,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          invoice?.nameStore ?? 'Nama Lembaga',
                          style: context.titleLargeBold,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Center(
                        child: Text(
                          invoice?.address != null
                              ? '${invoice?.address}, ${invoice?.email}'
                              : 'Alamat',
                          style: context.titleSmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Center(
                        child: Text(
                          invoice?.noHp ?? 'Nomor Telepon',
                          style: context.titleSmall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          total,
                          style: context.titleLargeBold,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Nomor Pengadaan: ${invoice?.noInvoice ?? ''}',
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
                            'Waktu Masak',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            invoice?.waktu ?? '',
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
                            invoice?.operator ?? '',
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
                            'Status',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            invoice?.status?.toUpperCase() ?? status ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                    'Daftar Permintaan ',
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
                    return ListTile(
                      visualDensity:
                          const VisualDensity(horizontal: 0, vertical: -4),
                      title: Text(
                        '- ${product?.nameProduct}',
                        style: context.bodyMedium,
                      ),
                      trailing: Text(
                        '${product?.amount} ${product?.unit ?? ''}',
                        style: context.bodySmall,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Catatan: \n${invoice?.keterangan ?? ''}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                // const Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
