import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/models/kantin/kantin_models.dart';
import 'package:syathiby/models/kantin/kantin_repository.dart';
import 'package:syathiby/models/kantin/kantin_titipan_models.dart';
import 'package:syathiby/models/kantin/kantin_titipan_repository.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

import 'kantin_widgets.dart';

/// Daftar penitip barang kantin + ringkasan hak penitip. Detail, terima barang
/// titipan, dan pembayaran ada di [PenitipDetailScreen]. Hak akses dari server
/// (membayar penitip hanya admin keuangan/admin utama).
class TitipanTab extends HookConsumerWidget {
  const TitipanTab({super.key, required this.keySesi});
  final String keySesi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(kantinPenitipProvider(keySesi));
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => ref.refresh(kantinPenitipProvider(keySesi).future),
          child: data.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => KantinPesan(ikon: Icons.lock_outline, teks: kantinPesanError(e)),
            data: (daftar) {
              if (daftar.isEmpty) {
                return const KantinPesan(
                  ikon: Icons.handshake_outlined,
                  teks: 'Belum ada penitip. Tekan "Penitip" untuk menambah, lalu tandai produk sebagai titipan di tab Produk.',
                );
              }
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: daftar.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final d = daftar[i];
                  return ListTile(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => PenitipDetailScreen(keySesi: keySesi, penitip: d)),
                    ),
                    title: Text(d.nama + (d.aktif ? '' : ' (nonaktif)')),
                    subtitle: Text([
                      '${d.jumlahProduk} produk · stok ${d.stokTotal} · terjual ${d.terjualQty}',
                      'tersedia dicairkan ${rp(d.tersediaCair)}',
                      if (d.pendingCair > 0) 'menunggu pencairan ${rp(d.pendingCair)}',
                    ].join('\n')),
                    isThreeLine: true,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Sisa bayar', style: context.bodySmall),
                        Text(rp(d.sisaBayar),
                            style: context.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: d.sisaBayar > 0 ? Colors.orange.shade800 : null,
                            )),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'fab-penitip',
            onPressed: () async {
              final ok = await tampilFormPenitip(context, ref, keySesi, null);
              if (ok == true) ref.invalidate(kantinPenitipProvider(keySesi));
            },
            icon: const Icon(Icons.add),
            label: const Text('Penitip'),
          ),
        ),
      ],
    );
  }
}

Future<bool?> tampilFormPenitip(BuildContext context, WidgetRef ref, String key, KantinPenitip? p) {
  final nama = TextEditingController(text: p?.nama ?? '');
  final kontak = TextEditingController(text: p?.kontak ?? '');
  final catatan = TextEditingController(text: p?.catatan ?? '');
  var aktif = p?.aktif ?? true;
  String? galat;
  var sibuk = false;
  return showDialog<bool>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, setS) => AlertDialog(
        title: Text(p == null ? 'Tambah Penitip' : 'Ubah Penitip'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama penitip')),
              TextField(controller: kontak, decoration: const InputDecoration(labelText: 'Kontak (opsional)')),
              TextField(controller: catatan, decoration: const InputDecoration(labelText: 'Catatan (opsional)')),
              if (p != null)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Aktif'),
                  value: aktif,
                  onChanged: (v) => setS(() => aktif = v),
                ),
              if (galat != null) KantinBanner(teks: galat!, jenis: JenisBanner.merah),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: sibuk ? null : () => Navigator.pop(c, false), child: const Text('Batal')),
          FilledButton(
            onPressed: sibuk
                ? null
                : () async {
                    if (nama.text.trim().isEmpty) {
                      setS(() => galat = 'Nama penitip wajib diisi.');
                      return;
                    }
                    setS(() {
                      sibuk = true;
                      galat = null;
                    });
                    try {
                      await kantinAksi(ref, 'kantin/penitip.php', {
                        'key': key,
                        'act': p == null ? 'tambah' : 'ubah',
                        if (p != null) 'id_penitip': p.id,
                        'nama': nama.text.trim(),
                        'kontak': kontak.text.trim(),
                        'catatan': catatan.text.trim(),
                        'aktif': aktif ? 1 : 0,
                      });
                      if (c.mounted) Navigator.pop(c, true);
                    } catch (e) {
                      setS(() {
                        sibuk = false;
                        galat = kantinPesanError(e);
                      });
                    }
                  },
            child: const Text('Simpan'),
          ),
        ],
      ),
    ),
  );
}

class PenitipDetailScreen extends HookConsumerWidget {
  const PenitipDetailScreen({super.key, required this.keySesi, required this.penitip});
  final String keySesi;
  final KantinPenitip penitip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat('yyyy-MM-dd');
    final dari = useState(DateTime.now().subtract(const Duration(days: 30)));
    final sampai = useState(DateTime.now());
    final param = (key: keySesi, id: penitip.id, dari: fmt.format(dari.value), sampai: fmt.format(sampai.value));
    final laporan = ref.watch(kantinPenitipLaporanProvider(param));
    final katalog = ref.watch(kantinKatalogProvider(keySesi));
    final pesan = useState<String?>(null);
    final ringkasan = ref
            .watch(kantinPenitipProvider(keySesi))
            .valueOrNull
            ?.where((e) => e.id == penitip.id)
            .firstOrNull ??
        penitip;

    void segarkan() {
      ref.invalidate(kantinPenitipLaporanProvider(param));
      ref.invalidate(kantinPenitipProvider(keySesi));
      ref.invalidate(kantinKatalogProvider(keySesi));
      ref.invalidate(kantinPencairanProvider);
    }

    Future<void> pilihRentang() async {
      final r = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2025),
        lastDate: DateTime.now(),
        initialDateRange: DateTimeRange(start: dari.value, end: sampai.value),
      );
      if (r != null) {
        dari.value = r.start;
        sampai.value = r.end;
      }
    }

    Future<void> terimaBarang() async {
      final produk = (katalog.valueOrNull?.produk ?? const <KantinProduk>[])
          .where((p) => p.titipan && p.idPenitip == penitip.id)
          .toList();
      if (produk.isEmpty) {
        pesan.value = 'Belum ada produk titipan untuk penitip ini. Tambahkan produk titipan di tab Produk.';
        return;
      }
      int? idProduk = produk.first.id;
      final jumlah = TextEditingController();
      final cat = TextEditingController();
      String? galat;
      var sibuk = false;
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => StatefulBuilder(
          builder: (c, setS) => AlertDialog(
            title: const Text('Terima Barang Titipan'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: idProduk,
                    decoration: const InputDecoration(labelText: 'Produk titipan'),
                    items: [for (final p in produk) DropdownMenuItem(value: p.id, child: Text('${p.nama} (stok ${p.stok})'))],
                    onChanged: (v) => idProduk = v,
                  ),
                  TextField(
                    controller: jumlah,
                    keyboardType: const TextInputType.numberWithOptions(signed: true),
                    decoration: const InputDecoration(
                      labelText: 'Jumlah',
                      helperText: 'Positif = terima titipan. Negatif (mis. -2) = retur/koreksi.',
                    ),
                  ),
                  TextField(controller: cat, decoration: const InputDecoration(labelText: 'Catatan (opsional)')),
                  if (galat != null) KantinBanner(teks: galat!, jenis: JenisBanner.merah),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: sibuk ? null : () => Navigator.pop(c, false), child: const Text('Batal')),
              FilledButton(
                onPressed: sibuk
                    ? null
                    : () async {
                        final n = angkaDari(jumlah.text, bolehNegatif: true);
                        if (idProduk == null || n == 0) {
                          setS(() => galat = 'Isi jumlah yang tidak nol.');
                          return;
                        }
                        setS(() {
                          sibuk = true;
                          galat = null;
                        });
                        try {
                          await kantinAksi(ref, 'kantin/penitip.php', {
                            'key': keySesi,
                            'act': 'stok',
                            'id_produk': idProduk,
                            'jumlah': n,
                            'catatan': cat.text.trim(),
                          });
                          if (c.mounted) Navigator.pop(c, true);
                        } catch (e) {
                          setS(() {
                            sibuk = false;
                            galat = kantinPesanError(e);
                          });
                        }
                      },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      );
      if (ok == true) {
        pesan.value = 'Stok titipan diperbarui.';
        segarkan();
      }
    }

    Future<void> bayar(PenitipLaporan l) async {
      final jumlah = TextEditingController(text: l.sisa > 0 ? '${l.sisa}' : '');
      final cat = TextEditingController();
      String? galat;
      var sibuk = false;
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => StatefulBuilder(
          builder: (c, setS) => AlertDialog(
            title: const Text('Catat Pembayaran ke Penitip'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Sisa yang harus dibayar: ${rp(l.sisa)}'),
                  TextField(
                    controller: jumlah,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Jumlah dibayar (Rp)'),
                  ),
                  TextField(controller: cat, decoration: const InputDecoration(labelText: 'Catatan (opsional)')),
                  if (galat != null) KantinBanner(teks: galat!, jenis: JenisBanner.merah),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: sibuk ? null : () => Navigator.pop(c, false), child: const Text('Batal')),
              FilledButton(
                onPressed: sibuk
                    ? null
                    : () async {
                        final n = angkaDari(jumlah.text);
                        if (n <= 0) {
                          setS(() => galat = 'Jumlah harus lebih dari 0.');
                          return;
                        }
                        setS(() {
                          sibuk = true;
                          galat = null;
                        });
                        try {
                          await kantinAksi(ref, 'kantin/penitip.php', {
                            'key': keySesi,
                            'act': 'bayar',
                            'id_penitip': penitip.id,
                            'jumlah': n,
                            'catatan': cat.text.trim(),
                          });
                          if (c.mounted) Navigator.pop(c, true);
                        } catch (e) {
                          // mis. errCode 03: hanya admin keuangan yang boleh membayar
                          setS(() {
                            sibuk = false;
                            galat = kantinPesanError(e);
                          });
                        }
                      },
                child: const Text('Catat'),
              ),
            ],
          ),
        ),
      );
      if (ok == true) {
        pesan.value = 'Pembayaran tercatat.';
        segarkan();
      }
    }

    Future<void> ajukanCair() async {
      final jumlah = TextEditingController(text: ringkasan.tersediaCair > 0 ? '${ringkasan.tersediaCair}' : '');
      final cat = TextEditingController();
      String? galat;
      var sibuk = false;
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => StatefulBuilder(
          builder: (c, setS) => AlertDialog(
            title: const Text('Ajukan Pencairan'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Tersedia dicairkan: ${rp(ringkasan.tersediaCair)}'),
                  const SizedBox(height: 4),
                  Text('Pengajuan akan diperiksa admin keuangan sebelum dicairkan.', style: context.bodySmall),
                  TextField(
                    controller: jumlah,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Nominal pencairan (Rp)'),
                  ),
                  TextField(controller: cat, decoration: const InputDecoration(labelText: 'Catatan (opsional)')),
                  if (galat != null) KantinBanner(teks: galat!, jenis: JenisBanner.merah),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: sibuk ? null : () => Navigator.pop(c, false), child: const Text('Batal')),
              FilledButton(
                onPressed: sibuk
                    ? null
                    : () async {
                        final n = angkaDari(jumlah.text);
                        final g = galatAjuanCair(n, ringkasan.tersediaCair);
                        if (g != null) {
                          setS(() => galat = g);
                          return;
                        }
                        final ya = await showDialog<bool>(
                          context: c,
                          builder: (d) => AlertDialog(
                            title: const Text('Konfirmasi pengajuan'),
                            content: Text('Ajukan pencairan ${rp(n)} untuk ${penitip.nama}?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Kembali')),
                              FilledButton(onPressed: () => Navigator.pop(d, true), child: const Text('Ajukan')),
                            ],
                          ),
                        );
                        if (ya != true) return;
                        setS(() {
                          sibuk = true;
                          galat = null;
                        });
                        try {
                          await kantinAksi(ref, 'kantin/penitip.php', {
                            'key': keySesi,
                            'act': 'ajukan_cair',
                            'id_penitip': penitip.id,
                            'jumlah': n,
                            'catatan': cat.text.trim(),
                          });
                          if (c.mounted) Navigator.pop(c, true);
                        } catch (e) {
                          setS(() {
                            sibuk = false;
                            galat = kantinPesanError(e);
                          });
                        }
                      },
                child: const Text('Ajukan'),
              ),
            ],
          ),
        ),
      );
      if (ok == true) {
        pesan.value = 'Pengajuan pencairan terkirim ke admin keuangan.';
        segarkan();
      }
    }

    Future<void> ubah() async {
      final ok = await tampilFormPenitip(context, ref, keySesi, penitip);
      if (ok == true) {
        ref.invalidate(kantinPenitipProvider(keySesi));
        if (context.mounted) Navigator.of(context).pop();
      }
    }

    Future<void> hapus() async {
      final ya = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Hapus penitip?'),
          content: const Text('Hanya bisa bila penitip belum punya produk.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hapus')),
          ],
        ),
      );
      if (ya != true) return;
      try {
        await kantinAksi(ref, 'kantin/penitip.php', {'key': keySesi, 'act': 'hapus', 'id_penitip': penitip.id});
        ref.invalidate(kantinPenitipProvider(keySesi));
        if (context.mounted) Navigator.of(context).pop();
      } catch (e) {
        pesan.value = kantinPesanError(e);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(penitip.nama),
        actions: [
          IconButton(tooltip: 'Ubah', icon: const Icon(Icons.edit_outlined), onPressed: ubah),
          IconButton(tooltip: 'Hapus', icon: const Icon(Icons.delete_outline), onPressed: hapus),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => segarkan(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (penitip.kontak.isNotEmpty) Text('Kontak: ${penitip.kontak}'),
            if (penitip.catatan.isNotEmpty) Text(penitip.catatan, style: context.bodySmall),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: pilihRentang,
              icon: const Icon(Icons.date_range),
              label: Text('${param.dari}  s/d  ${param.sampai}'),
            ),
            if (pesan.value != null) KantinBanner(teks: pesan.value!),
            const SizedBox(height: 8),
            laporan.when(
              loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
              error: (e, _) => KantinBanner(teks: kantinPesanError(e), jenis: JenisBanner.merah),
              data: (l) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: context.colorPrimary.withValues(alpha: 0.06),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          BarisNilai('Hak penitip (periode)', rp(l.hakTotal)),
                          BarisNilai('Sudah dibayar', rp(l.dibayar)),
                          const Divider(),
                          BarisNilai('Sisa harus dibayar', rp(l.sisa), tebal: true),
                          const Divider(),
                          BarisNilai('Menunggu pencairan', rp(ringkasan.pendingCair)),
                          BarisNilai('Tersedia dicairkan', rp(ringkasan.tersediaCair), tebal: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: terimaBarang,
                          icon: const Icon(Icons.move_to_inbox),
                          label: const Text('Terima Barang'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () => bayar(l),
                          icon: const Icon(Icons.payments),
                          label: const Text('Bayar Penitip'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: ajukanCair,
                      icon: const Icon(Icons.request_quote_outlined),
                      label: const Text('Ajukan Pencairan'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Produk titipan', style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  if (l.produk.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Belum ada produk.')),
                  for (final p in l.produk)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(p.nama),
                      subtitle: Text('terjual ${p.terjualQty} · omzet ${rp(p.subtotal)} · stok ${p.stok}'),
                      trailing: Text(rp(p.hakPenitip), style: context.bodyMedium),
                    ),
                  const SizedBox(height: 12),
                  Text('Riwayat pembayaran', style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  if (l.setoran.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Belum ada pembayaran.')),
                  for (final s in l.setoran)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(s.tanggal),
                      subtitle: Text([if (s.catatan.isNotEmpty) s.catatan, if (s.operator.isNotEmpty) 'oleh ${s.operator}'].join(' · ')),
                      trailing: Text(rp(s.jumlah), style: context.bodyMedium),
                    ),
                  const SizedBox(height: 12),
                  _SeksiPencairan(
                    keySesi: keySesi,
                    idPenitip: penitip.id,
                    onSelesai: (m) {
                      pesan.value = m;
                      segarkan();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Daftar pengajuan pencairan hasil titipan untuk satu penitip + aksi
/// Setujui/Tolak. Hak ditentukan server: bila tidak berhak (errCode 03)
/// pesan server ditampilkan di dialog.
class _SeksiPencairan extends HookConsumerWidget {
  const _SeksiPencairan({required this.keySesi, required this.idPenitip, required this.onSelesai});
  final String keySesi;
  final int idPenitip;
  final void Function(String pesan) onSelesai;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = useState('semua');
    final data = ref.watch(kantinPencairanProvider((key: keySesi, idPenitip: idPenitip, status: filter.value)));

    Future<void> proses(PenitipPencairan p, String aksi) async {
      final alasan = TextEditingController();
      String? galat;
      var sibuk = false;
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => StatefulBuilder(
          builder: (c, setS) => AlertDialog(
            title: Text(aksi == 'setuju' ? 'Setujui pencairan?' : 'Tolak pencairan'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${p.kode} · ${rp(p.jumlah)}'),
                  const SizedBox(height: 8),
                  if (aksi == 'setuju')
                    const Text('Hak penitip berkurang dan tercatat pengeluaran kas sebesar nominal ini.')
                  else
                    TextField(controller: alasan, decoration: const InputDecoration(labelText: 'Alasan penolakan (wajib)')),
                  if (galat != null) KantinBanner(teks: galat!, jenis: JenisBanner.merah),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: sibuk ? null : () => Navigator.pop(c, false), child: const Text('Batal')),
              FilledButton(
                onPressed: sibuk
                    ? null
                    : () async {
                        if (aksi == 'tolak' && alasan.text.trim().isEmpty) {
                          setS(() => galat = 'Alasan penolakan wajib diisi.');
                          return;
                        }
                        setS(() {
                          sibuk = true;
                          galat = null;
                        });
                        try {
                          await kantinAksi(ref, 'kantin/penitip.php', {
                            'key': keySesi,
                            'act': 'proses_cair',
                            'id_pencairan': p.id,
                            'aksi': aksi,
                            if (aksi == 'tolak') 'alasan': alasan.text.trim(),
                          });
                          if (c.mounted) Navigator.pop(c, true);
                        } catch (e) {
                          setS(() {
                            sibuk = false;
                            galat = kantinPesanError(e);
                          });
                        }
                      },
                child: Text(aksi == 'setuju' ? 'Setujui' : 'Tolak'),
              ),
            ],
          ),
        ),
      );
      if (ok == true) {
        onSelesai(aksi == 'setuju'
            ? 'Pencairan ${p.kode} disetujui dan tercatat sebagai pengeluaran.'
            : 'Pencairan ${p.kode} ditolak.');
      }
    }

    Color warna(String st) => switch (st) {
          'disetujui' => Colors.green.shade700,
          'ditolak' => Colors.red,
          _ => Colors.orange.shade800,
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pengajuan Pencairan', style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          children: [
            for (final f in const ['semua', 'menunggu', 'disetujui', 'ditolak'])
              ChoiceChip(
                label: Text(f[0].toUpperCase() + f.substring(1)),
                selected: filter.value == f,
                onSelected: (_) => filter.value = f,
              ),
          ],
        ),
        data.when(
          loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
          error: (e, _) => KantinBanner(teks: kantinPesanError(e), jenis: JenisBanner.merah),
          data: (hasil) {
            final daftar = hasil.daftar;
            if (daftar.isEmpty) {
              return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Belum ada pengajuan.'));
            }
            return Column(
              children: [
                for (final p in daftar)
                  Card(
                    margin: const EdgeInsets.only(top: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('${p.kode} · ${rp(p.jumlah)}',
                                    style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                              ),
                              Chip(
                                label: Text(p.status, style: TextStyle(color: warna(p.status), fontSize: 12)),
                                side: BorderSide(color: warna(p.status)),
                                backgroundColor: warna(p.status).withValues(alpha: 0.08),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          Text('Diajukan ${p.namaPengaju.isEmpty ? '-' : p.namaPengaju} · ${p.diajukanPada}',
                              style: context.bodySmall),
                          if (p.catatan.isNotEmpty) Text(p.catatan, style: context.bodySmall),
                          if (p.status == 'ditolak' && p.alasanTolak.isNotEmpty)
                            Text('Ditolak: ${p.alasanTolak}', style: context.bodySmall?.copyWith(color: Colors.red)),
                          if (p.status == 'disetujui')
                            Text(
                              'Disetujui ${p.namaPemroses}${p.noPengeluaran.isEmpty ? '' : ' · pengeluaran ${p.noPengeluaran}'}',
                              style: context.bodySmall,
                            ),
                          if (p.menunggu && hasil.bolehProses)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(onPressed: () => proses(p, 'tolak'), child: const Text('Tolak')),
                                FilledButton(onPressed: () => proses(p, 'setuju'), child: const Text('Setujui')),
                              ],
                            )
                          else if (p.menunggu)
                            Text('Menunggu admin keuangan', style: context.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
