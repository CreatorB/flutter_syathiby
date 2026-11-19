import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/transaction/petugas_pengajuan.dart';
import 'package:syathiby/models/transaction/request_transaction.dart';
import 'package:syathiby/presentation/transaction/transaction_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/alur_kegiatan.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';

/// Form pengajuan bebas (12 Nov 2026).
///
/// Pemohon tidak perlu katalog barang: ia menulis sendiri nama barang,
/// nominal, jumlah, dan deskripsi tiap item, ditambah tujuan pengajuan.
/// Satu pengajuan bisa berisi banyak item dan totalnya dihitung otomatis.
///
/// Ditulis ulang dari `AddRequestTransactionScreen` yang masih memakai
/// katalog `barang` (mode lama).
class AddPengajuanScreen extends HookConsumerWidget {
  const AddPengajuanScreen({super.key, this.jenisAwal});

  /// Jenis kegiatan bawaan, mis. 'Pengadaan Barang' atau 'Perbaikan'.
  final String? jenisAwal;

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

    final activityName = useTextEditingController();
    final lokasi = useTextEditingController();
    final tujuan = useTextEditingController();
    final keterangan = useTextEditingController();

    final timSelected = useState<TimPerbaikan?>(null);
    final drafts = useState<List<_ItemDraft>>([_ItemDraft(id: 1)]);

    final petugasPengajuan =
        ref.watch(fetchPetugasPengajuanProvider(key: key)).valueOrNull;
    // Jenis pengajuan TIDAK lagi dipilih di layar (permintaan owner 19 Nov
    // 2026: "kenapa harus ada jenis kegiatan? kalau pengadaan ya fokus di
    // pengadaan, kalau perbaikan fokus di perbaikan"). Jenisnya sudah
    // ditentukan menu yang dipakai: "Ajukan Pengadaan" -> Pengadaan Barang,
    // "Ajukan Perbaikan" -> Perbaikan.
    final jenisTerpilih = jenisDariMenu(jenisAwal);
    final pakaiAlurTim = isAlurTim(jenisTerpilih);
    // Perbaikan: dikerjakan Tim Maintenance, tanpa nominal barang.
    // Pengadaan: ditugaskan ke Tim Admin Keuangan, ada nominal barang.
    final tanpaNominal = jenisTanpaNominal(jenisTerpilih);
    final timList = pakaiAlurTim
        ? (petugasPengajuan?.tim ?? const <TimPerbaikan>[])
        : (petugasPengajuan?.keuangan ?? const <TimPerbaikan>[]);
    final timAktif =
        timSelected.value ?? (timList.length == 1 ? timList.first : null);
    final namaTim = namaTimUntukJenis(jenisTerpilih);

    final total = drafts.value.fold<double>(
      0,
      (sum, d) => sum + (d.harga * d.jumlah),
    );
    final totalFormat = ref.watch(formatCurrencyProvider('$total'));
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    void tambahItem() {
      final idTerbaru = drafts.value.fold<int>(
        0,
        (max, d) => d.id > max ? d.id : max,
      );
      drafts.value = [...drafts.value, _ItemDraft(id: idTerbaru + 1)];
    }

    void hapusItem(int index) {
      if (drafts.value.length <= 1) return;
      final baru = [...drafts.value]..removeAt(index);
      drafts.value = baru;
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Form(
        key: formKey,
        child: Scaffold(
          appBar: AppBar(
            title: Text(pakaiAlurTim ? 'Ajukan Perbaikan' : 'Ajukan Pengadaan'),
            actions: [
              TextButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  if (pakaiAlurTim && timList.isNotEmpty && timAktif == null) {
                    context.showErrorMessage('Pilih tim yang mengerjakan');
                    return;
                  }
                  if (!pakaiAlurTim && timList.isNotEmpty && timAktif == null) {
                    context.showErrorMessage('Pilih tim admin keuangan');
                    return;
                  }
                  // Perbaikan: tanpa nominal, cukup keterangan yang perlu
                  // diperbaiki. Pengadaan: minimal satu barang bernominal.
                  final adaItemValid = tanpaNominal
                      ? drafts.value.any(
                          (d) =>
                              d.nama.trim().isNotEmpty ||
                              d.deskripsi.trim().isNotEmpty,
                        )
                      : drafts.value.any(
                          (d) =>
                              d.nama.trim().isNotEmpty &&
                              d.harga > 0 &&
                              d.jumlah > 0,
                        );
                  if (!adaItemValid) {
                    context.showErrorMessage(
                      tanpaNominal
                          ? 'Tuliskan apa yang perlu diperbaiki'
                          : 'Isi minimal satu barang: nama, nominal, dan jumlah',
                    );
                    return;
                  }
                  final items = drafts.value
                      .where(
                        (d) => tanpaNominal
                            ? d.nama.trim().isNotEmpty ||
                                d.deskripsi.trim().isNotEmpty
                            : d.nama.trim().isNotEmpty &&
                                d.harga > 0 &&
                                d.jumlah > 0,
                      )
                      .map(
                        (d) => Barang(
                          namaItem: d.nama.trim().isEmpty
                              ? 'Perbaikan'
                              : d.nama.trim(),
                          amountProduct: tanpaNominal ? 1 : d.jumlah,
                          newPrice: tanpaNominal ? '0' : '${d.harga}',
                          notes: d.deskripsi.trim(),
                        ),
                      )
                      .toList();

                  final result = await ref
                      .read(transactionControllerProvider.notifier)
                      .addOrderTransaction(
                        requestTransaction: RequestTransaction(
                          key: key,
                          // Lokasi agora diketik pemohon (lihat kolom Lokasi),
                          // jadi tidak ada lagi id unit yang dikirim.
                          id: '',
                          location: lokasi.text.trim(),
                          jenisKegiatan: jenisTerpilih,
                          note: keterangan.text.trim(),
                          tujuan: tujuan.text.trim(),
                          nameKegiatan: activityName.text.trim(),
                          paymentAmount: 0,
                          paymentType: 1,
                          totalOrder: total,
                          product: items,
                          idTim: timAktif?.id,
                        ),
                      );
                  if (result == null || !context.mounted) return;
                  context.showSuccessMessage(
                    'Berhasil menambah permohonan ${result.invoice}',
                  );
                  ref.invalidate(fetchHistoryTransactionProvider);
                  context.goNamed(AppRoute.historyTransaction.name);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Simpan'),
              )
            ],
          ),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 140),
                children: [
                  _buildFlowInfo(context, isAlurTim: pakaiAlurTim),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: activityName,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            labelText: 'Nama *',
                            hintText: tanpaNominal
                                ? 'Contoh: Lampu kelas 1 rusak'
                                : 'Contoh: Alat tulis kantor',
                            prefixIcon: const Icon(Icons.local_activity),
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Nama wajib diisi'
                                  : null,
                        ),
                        const SizedBox(height: 8),
                        // Lokasi diketik sendiri, bukan pilih dari daftar unit:
                        // pengajuan bisa berupa barang, jadi unit/gedung yang
                        // dibutuhkan tidak selalu salah satu dari daftar tetap.
                        TextFormField(
                          controller: lokasi,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            labelText: 'Lokasi *',
                            hintText: 'Contoh: UKP / Asrama / Madrasah MSW',
                            prefixIcon: const Icon(Icons.location_on),
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Lokasi wajib diisi'
                                  : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: tujuan,
                          maxLines: 2,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            labelText: 'Tujuan Pengajuan *',
                            hintText: 'Contoh: kebutuhan kegiatan belajar',
                            prefixIcon: const Icon(Icons.flag_outlined),
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Tujuan pengajuan wajib diisi'
                                  : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: keterangan,
                          maxLines: 2,
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            labelText: 'Keterangan Tambahan',
                            prefixIcon: const Icon(Icons.description),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (timList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: DropdownSearch<TimPerbaikan>(
                        // Key ikut daftar tim: kalau jenis kegiatan diganti,
                        // widget harus dibangun ulang supaya pilihan otomatis
                        // (satu tim) ikut terisi, bukan tampil kosong.
                        key: ValueKey(
                          'tim-${pakaiAlurTim ? 'maintenance' : 'keuangan'}-'
                          '${timList.map((e) => e.id).join('-')}',
                        ),
                        items: timList,
                        selectedItem: timAktif,
                        compareFn: (a, b) => a.id == b.id,
                        itemAsString: (e) => '${e.nama}',
                        popupProps: const PopupProps.menu(
                          showSelectedItems: true,
                        ),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: 'Pilih $namaTim',
                            labelText: '$namaTim *',
                            border: OutlineInputBorder(),
                            isDense: true,
                            prefixIcon: Icon(Icons.engineering),
                          ),
                        ),
                        validator: (value) =>
                            value == null ? 'Pilih $namaTim' : null,
                        onChanged: (value) {
                          timSelected.value = value;
                        },
                      ),
                    ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tanpaNominal
                              ? 'Yang Perlu Diperbaiki'
                              : 'Rincian Barang',
                          style: context.bodyMediumBold,
                        ),
                        TextButton.icon(
                          onPressed: tambahItem,
                          icon: const Icon(Icons.add),
                          label: Text(tanpaNominal ? 'Tambah' : 'Tambah Barang'),
                        ),
                      ],
                    ),
                  ),
                  for (var index = 0; index < drafts.value.length; index++)
                    _ItemRow(
                      key: ValueKey('item-${drafts.value[index].id}'),
                      draft: drafts.value[index],
                      tanpaNominal: tanpaNominal,
                      formatRupiah: (value) =>
                          ref.read(formatCurrencyProvider('$value')),
                      onChanged: () => drafts.value = [...drafts.value],
                      onRemove: () => hapusItem(index),
                    ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: context.colorSurface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tanpaNominal ? 'Perbaikan' : 'Total Pengajuan',
                        style: context.bodyMediumBold,
                      ),
                      Text(
                        tanpaNominal ? 'Tanpa nominal' : totalFormat,
                        style: context.bodyMediumBold?.copyWith(
                          color: context.colorPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: ref.watch(transactionControllerProvider).isLoading,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlowInfo(BuildContext context, {required bool isAlurTim}) {
    final alurText = isAlurTim
        ? 'Diajukan -> ACC Atasan -> ACC Mudir (otomatis) -> Dikerjakan '
            '$namaTimMaintenance -> Klaim selesai -> Anda mengesahkan. '
            'Tanpa nominal barang; yang diperbaiki ditulis bebas. Bisa '
            'ditolak selama belum dikerjakan.'
        : 'Diajukan -> ACC Atasan -> ACC Mudir (otomatis) -> ACC & Cairkan Dana '
            'oleh $namaTimKeuangan -> barang datang -> Anda mengesahkan. '
            'Bisa ditolak selama belum dicairkan.';
    final judul = isAlurTim
        ? 'Permintaan perbaikan ke $namaTimMaintenance'
        : 'Pengadaan barang ke $namaTimKeuangan';
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(judul, style: context.bodyMediumBold),
            const SizedBox(height: 4),
            Text(alurText, style: context.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Draft satu item pengajuan (dipakai juga sebagai state baris di form).
class _ItemDraft {
  _ItemDraft({required this.id});

  int id;
  String nama = '';
  double harga = 0;
  double jumlah = 1;
  String deskripsi = '';
}

/// Baris input satu item: nama barang, nominal, jumlah, deskripsi.
class _ItemRow extends StatefulWidget {
  const _ItemRow({
    super.key,
    required this.draft,
    required this.tanpaNominal,
    required this.formatRupiah,
    required this.onChanged,
    required this.onRemove,
  });

  final _ItemDraft draft;

  /// Perbaikan: nama & deskripsi saja, tanpa nominal dan jumlah.
  final bool tanpaNominal;
  final String Function(double) formatRupiah;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  late final TextEditingController nama;
  late final TextEditingController harga;
  late final TextEditingController jumlah;
  late final TextEditingController deskripsi;

  @override
  void initState() {
    super.initState();
    nama = TextEditingController(text: widget.draft.nama);
    harga = TextEditingController(text: widget.draft.harga > 0 ? '${widget.draft.harga}' : '');
    jumlah = TextEditingController(text: '${widget.draft.jumlah}');
    deskripsi = TextEditingController(text: widget.draft.deskripsi);
  }

  @override
  void dispose() {
    nama.dispose();
    harga.dispose();
    jumlah.dispose();
    deskripsi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtotalFormat =
        widget.formatRupiah(widget.draft.harga * widget.draft.jumlah);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: nama,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      isDense: true,
                      border: const OutlineInputBorder(),
                      labelText: widget.tanpaNominal
                          ? 'Barang / Perkara yang perlu diperbaiki *'
                          : 'Nama Barang *',
                      prefixIcon: const Icon(Icons.inventory_2_outlined),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? (widget.tanpaNominal
                                ? 'Tuliskan yang perlu diperbaiki'
                                : 'Nama barang wajib diisi')
                            : null,
                    onChanged: (value) {
                      widget.draft.nama = value;
                      widget.onChanged();
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus barang',
                  onPressed: widget.onRemove,
                  icon: Icon(Icons.delete_outline, color: context.colorError),
                ),
              ],
            ),
            if (!widget.tanpaNominal) ...[
              const SizedBox(height: 8),
              Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: harga,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      labelText: 'Nominal (Rp) *',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    validator: (value) {
                      final angka = double.tryParse(
                        (value ?? '').replaceAll('.', '').replaceAll(',', ''),
                      );
                      if (angka == null || angka <= 0) {
                        return 'nominal tidak valid';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      widget.draft.harga = double.tryParse(
                            value.replaceAll('.', '').replaceAll(',', ''),
                          ) ??
                          0;
                      widget.onChanged();
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 110,
                  child: TextFormField(
                    controller: jumlah,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      labelText: 'Jumlah *',
                    ),
                    validator: (value) {
                      final angka = double.tryParse(
                        (value ?? '').replaceAll('.', '').replaceAll(',', ''),
                      );
                      if (angka == null || angka <= 0) {
                        return 'jumlah tidak valid';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      widget.draft.jumlah = double.tryParse(
                            value.replaceAll('.', '').replaceAll(',', ''),
                          ) ??
                          0;
                      widget.onChanged();
                      setState(() {});
                    },
                  ),
                ),
              ],
              ),
            ],
            const SizedBox(height: 8),
            TextFormField(
              controller: deskripsi,
              maxLines: 2,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                labelText: 'Deskripsi / Spesifikasi',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              onChanged: (value) {
                widget.draft.deskripsi = value;
                widget.onChanged();
              },
            ),
            if (!widget.tanpaNominal) ...[
              const SizedBox(height: 6),
              Text(
                'Subtotal: $subtotalFormat',
                style: context.bodySmall?.copyWith(color: context.colorPrimary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
