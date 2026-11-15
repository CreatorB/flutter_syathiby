import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/kantin/kantin_models.dart';
import 'package:syathiby/models/kantin/kantin_repository.dart';
import 'package:syathiby/models/kantin/kantin_titipan_repository.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

import 'kantin_widgets.dart';

/// Kelola produk kantin (admin kantin/keuangan). Mendukung BARANG TITIPAN:
/// jenis=titipan, penitip, dan harga setor (hak penitip per unit terjual).
class ProdukTab extends HookConsumerWidget {
  const ProdukTab({super.key, required this.keySesi});
  final String keySesi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cari = useState('');
    final data = ref.watch(kantinKatalogProvider(keySesi));

    Future<void> buka(KantinProduk? p, KantinKatalog kat) async {
      final ok = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        builder: (_) => ProdukForm(keySesi: keySesi, produk: p, kategori: kat.kategori),
      );
      if (ok == true) {
        ref.invalidate(kantinKatalogProvider(keySesi));
        ref.invalidate(kantinPenitipProvider(keySesi));
      }
    }

    return Stack(
      children: [
        Column(
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
                  data: (kat) {
                    final daftar = kat.produk
                        .where((p) =>
                            cari.value.isEmpty ||
                            p.nama.toLowerCase().contains(cari.value) ||
                            p.kode.toLowerCase().contains(cari.value))
                        .toList();
                    if (daftar.isEmpty) {
                      return KantinPesan(
                        ikon: Icons.inventory_2_outlined,
                        teks: cari.value.isEmpty ? 'Belum ada produk. Tekan "Produk" untuk menambah.' : 'Produk tidak ditemukan.',
                      );
                    }
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: daftar.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final p = daftar[i];
                        return ListTile(
                          onTap: () => buka(p, kat),
                          title: Text(p.nama),
                          subtitle: Text([
                            if (p.kategori.isNotEmpty) p.kategori,
                            if (p.titipan) 'titipan ${p.namaPenitip}'.trim(),
                            if (!p.aktif) 'nonaktif',
                          ].join(' · ')),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(rp(p.harga), style: context.bodyMedium),
                              Text('Stok ${p.stok} ${p.satuan}',
                                  style: context.bodySmall?.copyWith(color: p.stokMenipis ? Colors.red : null)),
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
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'fab-produk',
            onPressed: data.valueOrNull == null ? null : () => buka(null, data.value!),
            icon: const Icon(Icons.add),
            label: const Text('Produk'),
          ),
        ),
      ],
    );
  }
}

class ProdukForm extends HookConsumerWidget {
  const ProdukForm({super.key, required this.keySesi, required this.produk, required this.kategori});
  final String keySesi;
  final KantinProduk? produk;
  final List<KantinKategori> kategori;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = produk;
    final nama = useTextEditingController(text: p?.nama ?? '');
    final kode = useTextEditingController(text: p?.kode ?? '');
    final harga = useTextEditingController(text: p == null ? '' : '${p.harga}');
    final stok = useTextEditingController(text: p == null ? '' : '${p.stok}');
    final minimal = useTextEditingController(text: p == null ? '' : '${p.minimalStok}');
    final satuan = useTextEditingController(text: p?.satuan ?? 'pcs');
    final setor = useTextEditingController(text: (p != null && p.hargaSetor > 0) ? '${p.hargaSetor}' : '');
    final idKategori = useState<int>(p?.idKategori ?? 0);
    final titipan = useState(p?.titipan ?? false);
    final idPenitip = useState<int>(p?.idPenitip ?? 0);
    final sibuk = useState(false);
    final galat = useState<String?>(null);
    final penitip = ref.watch(kantinPenitipProvider(keySesi));

    Future<void> simpan() async {
      if (nama.text.trim().isEmpty) {
        galat.value = 'Nama produk wajib diisi.';
        return;
      }
      final h = angkaDari(harga.text);
      if (titipan.value) {
        if (idPenitip.value == 0) {
          galat.value = 'Pilih penitip untuk barang titipan.';
          return;
        }
        final s = angkaDari(setor.text);
        if (s <= 0 || s > h) {
          galat.value = 'Harga setor harus lebih dari 0 dan tidak melebihi harga jual.';
          return;
        }
      }
      sibuk.value = true;
      galat.value = null;
      try {
        await kantinProdukSimpan(
          ref,
          keySesi,
          {
            'nama': nama.text.trim(),
            'kode': kode.text.trim(),
            'harga': h,
            'stok': angkaDari(stok.text),
            'minimal_stok': angkaDari(minimal.text),
            'satuan': satuan.text.trim().isEmpty ? 'pcs' : satuan.text.trim(),
            'id_kategori': idKategori.value,
            'jenis': titipan.value ? 'titipan' : 'milik',
            'id_penitip': titipan.value ? idPenitip.value : 0,
            'harga_setor': titipan.value ? angkaDari(setor.text) : 0,
          },
          id: p?.id,
        );
        if (context.mounted) Navigator.of(context).pop(true);
      } catch (e) {
        galat.value = kantinPesanError(e);
      } finally {
        sibuk.value = false;
      }
    }

    Future<void> hapus() async {
      if (p == null) return;
      final ya = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Hapus produk?'),
          content: Text('${p.nama} akan dihapus. Produk yang sudah pernah terjual hanya dinonaktifkan.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus')),
          ],
        ),
      );
      if (ya != true) return;
      sibuk.value = true;
      try {
        await kantinAksi(ref, 'kantin/produk.php', {'key': keySesi, 'act': 'hapus', 'id_produk': p.id});
        if (context.mounted) Navigator.of(context).pop(true);
      } catch (e) {
        galat.value = kantinPesanError(e);
      } finally {
        sibuk.value = false;
      }
    }

    InputDecoration dekor(String label, {String? hint}) =>
        InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder(), isDense: true);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(p == null ? 'Tambah Produk' : 'Ubah Produk', style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            TextField(controller: nama, decoration: dekor('Nama produk')),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: harga,
                    keyboardType: TextInputType.number,
                    decoration: dekor('Harga jual (Rp)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(controller: stok, keyboardType: TextInputType.number, decoration: dekor('Stok')),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(controller: minimal, keyboardType: TextInputType.number, decoration: dekor('Stok minimal')),
                ),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: satuan, decoration: dekor('Satuan'))),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: kategori.any((k) => k.id == idKategori.value) ? idKategori.value : 0,
              decoration: dekor('Kategori'),
              items: [
                const DropdownMenuItem(value: 0, child: Text('- Tanpa kategori -')),
                for (final k in kategori) DropdownMenuItem(value: k.id, child: Text(k.nama)),
              ],
              onChanged: (v) => idKategori.value = v ?? 0,
            ),
            const SizedBox(height: 8),
            TextField(controller: kode, decoration: dekor('Kode (kosongkan untuk otomatis)')),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Barang titipan'),
              subtitle: const Text('Dijual atas nama penitip; kantin wajib menyetor harga setor.'),
              value: titipan.value,
              onChanged: sibuk.value ? null : (v) => titipan.value = v,
            ),
            if (titipan.value) ...[
              penitip.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => KantinBanner(teks: kantinPesanError(e), jenis: JenisBanner.merah),
                data: (daftar) => DropdownButtonFormField<int>(
                  initialValue: daftar.any((d) => d.id == idPenitip.value) ? idPenitip.value : 0,
                  decoration: dekor('Penitip'),
                  items: [
                    const DropdownMenuItem(value: 0, child: Text('- Pilih penitip -')),
                    for (final d in daftar.where((d) => d.aktif || d.id == idPenitip.value))
                      DropdownMenuItem(value: d.id, child: Text(d.nama)),
                  ],
                  onChanged: (v) => idPenitip.value = v ?? 0,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: setor,
                keyboardType: TextInputType.number,
                decoration: dekor('Harga setor ke penitip per unit (Rp)', hint: 'tidak boleh melebihi harga jual'),
              ),
            ],
            if (galat.value != null) KantinBanner(teks: galat.value!, jenis: JenisBanner.merah),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: sibuk.value ? null : simpan,
              icon: sibuk.value
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(sibuk.value ? 'Menyimpan...' : 'Simpan'),
            ),
            if (p != null)
              TextButton.icon(
                onPressed: sibuk.value ? null : hapus,
                icon: Icon(Icons.delete_outline, color: context.colorError),
                label: Text('Hapus produk', style: TextStyle(color: context.colorError)),
              ),
          ],
        ),
      ),
    );
  }
}
