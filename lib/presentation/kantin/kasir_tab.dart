import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/kantin/kantin_models.dart';
import 'package:syathiby/models/kantin/kantin_repository.dart';
import 'package:syathiby/models/kantin/kantin_titipan_models.dart';
import 'package:syathiby/models/kantin/kantin_titipan_repository.dart';
import 'package:syathiby/presentation/widgets/gambar_zoom.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

import 'kantin_widgets.dart';

enum _Langkah { pilih, kartu, preview, nota }

/// Kasir kantin: (1) pilih barang (banyak sekaligus, total langsung tampil)
/// -> (2) tap kartu santri -> (3) pratinjau konfirmasi (detail santri, item,
/// saldo sebelum/sesudah, jatah harian) -> (4) konfirmasi & bayar -> (5) nota.
/// Pembaca RFID USB/OTG bekerja sebagai keyboard dan mengirim Enter, jadi
/// kolom kartu cukup memakai onSubmitted. Hak akses dan semua batas (stok,
/// saldo, jam, batas harian) diputuskan server.
class KasirTab extends HookConsumerWidget {
  const KasirTab({super.key, required this.keySesi});
  final String keySesi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langkah = useState(_Langkah.pilih);
    final kartuCtl = useTextEditingController();
    final fokus = useFocusNode();
    final cari = useState('');
    final keranjang = useState(const Keranjang());
    final metode = useState('tabungan');
    final preview = useState<KantinPreview?>(null);
    final token = useRef<String?>(null);
    final sibuk = useState(false);
    final galat = useState<String?>(null);
    final nota = useState<KantinNota?>(null);

    void ubahKeranjang(Keranjang baru) {
      keranjang.value = baru;
      token.value = null; // isi transaksi berubah -> transaksi baru
      preview.value = null;
      galat.value = null;
    }

    void ulang() {
      langkah.value = _Langkah.pilih;
      keranjang.value = const Keranjang();
      metode.value = 'tabungan';
      preview.value = null;
      token.value = null;
      galat.value = null;
      nota.value = null;
      kartuCtl.clear();
      cari.value = '';
    }

    void kembaliKeBarang() {
      langkah.value = _Langkah.pilih;
      preview.value = null;
      token.value = null;
      galat.value = null;
    }

    Future<void> pratinjau() async {
      final id = kartuCtl.text.trim();
      if (id.isEmpty || sibuk.value) return;
      sibuk.value = true;
      galat.value = null;
      try {
        final p = await kantinPreview(ref, key: keySesi, idCard: id, keranjang: keranjang.value, metode: metode.value);
        preview.value = p;
        token.value = null; // kartu/isi bisa berbeda dari percobaan sebelumnya
        langkah.value = _Langkah.preview;
      } catch (e) {
        galat.value = kantinPesanError(e);
      } finally {
        sibuk.value = false;
      }
    }

    Future<void> bayar({required String idCard}) async {
      if (keranjang.value.kosong || sibuk.value) return;
      sibuk.value = true;
      galat.value = null;
      token.value ??= buatTokenKantin();
      try {
        nota.value = await kantinSimpan(
          ref,
          key: keySesi,
          idCard: idCard,
          keranjang: keranjang.value,
          metode: metode.value,
          token: token.value!,
        );
        token.value = null;
        langkah.value = _Langkah.nota;
        ref.invalidate(kantinRiwayatProvider);
        ref.invalidate(kantinKatalogProvider(keySesi));
        ref.invalidate(kantinPenitipProvider(keySesi));
      } catch (e) {
        // Token sengaja DIPERTAHANKAN: kalau koneksi putus setelah server
        // memproses, mencoba lagi tidak memotong saldo dua kali.
        galat.value = kantinPesanError(e);
      } finally {
        sibuk.value = false;
      }
    }

    switch (langkah.value) {
      case _Langkah.nota:
        return NotaView(nota: nota.value!, onBaru: ulang);
      case _Langkah.kartu:
        return _LangkahKartu(
          keranjang: keranjang.value,
          tunai: metode.value == 'tunai',
          kartuCtl: kartuCtl,
          fokus: fokus,
          sibuk: sibuk.value,
          galat: galat.value,
          onPratinjau: pratinjau,
          onKembali: kembaliKeBarang,
        );
      case _Langkah.preview:
        return _LangkahPreview(
          preview: preview.value!,
          sibuk: sibuk.value,
          galat: galat.value,
          onKonfirmasi: () => bayar(idCard: kartuCtl.text.trim()),
          onBatal: ulang,
          onGantiKartu: () {
            token.value = null;
            preview.value = null;
            galat.value = null;
            kartuCtl.clear();
            langkah.value = _Langkah.kartu;
          },
          onUbahBarang: kembaliKeBarang,
        );
      case _Langkah.pilih:
        break;
    }

    final katalog = ref.watch(kantinKatalogProvider(keySesi));
    final total = keranjang.value.total;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Cari produk',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => cari.value = v.trim().toLowerCase(),
          ),
        ),
        Expanded(
          child: katalog.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => KantinPesan(ikon: Icons.lock_outline, teks: kantinPesanError(e)),
            data: (kat) {
              final daftar = kat.produk
                  .where((p) =>
                      p.aktif &&
                      p.stok > 0 &&
                      (cari.value.isEmpty ||
                          p.nama.toLowerCase().contains(cari.value) ||
                          p.kode.toLowerCase().contains(cari.value)))
                  .toList();
              if (daftar.isEmpty) {
                return const KantinPesan(ikon: Icons.inventory_2_outlined, teks: 'Tidak ada produk tersedia.');
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: daftar.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final p = daftar[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(p.nama),
                    subtitle: Text([
                      rp(p.harga),
                      'stok ${p.stok} ${p.satuan}',
                      if (p.titipan) 'titipan',
                    ].join(' · ')),
                    trailing: KantinStepper(
                      jumlah: keranjang.value.jumlahDari(p.id),
                      bisaTambah: keranjang.value.bisaTambah(p),
                      onTambah: () => ubahKeranjang(keranjang.value.tambah(p)),
                      onKurang: () => ubahKeranjang(keranjang.value.kurang(p)),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Material(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!keranjang.value.kosong)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      keranjang.value.baris.map((b) => '${b.produk.nama} x${b.jumlah}').join(', '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodySmall,
                    ),
                  ),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'tabungan', label: Text('Kartu Santri'), icon: Icon(Icons.credit_card)),
                    ButtonSegment(value: 'tunai', label: Text('Tunai'), icon: Icon(Icons.payments)),
                  ],
                  selected: {metode.value},
                  onSelectionChanged: (s) {
                    metode.value = s.first;
                    token.value = null;
                  },
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: context.bodyMedium),
                    Text(rp(total), style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: keranjang.value.kosong
                        ? null
                        : () {
                            galat.value = null;
                            langkah.value = _Langkah.kartu;
                          },
                    icon: const Icon(Icons.nfc),
                    label: const Text('Lanjut: Tap Kartu Santri'),
                  ),
                ),
                if (!keranjang.value.kosong)
                  TextButton(onPressed: ulang, child: const Text('Kosongkan keranjang')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RingkasanItem extends StatelessWidget {
  const _RingkasanItem({required this.keranjang});
  final Keranjang keranjang;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final b in keranjang.baris) BarisNilai('${b.produk.nama} x${b.jumlah}', rp(b.subtotal)),
        const Divider(),
        BarisNilai('Total', rp(keranjang.total), tebal: true),
      ],
    );
  }
}

class _LangkahKartu extends StatelessWidget {
  const _LangkahKartu({
    required this.keranjang,
    required this.tunai,
    required this.kartuCtl,
    required this.fokus,
    required this.sibuk,
    required this.galat,
    required this.onPratinjau,
    required this.onKembali,
  });
  final Keranjang keranjang;
  final bool tunai;
  final TextEditingController kartuCtl;
  final FocusNode fokus;
  final bool sibuk;
  final String? galat;
  final Future<void> Function() onPratinjau;
  final VoidCallback onKembali;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Total belanja', style: context.bodySmall),
        Text(rp(keranjang.total), style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 28)),
        const SizedBox(height: 4),
        _RingkasanItem(keranjang: keranjang),
        const SizedBox(height: 16),
        Text('Minta santri men-tap kartunya', style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        if (tunai)
          const KantinBanner(teks: 'Tunai: kartu tetap di-tap agar pembelian tercatat atas nama santri, saldo santri tidak dipotong.'),
        const SizedBox(height: 8),
        TextField(
          controller: kartuCtl,
          focusNode: fokus,
          autofocus: true,
          enabled: !sibuk,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => onPratinjau(),
          decoration: InputDecoration(
            labelText: 'Nomor kartu RFID',
            hintText: 'Tempelkan kartu pada pembaca atau ketik nomor',
            prefixIcon: const Icon(Icons.credit_card),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              tooltip: 'Pratinjau',
              icon: const Icon(Icons.search),
              onPressed: sibuk ? null : onPratinjau,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: sibuk ? null : onPratinjau,
          icon: sibuk
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.visibility),
          label: Text(sibuk ? 'Memeriksa kartu...' : 'Lihat Pratinjau Pembelian'),
        ),
        if (galat != null) KantinBanner(teks: galat!, jenis: JenisBanner.merah),
        const SizedBox(height: 8),
        TextButton.icon(onPressed: sibuk ? null : onKembali, icon: const Icon(Icons.arrow_back), label: const Text('Ubah barang')),
      ],
    );
  }
}

class _LangkahPreview extends StatelessWidget {
  const _LangkahPreview({
    required this.preview,
    required this.sibuk,
    required this.galat,
    required this.onKonfirmasi,
    required this.onBatal,
    required this.onGantiKartu,
    required this.onUbahBarang,
  });
  final KantinPreview preview;
  final bool sibuk;
  final String? galat;
  final VoidCallback onKonfirmasi;
  final VoidCallback onBatal;
  final VoidCallback onGantiKartu;
  final VoidCallback onUbahBarang;

  @override
  Widget build(BuildContext context) {
    final s = preview.siswa;
    final tunai = preview.metode == 'tunai';
    final adaPeringatanHutang = preview.peringatan.any((w) => w.toLowerCase().contains('berhutang'));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Konfirmasi pembelian', style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: s.foto.isEmpty
                      ? null
                      : () => showGambarZoom(context, url: s.foto, judul: s.nama),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 72,
                      height: 90,
                      child: s.foto.isEmpty
                          ? const ColoredBox(color: Color(0xFFE0E0E0), child: Icon(Icons.person, size: 40, color: Colors.grey))
                          : Image.network(
                              s.foto,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const ColoredBox(color: Color(0xFFE0E0E0), child: Icon(Icons.person, size: 40, color: Colors.grey)),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.nama, style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 2),
                      Text('NIS ${s.nis}'),
                      if (s.kelas.isNotEmpty) Text('Kelas ${s.kelas}'),
                      if (s.gender.isNotEmpty) Text(s.gender),
                      Text('Kartu ${s.kartu}', style: context.bodySmall),
                      if (!tunai)
                        Text(
                          'Saldo: ${labelSaldo(s.saldo)}',
                          style: context.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: s.saldo < 0 ? Colors.red : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final i in preview.items) BarisNilai('${i.nama} x${i.jumlah}', rp(i.subtotal)),
        const Divider(),
        BarisNilai('Total belanja', rp(preview.total), tebal: true),
        const SizedBox(height: 8),
        if (tunai)
          const KantinBanner(teks: 'Tunai: saldo santri tidak dipotong. Terima uang sebesar total belanja.')
        else
          Card(
            color: context.colorPrimary.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  BarisNilai('Saldo sebelum', labelSaldo(preview.saldoSebelum),
                      warna: preview.saldoSebelum < 0 ? Colors.red : null),
                  BarisNilai('Saldo sesudah', labelSaldo(preview.saldoSesudah),
                      tebal: true, warna: preview.saldoSesudah < 0 ? Colors.red : null),
                  if (preview.batasHarian != null && preview.batasHarian! > 0) ...[
                    const Divider(),
                    BarisNilai('Batas jajan harian', rp(preview.batasHarian!)),
                    if (preview.sisaJatahHarian != null) BarisNilai('Sisa jatah hari ini', rp(preview.sisaJatahHarian!)),
                  ],
                ],
              ),
            ),
          ),
        for (final w in preview.peringatan) KantinBanner(teks: w, jenis: JenisBanner.kuning),
        if (!tunai && preview.menjadiHutang && !adaPeringatanHutang)
          KantinBanner(
            teks: 'Santri akan berhutang ${rp(preview.hutangSesudah)}'
                '${preview.batasHutang > 0 ? ' (batas hutang ${rp(preview.batasHutang)}'
                    '${preview.sisaBatasHutang != null ? ', sisa ${rp(preview.sisaBatasHutang!)}' : ''})' : ''}',
            jenis: JenisBanner.kuning,
          ),
        if (preview.alasanTolak.isNotEmpty) KantinBanner(teks: preview.alasanTolak, jenis: JenisBanner.merah),
        if (!preview.bisaBayar && preview.alasanTolak.isEmpty)
          const KantinBanner(teks: 'Transaksi ini tidak dapat dilanjutkan.', jenis: JenisBanner.merah),
        if (galat != null) KantinBanner(teks: galat!, jenis: JenisBanner.merah),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: (sibuk || !preview.bolehKonfirmasi) ? null : onKonfirmasi,
          icon: sibuk
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.check_circle),
          label: Text(sibuk ? 'Memproses...' : (tunai ? 'Konfirmasi & Terima Tunai ${rp(preview.total)}' : 'Konfirmasi & Bayar ${rp(preview.total)}')),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: sibuk ? null : onBatal, child: const Text('Batal'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: sibuk ? null : onGantiKartu, child: const Text('Ganti kartu'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: sibuk ? null : onUbahBarang, child: const Text('Ubah barang'))),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class NotaView extends StatelessWidget {
  const NotaView({super.key, required this.nota, required this.onBaru});
  final KantinNota nota;
  final VoidCallback onBaru;

  @override
  Widget build(BuildContext context) {
    final tabungan = nota.metode == 'tabungan';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Icon(Icons.check_circle, size: 56, color: context.colorPrimary),
        const SizedBox(height: 8),
        Center(child: Text('Transaksi berhasil', style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
        if (nota.duplikat)
          const KantinBanner(teks: 'Transaksi ini sudah tersimpan sebelumnya (saldo tidak dipotong dua kali).'),
        const SizedBox(height: 12),
        Text('No. nota: ${nota.noNota}'),
        Text('${nota.tanggal} ${nota.jam}'),
        if (nota.namaSantri.isNotEmpty) Text('Santri: ${nota.namaSantri}'),
        Text('Metode: ${tabungan ? 'Kartu Santri' : 'Tunai'}'),
        const Divider(height: 24),
        for (final i in nota.items) BarisNilai('${i.nama} x${i.jumlah}', rp(i.subtotal)),
        const Divider(height: 24),
        BarisNilai('Total', rp(nota.total), tebal: true),
        if (tabungan) ...[
          const SizedBox(height: 4),
          Text('Saldo sebelum: ${labelSaldo(nota.saldoSebelum)}'),
          Text('Saldo sesudah: ${labelSaldo(nota.saldoSesudah)}'),
          if (nota.hutangSesudah > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Hutang sesudah: ${rp(nota.hutangSesudah)}',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(onPressed: onBaru, icon: const Icon(Icons.add), label: const Text('Transaksi Baru')),
      ],
    );
  }
}
