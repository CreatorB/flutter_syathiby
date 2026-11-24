import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/kantin/kantin_repository.dart';
import 'package:syathiby/models/kantin/kantin_topup_repository.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';

import 'kantin_widgets.dart';
import 'hutang_tab.dart';
import 'kasir_tab.dart';
import 'produk_tab.dart';
import 'titipan_tab.dart';

/// Modul Kantin di aplikasi: Kasir (pilih barang -> tap kartu -> konfirmasi),
/// Produk, Titipan, Katalog, Riwayat. Hak akses diputuskan server.
class KantinScreen extends HookConsumerWidget {
  const KantinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = '${ref.watch(getCurrentUserProvider)?.key}';
    // Hanya tim keuangan yang punya tombol verifikasi top-up.
    final bolehVerifikasi = ref.watch(kantinTopupBolehProvider).valueOrNull ?? false;
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kantin'),
          // Verifikasi top-up saldo hanya untuk tim keuangan; kasir kantin
          // menjaga aktivitas keseharian di lapangan, bukan ACC uang.
          actions: [
            if (bolehVerifikasi)
              IconButton(
                tooltip: 'Verifikasi top-up saldo',
                icon: const Icon(Icons.request_quote_outlined),
                onPressed: () => context.goNamed(AppRoute.topupVerifikasi.name),
              ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [Tab(text: 'Kasir'), Tab(text: 'Produk'), Tab(text: 'Titipan'), Tab(text: 'Hutang'), Tab(text: 'Katalog'), Tab(text: 'Riwayat')],
          ),
        ),
        // Isi tab menempel langsung di bawah deretan tab -- tidak ada pita
        // informasi atau jarak kosong di antaranya.
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            KasirTab(keySesi: key),
            ProdukTab(keySesi: key),
            TitipanTab(keySesi: key),
            HutangTab(keySesi: key),
            _KatalogTab(keySesi: key),
            _RiwayatTab(keySesi: key),
          ],
        ),
      ),
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
              error: (e, _) => KantinPesan(ikon: Icons.lock_outline, teks: kantinPesanError(e)),
              data: (k) {
                final daftar = k.produk
                    .where((p) =>
                        cari.value.isEmpty ||
                        p.nama.toLowerCase().contains(cari.value) ||
                        p.kode.toLowerCase().contains(cari.value))
                    .toList();
                if (daftar.isEmpty) {
                  return KantinPesan(
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
                    return ListTile(
                      title: Text(p.nama),
                      subtitle: Text([
                        if (p.kategori.isNotEmpty) p.kategori,
                        if (p.kode.isNotEmpty) p.kode,
                        if (p.titipan) 'titipan',
                        if (!p.aktif) 'nonaktif',
                      ].join(' · ')),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(rp(p.harga), style: context.bodyMedium),
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
              error: (e, _) => KantinPesan(ikon: Icons.lock_outline, teks: kantinPesanError(e)),
              data: (r) {
                if (r.transaksi.isEmpty) {
                  return const KantinPesan(ikon: Icons.receipt_long_outlined, teks: 'Belum ada transaksi pada tanggal ini.');
                }
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: r.transaksi.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: Text('${r.jumlah} transaksi · total ${rp(r.total)}', style: context.bodyMedium),
                      );
                    }
                    final t = r.transaksi[i - 1];
                    final ringkas = t.items.map((e) => '${e.nama} x${e.jumlah}').join(', ');
                    return ListTile(
                      title: Text(t.namaSantri.isEmpty ? '-' : t.namaSantri),
                      subtitle: Text([
                        if (t.jam.isNotEmpty) t.jam,
                        if (t.namaKasir.isNotEmpty) 'kasir ${t.namaKasir}',
                        if (ringkas.isNotEmpty) ringkas,
                      ].join(' · ')),
                      trailing: Text(rp(t.total), style: context.bodyMedium),
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
