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
import 'package:syathiby/utils/alur_kegiatan.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../utils/custom_avatar_widget.dart';

/// Nilai `value` untuk `pengadaan/confirm.php` beserta labelnya, urut sesuai
/// alur. Server baru mengirim `struk.aksi` berisi subset nilai ini.
const _actionLabels = <String, String>{
  'aprove_manager': 'ACC Atasan',
  'reject_manager': 'Tolak (Atasan)',
  'aprove_mudir': 'Mudir Setuju',
  'reject_mudir': 'Mudir Menolak',
  'aprove_keuangan': 'Keuangan Proses',
  'reject_keuangan': 'Keuangan Menolak',
  'cairkan_keuangan': 'Keuangan Cairkan',
  'confirm_humas': 'Konfirmasi',
  'finish_humas': 'Selesai',
  'confirm_maintenance': 'Terima & Kerjakan (Tim Perbaikan)',
  'selesai_maintenance': 'Klaim Selesai (Tim Perbaikan)',
  'finish_user': 'Konfirmasi Diterima/Selesai (Pemohon)',
};

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
    final pakaiAlurTim = isAlurTim(invoice?.jenisKegiatan);
    final aksi = invoice?.aksi;
    // aksi null = server lama, tampilkan semua aksi seperti sebelumnya.
    final actions = aksi == null
        ? _actionLabels.keys.toList()
        : aksi.where(_actionLabels.containsKey).toList();
    final showActions = !fetchDetailRequest.isLoading && actions.isNotEmpty;
    final atasanNama = invoice?.atasanNama ?? '';
    final timNama = invoice?.tim?.trim() ?? '';
    final petugasNama = (invoice?.petugas ?? [])
        .map((e) => e.nama ?? e.telp ?? '')
        .where((e) => e.isNotEmpty)
        .join(', ');
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
                    if (invoice?.atasan != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Atasan',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Wrap(
                              alignment: WrapAlignment.end,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              children: [
                                Text(
                                  atasanNama.isNotEmpty ? atasanNama : '-',
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                if (invoice?.atasanOtomatis == 1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: context.colorPrimaryContainer,
                                    ),
                                    child: Text(
                                      'otomatis',
                                      style: context.bodySmall?.copyWith(
                                        color: context.colorOnPrimaryContainer,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (pakaiAlurTim) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tim Perbaikan',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  timNama.isNotEmpty ? timNama : '-',
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                if (petugasNama.isNotEmpty)
                                  Text(
                                    petugasNama,
                                    textAlign: TextAlign.end,
                                    style: context.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
              if (!fetchDetailRequest.isLoading && (data?.isEmpty ?? true))
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    pakaiAlurTim
                        ? 'Tidak ada barang (perbaikan/jasa tanpa barang).'
                        : 'Tidak ada barang.',
                    style: context.bodySmall,
                  ),
                ),
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
      bottomNavigationBar: !showActions
          ? null
          : Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: DropdownSearch<String>(
                selectedItem: actions.contains(statusSelected.value)
                    ? statusSelected.value
                    : null,
                items: actions,
                itemAsString: (value) => _actionLabels[value] ?? value,
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
                  final dialog = await _showDialogValueAndReason(
                    context,
                    status,
                    isAlurTim: pakaiAlurTim,
                  );
                  final value = dialog.$1;
                  final reason = dialog.$2;
                  final nominal = dialog.$3;
                  final penerima = dialog.$4;
                  if (value == null) return;

                  final result = await ref
                      .read(transactionControllerProvider.notifier)
                      .approveRequestTransaction(
                        key: key,
                        invoiceId: '$invoiceId',
                        data: value,
                        reason: reason,
                        nominal: nominal,
                        penerima: penerima,
                      );
                  if (result == null || !context.mounted) return;
                  if (result.errCode == '01') {
                    context.showSuccessMessage(result.msg);
                  } else {
                    // Backend menolak aksi yang tidak sesuai peran/status.
                    context.showErrorMessage(result.msg);
                    return;
                  }
                  ref.invalidate(fetchDetailRequestTransactionProvider);
                  ref.invalidate(fetchDetailRequestTransactionTimelineProvider);
                  ref.invalidate(fetchAllTransactionTypeProvider);
                  statusSelected.value = status;
                },
              ),
            ),
    );
  }

  Future<(String?, String?, String?, String?)> _showDialogValueAndReason(
    BuildContext context,
    String status, {
    bool isAlurTim = false,
  }) async {
    String message = '';
    String? value;
    String? reason;
    String? nominal;
    String? penerima;
    bool isInputDialog = false;
    bool required = false;
    bool isCairkan = false;

    switch (status) {
      case 'aprove_mudir':
        message = isAlurTim
            ? 'Apakah Anda menyetujui Pengajuan ini? Selanjutnya diteruskan ke tim yang dipilih.'
            : 'Apakah Anda menyetujui Pengajuan ini? Selanjutnya diteruskan ke bagian keuangan.';
        reason = 'Pesan untuk pengajuan ini, jika ada';
        value = 'aprove_mudir';
        isInputDialog = true;
        break;
      case 'aprove_manager':
        message = isAlurTim
            ? 'Apakah Anda (Atasan) menyetujui pengajuan ini? Selanjutnya disetujui Mudir otomatis lalu dikerjakan tim yang dipilih.'
            : 'Apakah Anda (Atasan) menyetujui Pengajuan ini? Selanjutnya diteruskan ke Mudir lalu bagian keuangan.';
        reason = 'Pesan untuk pengajuan ini, jika ada';
        value = 'aprove_manager';
        isInputDialog = true;
        break;
      case 'confirm_maintenance':
        message =
            'Terima dan mulai kerjakan pengajuan ini? Setelah dikerjakan, Mudir tidak bisa lagi menolak. Silakan isi keterangan bila perlu.';
        reason = 'Keterangan pekerjaan, jika ada';
        value = 'confirm_maintenance';
        isInputDialog = true;
        break;
      case 'selesai_maintenance':
        message =
            'Apakah pekerjaan sudah selesai? Keterangan wajib diisi sebagai bukti pekerjaan rampung.';
        reason = 'Keterangan pekerjaan yang sudah selesai';
        value = 'selesai_maintenance';
        isInputDialog = true;
        required = true;
        break;
      case 'aprove_keuangan':
        message =
            'Apakah Anda akan memproses Pengajuan ini? klik proses. Selanjutnya data akan dikirim ke bagian logistik.';
        reason = 'Pesan untuk bagian logistik, jika ada';
        value = 'aprove_keuangan';
        isInputDialog = true;
        break;
      case 'cairkan_keuangan':
        message =
            'Masukkan nominal yang dicairkan dan nama penerima dana. Kosongkan nominal bila nilainya sama dengan total pengajuan.';
        value = 'cairkan_keuangan';
        isInputDialog = true;
        isCairkan = true;
        break;
      case 'reject_mudir':
        message = 'Anda menolak Permintaan ini, silahkan isi alasan Anda';
        value = 'reject_mudir';
        isInputDialog = true;
        required = true;
        break;
      case 'reject_manager':
        message =
            'Anda (Atasan) menolak Permintaan ini, silahkan isi alasan Anda';
        value = 'reject_manager';
        isInputDialog = true;
        required = true;
        break;
      case 'reject_keuangan':
        message = 'Anda menolak Permintaan ini, silahkan isi alasan Anda';
        value = 'reject_keuangan';
        isInputDialog = true;
        required = true;
        break;
      case 'confirm_humas':
        message =
            'Apakah Anda akan mengonfirmasi Pengajuan ini? klik proses dan silahkan berbelanja';
        value = 'confirm_humas';
        break;
      case 'finish_humas':
        message =
            'Pastikan barang yang dipesan sudah tersedia? Masukkan Nomor Nota dan klik selesai';
        reason = 'Ketik Nomor Nota';
        value = 'finish_humas';
        isInputDialog = true;
        required = true;
        break;
      case 'finish_user':
        message = isAlurTim
            ? 'Pastikan pekerjaan sudah selesai dan memuaskan. Klik OK untuk menyelesaikan permohonan ini.'
            : 'Pastikan barang atau uang yang di ajukan sudah Anda terima. Klik OK untuk menyelesaikan proses permohonan ini.';
        value = 'finish_user';
        break;
      default:
        break;
    }
    if (isCairkan) {
      // Pencairan butuh dua hal: nominal yang dicairkan dan siapa yang
      // menerimanya. Keduanya jadi parameter terpisah di endpoint
      // `pengadaan/confirm.php`.
      final input = await showTextInputDialog(
        context: context,
        title: 'Pencairan Dana',
        message: message,
        textFields: [
          DialogTextField(
            hintText: 'Nominal pencairan (kosong = total pengajuan)',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final angka = double.tryParse(
                value.replaceAll(RegExp(r'[^0-9]'), ''),
              );
              if (angka == null || angka <= 0) return 'nominal tidak valid';
              return null;
            },
            autocorrect: false,
          ),
          DialogTextField(
            hintText: 'Nama penerima dana',
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'tidak boleh kosong';
              }
              return null;
            },
            autocorrect: true,
          ),
        ],
      );
      if (input == null) return (null, null, null, null);
      nominal = input.elementAtOrNull(0);
      penerima = input.elementAtOrNull(1);
      reason = 'Pencairan dana oleh bagian keuangan';
      return (value, reason, nominal, penerima);
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
              if (required && (value == null || value.trim().isEmpty)) {
                return 'tidak boleh kosong';
              }
              return null;
            },
            autocorrect: true,
          ),
        ],
      );
      reason = input?.firstOrNull;
      if (reason == null) return (null, null, null, null);
    } else {
      final result = await showOkCancelAlertDialog(
        context: context,
        title: 'Info',
        message: message,
      );
      if (result == OkCancelResult.cancel) return (null, null, null, null);
    }
    return (value, reason, nominal, penerima);
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
