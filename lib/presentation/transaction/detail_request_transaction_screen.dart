import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/job/job_detail.dart';
import 'package:syathiby/presentation/transaction/transaction_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../utils/custom_avatar_widget.dart';

class DetailRequestTransactionScreen extends HookConsumerWidget {
  final String? invoiceId;
  final String? status;

  const DetailRequestTransactionScreen({
    super.key,
    this.invoiceId,
    this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      transactionControllerProvider,
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';

    final fetchDetailRequest = ref.watch(
      fetchDetailRequestTransactionProvider(
        key: key,
        invoiceId: '$invoiceId',
      ),
    );
    final statusSelected = useState<String?>(null);
    final detailRequestTransaction = fetchDetailRequest.valueOrNull;
    final invoice = detailRequestTransaction?.struk;
    final data = detailRequestTransaction?.data;
    final formatDate = ref.watch(
      formatDateProvider('${invoice?.date}', format: 'EEEE, dd MMMM yyyy'),
    );
    final totalRequest =
        ref.watch(formatCurrencyProvider('${invoice?.totalOrder}'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Permohonan'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchDetailRequestTransactionProvider(
            key: key,
            invoiceId: '$invoiceId',
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchDetailRequest.isLoading,
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
                        totalRequest,
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
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          formatDate ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nama Bidang',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          invoice?.namaBidang ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nama Kegiatan',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          invoice?.namaKegiatan ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lokasi Kegiatan',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          invoice?.alokasi ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Jenis Kegiatan',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          invoice?.jenisKegiatan ?? '',
                          style: const TextStyle(
                            fontSize: 14,
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
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          invoice?.operator ?? '',
                          style: const TextStyle(
                            fontSize: 14,
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
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          invoice?.status?.toUpperCase() ?? status ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 8,
                ),
                child: Text(
                  'Daftar Permohonan ',
                  style: context.bodyMediumBold,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: data?.length ?? 0,
                itemBuilder: (context, index) {
                  final product = data?.elementAtOrNull(index);
                  final price =
                      ref.watch(formatCurrencyProvider('${product?.price}'));
                  final totalPrice = ref
                      .watch(formatCurrencyProvider('${product?.totalPrice}'));
                  final amount =
                      double.tryParse('${product?.amount}')?.toInt() ?? 0;

                  return ListTile(
                    visualDensity: const VisualDensity(
                      horizontal: 0,
                      vertical: -4,
                    ),
                    onTap: () async {
                      final input = await showTextInputDialog(
                        context: context,
                        title: 'Ubah Harga ${product?.nameProduct}',
                        textFields: [
                          DialogTextField(
                            hintText: 'Harga',
                            initialText: '${product?.price}',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty == true) {
                                return 'Tidak boleh kosong';
                              }
                              return null;
                            },
                            autocorrect: true,
                          ),
                        ],
                      );
                      final value = input?.firstOrNull;
                      if (value == null) return;
                      final result = await ref
                          .refresh(transactionControllerProvider.notifier)
                          .changePriceItem(
                            key: key,
                            productId: '${product?.idProduct}',
                            invoiceId: '$invoiceId',
                            newPrice: value,
                          );
                      if (result == null || !context.mounted) return;
                      context.showSuccessMessage(result.msg);
                      ref.invalidate(fetchDetailRequestTransactionProvider);
                    },
                    leading: InkWell(
                      onTap: () {
                        final imageProvider = CachedNetworkImageProvider(
                          '${product?.img}',
                        );
                        showImageViewer(context, imageProvider);
                      },
                      child: CustomAvatar(
                        name: '${product?.nameProduct}',
                        imageUrl: '${product?.img}',
                        size: 40,
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${product?.nameProduct}',
                          style: context.bodyMediumBold,
                        ),
                        Text(
                          '$price x $amount',
                          style: context.bodySmall,
                        ),
                      ],
                    ),
                    trailing: Text(
                      totalPrice,
                      style: context.bodySmallBold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Perkiraan ',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      totalRequest,
                      style: context.bodyMediumBold,
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  'Catatan: \n${invoice?.keterangan ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              // const Divider(),
              _buildItemProgress(context, ref, key),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: DropdownSearch<String>(
          selectedItem: statusSelected.value,
          items: const [
            'Mudir Setuju',
            'Mudir Menolak',
            'Atasan Setuju',
            'Atasan Menolak',
            'Keuangan Proses',
            'Keuangan Menolak',
            'Konfirmasi',
            'Selesai',
            'Barang Diterima',
          ],
          dropdownDecoratorProps: const DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: 'Ubah Status Permohonan',
              labelText: 'Ubah Status Permohonan',
              border: OutlineInputBorder(),
              isDense: true,
              prefixIcon: Icon(Icons.dataset),
            ),
          ),
          onChanged: (status) async {
            if (status == null) {
              return;
            }
            final dialog = await _showDialogValueAndReason(context, status);
            final value = dialog.$1;
            final reason = dialog.$2;
            if (value == null) return;

            final result = await ref
                .read(transactionControllerProvider.notifier)
                .approveRequestTransaction(
                  key: key,
                  invoiceId: '$invoiceId',
                  data: value,
                  reason: reason,
                );
            if (result == null || !context.mounted) return;
            context.showSuccessMessage(result.msg);
            ref.invalidate(fetchDetailRequestTransactionProvider);
            ref.invalidate(fetchDetailRequestTransactionTimelineProvider);
            ref.invalidate(fetchAllTransactionTypeProvider);
            statusSelected.value = status;
          },
        ),
      ),
    );
  }

  Future<(String?, String?)> _showDialogValueAndReason(
    BuildContext context,
    String status,
  ) async {
    String message = '';
    String? value;
    String? reason;
    bool isInputDialog = false;
    bool required = false;

    switch (status) {
      case 'Mudir Setuju':
        message =
            'Apakah Anda menyetujui Pengajuan ini? klik setuju. Selanjutnya data akan dikirim ke manager untuk dilakukan persetujuan';
        reason = 'Pesan untuk pengadaan ini, jika ada';
        value = 'aprove_mudir';
        isInputDialog = true;
        break;
      case 'Atasan Setuju':
        message =
            'Apakah Anda menyetujui Pengajuan ini? klik setuju, Selanjutnya data akan dikirim kebagian keuangan';
        value = 'aprove_manager';
        break;
      case 'Keuangan Proses':
        message =
            'Apakah Anda akan memproses Pengajuan ini? klik proses. Selanjutnya data akan dikirim ke bagian logistik.';
        reason = 'Pesan untuk bagian logistik, jika ada';
        value = 'aprove_keuangan';
        isInputDialog = true;
        break;
      case 'Mudir Menolak':
        message = 'Anda menolak Permintaan ini, silahkan isi alasan Anda';
        value = 'reject_mudir';
        isInputDialog = true;
        required = true;
        break;
      case 'Atasan Menolak':
        message = 'Anda menolak Permintaan ini, silahkan isi alasan Anda';
        value = 'reject_manager';
        isInputDialog = true;
        required = true;
        break;
      case 'Keuangan Menolak':
        message = 'Anda menolak Permintaan ini, silahkan isi alasan Anda';
        value = 'reject_keuangan';
        isInputDialog = true;
        required = true;
        break;
      case 'Konfirmasi':
        message =
            'Apakah Anda akan mengonfirmasi Pengajuan ini? klik proses dan silahkan berbelanja';
        value = 'confirm_humas';
        break;
      case 'Selesai':
        message =
            'Pastikan barang yang dipesan sudah tersedia? Masukkan Nomor Nota dan klik selesai';
        reason = 'Ketik Nomor Nota';
        value = 'finish_humas';
        isInputDialog = true;
        required = true;
        break;
      case 'Barang Diterima':
        message =
            'Pastikan barang atau uang yang di ajukan sudah Anda terima? klik selesai untuk menyelesaikan proses permohonan ini';
        value = 'finish_user';
        break;
      default:
        break;
    }
    if (isInputDialog) {
      final input = await showTextInputDialog(
        context: context,
        title: 'Info',
        message: message,
        textFields: [
          DialogTextField(
            hintText: reason ?? 'Alasan Anda',
            keyboardType: TextInputType.text,
            validator: (value) {
              if (required) return 'tidak boleh kosong';
              return null;
            },
            autocorrect: true,
          ),
        ],
      );
      reason = input?.firstOrNull;
      if (reason == null) return (null, null);
    } else {
      final result = await showOkCancelAlertDialog(
        context: context,
        title: 'Info',
        message: message,
      );
      if (result == OkCancelResult.cancel) return (null, null);
    }
    return (value, reason);
  }

  Widget _buildItemProgress(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) {
    final fetchDetailMedicineRequest = ref.watch(
      fetchDetailRequestTransactionTimelineProvider(
        key: key,
        invoiceId: '$invoiceId',
      ),
    );
    final timelineMedicineRequest = fetchDetailMedicineRequest.valueOrNull;
    final info = timelineMedicineRequest?.info;
    final data = timelineMedicineRequest?.data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Timeline Permohonan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data?.length ?? 0, // Set number of progress items
          itemBuilder: (context, index) {
            final timeline = data?.elementAtOrNull(index);

            return _buildItemTimeline(context, ref, key, timeline);
          },
        ),
      ],
    );
  }

  Widget _buildItemTimeline(
    BuildContext context,
    WidgetRef ref,
    String key,
    JobData? data,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdvancedAvatar(
            image: CachedNetworkImageProvider('${data?.img}'),
            size: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorPrimary,
            ),
            child: Icon(
              Icons.work,
              color: context.colorOnPrimary,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data?.name_staff}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: context.colorOnSurface.withOpacity(0.87),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '${data?.note}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: context.colorOnSurface.withOpacity(0.78),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '${data?.date}',
                  style: context.bodySmall?.copyWith(
                    color: context.colorOnSurface.withOpacity(0.60),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: data?.status == 'ditolak'
                  ? context.colorError
                  : data?.status == "pengajuan"
                      ? context.colorPrimaryContainer
                      : context.colorPrimary,
            ),
            child: Text(
              '${data?.status}',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: data?.status == 'ditolak'
                    ? context.colorOnError
                    : data?.status == "pengajuan"
                        ? context.colorPrimary
                        : context.colorOnPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
