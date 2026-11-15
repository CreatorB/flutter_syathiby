import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/models/kantin/kantin_models.dart';
import 'package:syathiby/models/kantin/kantin_repository.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

String _rp(int v) => 'Rp ${NumberFormat.decimalPattern('id_ID').format(v)}';

/// Kasir kantin: scan/ketik kartu RFID -> pilih produk -> bayar.
/// Pembaca RFID USB/OTG bekerja sebagai keyboard dan mengirim Enter, jadi
/// kolom kartu cukup memakai onSubmitted. Hak akses dan semua batas
/// (stok, saldo, jam, batas harian) diputuskan server.
class KasirTab extends HookConsumerWidget {
  const KasirTab({super.key, required this.keySesi});
  final String keySesi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kartuCtl = useTextEditingController();
    final fokus = useFocusNode();
    final cari = useState('');
    final kartu = useState<KantinKartu?>(null);
    final keranjang = useState(const Keranjang());
    final metode = useState('tabungan');
    final token = useRef<String?>(null);
    final sibuk = useState(false);
    final galat = useState<String?>(null);
    final nota = useState<KantinNota?>(null);

    void ubahKeranjang(Keranjang baru) {
      keranjang.value = baru;
      token.value = null; // isi transaksi berubah -> transaksi baru
      galat.value = null;
    }

    void ulang() {
      kartu.value = null;
      keranjang.value = const Keranjang();
      metode.value = 'tabungan';
      token.value = null;
      galat.value = null;
      nota.value = null;
      kartuCtl.clear();
      cari.value = '';
      fokus.requestFocus();
    }

    Future<void> cekKartu() async {
      final id = kartuCtl.text.trim();
      if (id.isEmpty || sibuk.value) return;
      sibuk.value = true;
      galat.value = null;
      try {
        kartu.value = await kantinCekKartu(ref, keySesi, id);
        token.value = null;
      } catch (e) {
        kartu.value = null;
        galat.value = kantinPesanError(e);
      } finally {
        sibuk.value = false;
      }
    }

    Future<void> bayar() async {
      final k = kartu.value;
      if (k == null || keranjang.value.kosong || sibuk.value) return;
      sibuk.value = true;
      galat.value = null;
      token.value ??= buatTokenKantin();
      try {
        nota.value = await kantinSimpan(
          ref,
          key: keySesi,
          idCard: k.idCard,
          keranjang: keranjang.value,
          metode: metode.value,
          token: token.value!,
        );
        token.value = null;
        ref.invalidate(kantinRiwayatProvider);
        ref.invalidate(kantinKatalogProvider(keySesi));
      } catch (e) {
        // Token sengaja DIPERTAHANKAN: kalau koneksi putus setelah server
        // memproses, mencoba lagi tidak memotong saldo dua kali.
        galat.value = kantinPesanError(e);
      } finally {
        sibuk.value = false;
      }
    }

    final n = nota.value;
    if (n != null) return _NotaView(nota: n, onBaru: ulang);

    final katalog = ref.watch(kantinKatalogProvider(keySesi));
    final k = kartu.value;
    final total = keranjang.value.total;
    final kurang = k != null && metode.value == 'tabungan' && total > k.saldo;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        TextField(
          controller: kartuCtl,
          focusNode: fokus,
          autofocus: true,
          enabled: !sibuk.value,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => cekKartu(),
          onChanged: (_) {
            if (kartu.value != null) {
              kartu.value = null;
              keranjang.value = const Keranjang();
              token.value = null;
            }
          },
          decoration: InputDecoration(
            labelText: 'Nomor kartu RFID',
            hintText: 'Tempelkan kartu pada pembaca atau ketik nomor',
            prefixIcon: const Icon(Icons.credit_card),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              tooltip: 'Cek kartu',
              icon: const Icon(Icons.search),
              onPressed: sibuk.value ? null : cekKartu,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: sibuk.value ? null : cekKartu,
          icon: const Icon(Icons.nfc),
          label: const Text('Cek Kartu'),
        ),
        if (galat.value != null) _Banner(teks: galat.value!, merah: true),
        if (k != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(k.nama, style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text('NIS ${k.nis}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Saldo', style: context.bodySmall),
                  Text(_rp(k.saldo), style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Cari produk',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => cari.value = v.trim().toLowerCase(),
          ),
          const SizedBox(height: 4),
          katalog.when(
            loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
            error: (e, _) => _Banner(teks: kantinPesanError(e), merah: true),
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
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Tidak ada produk tersedia.')),
                );
              }
              return Column(
                children: [
                  for (final p in daftar)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(p.nama),
                      subtitle: Text('${_rp(p.harga)} · stok ${p.stok} ${p.satuan}'),
                      trailing: _Stepper(
                        jumlah: keranjang.value.jumlahDari(p.id),
                        bisaTambah: keranjang.value.bisaTambah(p) && !sibuk.value,
                        onTambah: () => ubahKeranjang(keranjang.value.tambah(p)),
                        onKurang: sibuk.value ? null : () => ubahKeranjang(keranjang.value.kurang(p)),
                      ),
                    ),
                ],
              );
            },
          ),
          const Divider(height: 24),
          Text('Keranjang', style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          if (keranjang.value.kosong)
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Belum ada barang.'))
          else
            for (final b in keranjang.value.baris)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('${b.produk.nama} x${b.jumlah}'),
                subtitle: Text(_rp(b.subtotal)),
                trailing: IconButton(
                  tooltip: 'Hapus',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: sibuk.value ? null : () => ubahKeranjang(keranjang.value.hapus(b.produk.id)),
                ),
              ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'tabungan', label: Text('Tabungan'), icon: Icon(Icons.account_balance_wallet)),
              ButtonSegment(value: 'tunai', label: Text('Tunai'), icon: Icon(Icons.payments)),
            ],
            selected: {metode.value},
            onSelectionChanged: sibuk.value
                ? null
                : (s) {
                    metode.value = s.first;
                    token.value = null;
                    galat.value = null;
                  },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: context.bodyMedium),
              Text(_rp(total), style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          if (kurang)
            _Banner(
              teks: 'Saldo tidak cukup (kurang ${_rp(total - k.saldo)}). Server akan menolak transaksi ini.',
              merah: true,
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: (sibuk.value || keranjang.value.kosong) ? null : bayar,
            icon: sibuk.value
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check_circle),
            label: Text(sibuk.value ? 'Memproses...' : 'Bayar ${_rp(total)}'),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.jumlah, required this.bisaTambah, required this.onTambah, required this.onKurang});
  final int jumlah;
  final bool bisaTambah;
  final VoidCallback onTambah;
  final VoidCallback? onKurang;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Kurangi',
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: jumlah > 0 ? onKurang : null,
        ),
        SizedBox(width: 24, child: Text('$jumlah', textAlign: TextAlign.center)),
        IconButton(
          tooltip: 'Tambah',
          icon: Icon(Icons.add_circle, color: bisaTambah ? context.colorPrimary : null),
          onPressed: bisaTambah ? onTambah : null,
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.teks, required this.merah});
  final String teks;
  final bool merah;

  @override
  Widget build(BuildContext context) {
    final warna = merah ? Colors.red : context.colorPrimary;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.1),
        border: Border.all(color: warna.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(teks, style: context.bodySmall?.copyWith(color: warna)),
    );
  }
}

class _NotaView extends StatelessWidget {
  const _NotaView({required this.nota, required this.onBaru});
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
          const _Banner(teks: 'Transaksi ini sudah tersimpan sebelumnya (saldo tidak dipotong dua kali).', merah: false),
        const SizedBox(height: 12),
        Text('No. nota: ${nota.noNota}'),
        Text('${nota.tanggal} ${nota.jam}'),
        Text('Santri: ${nota.namaSantri}'),
        Text('Metode: ${tabungan ? 'Tabungan' : 'Tunai'}'),
        const Divider(height: 24),
        for (final i in nota.items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(child: Text('${i.nama} x${i.jumlah}')),
                Text(_rp(i.subtotal)),
              ],
            ),
          ),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total'),
            Text(_rp(nota.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        if (tabungan) ...[
          const SizedBox(height: 4),
          Text('Saldo sebelum: ${_rp(nota.saldoSebelum)}'),
          Text('Saldo sesudah: ${_rp(nota.saldoSesudah)}'),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(onPressed: onBaru, icon: const Icon(Icons.add), label: const Text('Transaksi Baru')),
      ],
    );
  }
}
