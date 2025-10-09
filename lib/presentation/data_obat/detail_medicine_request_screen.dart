import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/job/job_detail.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'medicine_controller.dart';

class DetailMedicineRequestScreen extends HookConsumerWidget {
  final String? invoiceId;
  final String? status;

  const DetailMedicineRequestScreen({
    super.key,
    this.invoiceId,
    this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      medicineControllerProvider,
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';

    final fetchDetailMedicineRequest = ref.watch(
      detailMedicineRequestProvider(
        key: key,
        invoiceId: '$invoiceId',
      ),
    );

    final detailMedicineRequest = fetchDetailMedicineRequest.valueOrNull;
    final invoice = detailMedicineRequest?.struk;
    final data = detailMedicineRequest?.data;
    final formatDate = ref.watch(
      formatDateProvider('${invoice?.date}', format: 'EEE, dd MMMM yyyy'),
    );
    final statusSelected = useState<String?>(status);
    final total = ref.watch(formatCurrencyProvider('${invoice?.totalOrder}'));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Permohonan'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          detailMedicineRequestProvider(
            key: key,
            invoiceId: '$invoiceId',
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchDetailMedicineRequest.isLoading,
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
                      '${product?.amount} ${product?.unit}',
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
            'Setujui',
            'Tolak',
            'Proses',
            'Selesai',
            'Sudah Diterima',
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
                .read(medicineControllerProvider.notifier)
                .confirmMedicineRequest(
                  key: key,
                  invoiceId: '$invoiceId',
                  data: value,
                  reason: reason,
                );
            if (result == null || !context.mounted) return;
            context.showSuccessMessage(
              result.msg,
            );
            ref.invalidate(detailMedicineRequestProvider);
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
    switch (status) {
      case 'Setujui':
        message =
            'Apakah Anda menyetujui Permintaan ini? data akan dikirim kebagian terkait';
        value = 'aprove_manager';
        break;
      case 'Tolak':
        message = 'Anda menolak Permintaan ini, silahkan isi alasan Anda';
        value = 'reject_manager';
        isInputDialog = true;
        break;
      case 'Proses':
        message =
            'Apakah Anda akan memproses Pengajuan ini? klik proses dan silakan berbelanja';
        value = 'confirm_ukp';
        break;
      case 'Selesai':
        message =
            'Pastikan barang yang dipesan sudah dikirimkan dan klik selesai';
        value = 'finish_ukp';
        break;
      case 'Sudah Diterima':
        message =
            'Pastikan obat yang diminta sudah Anda terima? klik selesai untuk menyelesaikan proses permohonan ini';
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
      timelineMedicineRequestProvider(
        key: key,
        invoiceId: '$invoiceId',
      ),
    );
    final timelineMedicineRequest = fetchDetailMedicineRequest.valueOrNull;
    final info = timelineMedicineRequest?.info;
    final data = timelineMedicineRequest?.data;
    // final data = [
    //   ...?newData,
    //   JobData(
    //     img: info?.img,
    //     date: info?.date,
    //     name_staff: info?.name_staff,
    //     note: info?.note,
    //     no_invoice: info?.no_invoice,
    //     status: info?.status,
    //   ),
    // ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Progress',
            style: TextStyle(
              fontSize: 18,
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
