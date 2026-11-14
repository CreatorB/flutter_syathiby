import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/kantin/kantin_models.dart';
import 'package:syathiby/models/kantin/kantin_repository.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

/// Modul Kantin di aplikasi (read-only): katalog produk dan riwayat belanja.
/// Hak akses diputuskan server; transaksi kasir serta vendor & settlement
/// dikelola lewat panel web.
class KantinScreen extends HookConsumerWidget {
  const KantinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = '${ref.watch(getCurrentUserProvider)?.key}';
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kantin'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Katalog Produk'), Tab(text: 'Riwayat Belanja')],
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: context.colorPrimary.withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: context.colorPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Transaksi kasir serta vendor & settlement dikelola lewat panel web.',
                      style: context.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [_KatalogTab(keySesi: key), _RiwayatTab(keySesi: key)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pesan extends StatelessWidget {
  const _Pesan({required this.ikon, required this.teks});
  final IconData ikon;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 96),
        Icon(ikon, size: 56, color: Colors.grey),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(teks, textAlign: TextAlign.center, style: context.bodyMedium),
        ),
      ],
    );
  }
}

class _KatalogTab extends HookConsumerWidget {
  const _KatalogTab({required this.keySesi});
  final String keySesi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cari = useState('');
    final data = ref.watch(kantinKatalogProvider(keySesi));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Cari nama atau kode produk',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => cari.value = v.trim().toLowerCase(),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(kantinKatalogProvider(keySesi).future),
            child: data.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _Pesan(ikon: Icons.lock_outline, teks: kantinPesanError(e)),
              data: (k) {
                final daftar = k.produk
                    .where((p) =>
                        cari.value.isEmpty ||
                        p.nama.toLowerCase().contains(cari.value) ||
                        p.kode.toLowerCase().contains(cari.value))
                    .toList();
                if (daftar.isEmpty) {
                  return _Pesan(
                    ikon: Icons.inventory_2_outlined,
                    teks: cari.value.isEmpty ? 'Belum ada produk kantin.' : 'Produk tidak ditemukan.',
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: daftar.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = daftar[i];
                    final harga = ref.watch(formatCurrencyProvider('${p.harga}'));
                    return ListTile(
                      title: Text(p.nama),
                      subtitle: Text([
                        if (p.kategori.isNotEmpty) p.kategori,
                        if (p.kode.isNotEmpty) p.kode,
                        if (!p.aktif) 'nonaktif',
                      ].join(' · ')),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(harga, style: context.bodyMedium),
                          Text(
                            'Stok ${p.stok} ${p.satuan}',
                            style: context.bodySmall?.copyWith(
                              color: p.stokMenipis ? Colors.red : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _RiwayatTab extends HookConsumerWidget {
  const _RiwayatTab({required this.keySesi});
  final String keySesi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tanggal = useState(DateTime.now());
    final tgl = DateFormat('yyyy-MM-dd').format(tanggal.value);
    final data = ref.watch(kantinRiwayatProvider((key: keySesi, tanggal: tgl)));
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.event),
          title: Text('${ref.watch(formatDateProvider(tgl, format: 'EEEE, dd MMMM yyyy'))}'),
          trailing: TextButton(
            onPressed: () async {
              final pilih = await showDatePicker(
                context: context,
                initialDate: tanggal.value,
                firstDate: DateTime(2025),
                lastDate: DateTime.now(),
              );
              if (pilih != null) tanggal.value = pilih;
            },
            child: const Text('Ganti tanggal'),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(kantinRiwayatProvider((key: keySesi, tanggal: tgl)).future),
            child: data.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _Pesan(ikon: Icons.lock_outline, teks: kantinPesanError(e)),
              data: (r) {
                if (r.transaksi.isEmpty) {
                  return const _Pesan(ikon: Icons.receipt_long_outlined, teks: 'Belum ada transaksi pada tanggal ini.');
                }
                final total = ref.watch(formatCurrencyProvider('${r.total}'));
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: r.transaksi.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: Text('${r.jumlah} transaksi · total $total', style: context.bodyMedium),
                      );
                    }
                    final t = r.transaksi[i - 1];
                    final jumlah = ref.watch(formatCurrencyProvider('${t.total}'));
                    final ringkas = t.items.map((e) => '${e.nama} x${e.jumlah}').join(', ');
                    return ListTile(
                      title: Text(t.namaSantri.isEmpty ? '-' : t.namaSantri),
                      subtitle: Text([
                        if (t.jam.isNotEmpty) t.jam,
                        if (t.namaKasir.isNotEmpty) 'kasir ${t.namaKasir}',
                        if (ringkas.isNotEmpty) ringkas,
                      ].join(' · ')),
                      trailing: Text(jumlah, style: context.bodyMedium),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
