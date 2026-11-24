import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/kantin/kantin_repository.dart';
import 'package:syathiby/models/kantin/kantin_topup_models.dart';
import 'package:syathiby/models/kantin/kantin_topup_repository.dart';
import 'package:syathiby/presentation/kantin/kantin_widgets.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

/// Verifikasi top-up saldo oleh tim keuangan.
///
/// ACC top-up saldo adalah urusan tim keuangan -- kasir kantin menjaga
/// aktivitas keseharian di lapangan (tap kartu, input barang) dan tidak
/// boleh menyetujui pengeluaran uang. Server juga menolak kasir.
class TopupVerifikasiScreen extends ConsumerStatefulWidget {
  const TopupVerifikasiScreen({super.key});

  @override
  ConsumerState<TopupVerifikasiScreen> createState() =>
      _TopupVerifikasiScreenState();
}

class _TopupVerifikasiScreenState extends ConsumerState<TopupVerifikasiScreen> {
  String _status = 'menunggu';
  bool _sibuk = false;

  static const _statusList = <String, String>{
    'menunggu': 'Menunggu',
    'disetujui': 'Disetujui',
    'ditolak': 'Ditolak',
  };

  Future<void> _setujui(String key, TopupSaldo t) async {
    await _jalan(() => kantinTopupSetuju(ref, key: key, id: t.id));
  }

  Future<void> _tolak(String key, TopupSaldo t) async {
    final alasan = await showDialog<String>(
      context: context,
      builder: (ctx) => _DialogAlasanTolak(kode: t.kode),
    );
    if (alasan == null || alasan.trim().isEmpty) return;
    await _jalan(() => kantinTopupTolak(ref, key: key, id: t.id, alasan: alasan.trim()));
  }

  /// Jalankan aksi server lalu segarkan daftar.
  Future<void> _jalan(Future<void> Function() aksi) async {
    if (_sibuk) return;
    setState(() => _sibuk = true);
    try {
      await aksi();
      ref.invalidate(kantinTopupProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selesai diproses')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(kantinPesanError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final daftar = ref.watch(kantinTopupProvider((key: key, status: _status)));

    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Top-up Saldo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                for (final s in _statusList.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(_statusList[s.key]!),
                      selected: _status == s.key,
                      onSelected: (_) => setState(() => _status = s.key),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(kantinTopupProvider);
                await ref.read(kantinTopupProvider((key: key, status: _status)).future);
              },
              child: daftar.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ListView(
                  children: [
                    const SizedBox(height: 120),
                    KantinPesan(
                      ikon: Icons.lock_outline,
                      teks: kantinPesanError(e),
                    ),
                  ],
                ),
                data: (d) {
                  if (d.items.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 120),
                        KantinPesan(
                          ikon: Icons.receipt_long_outlined,
                          teks: _status == 'menunggu'
                              ? 'Tidak ada pengajuan top-up yang menunggu.'
                              : 'Tidak ada pengajuan pada status ini.',
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    itemCount: d.items.length,
                    itemBuilder: (context, i) {
                      final t = d.items[i];
                      return _KartuTopup(
                        topup: t,
                        keySesi: key,
                        sibuk: _sibuk,
                        onSetuju: () => _setujui(key, t),
                        onTolak: () => _tolak(key, t),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu kartu pengajuan top-up.
class _KartuTopup extends StatefulWidget {
  const _KartuTopup({
    required this.topup,
    required this.keySesi,
    required this.sibuk,
    required this.onSetuju,
    required this.onTolak,
  });

  final TopupSaldo topup;
  final String keySesi;
  final bool sibuk;
  final VoidCallback onSetuju;
  final VoidCallback onTolak;

  @override
  State<_KartuTopup> createState() => _KartuTopupState();
}

class _KartuTopupState extends State<_KartuTopup> {
  bool _bukaBukti = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.topup;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(t.kode, style: context.bodyMediumBold),
                ),
                Text(
                  rp(t.nominal),
                  style: context.titleMediumBold?.copyWith(
                    color: context.colorPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${t.namaSantri}  (NIS ${t.nis})', style: context.bodyMedium),
            Text('Wali: ${t.namaWali} (${t.noWali})', style: context.bodySmall),
            const SizedBox(height: 6),
            _Baris(label: 'Pengirim', nilai: t.namaPengirim),
            _Baris(
              label: 'Rekening tujuan',
              nilai: t.bankRekening.isEmpty
                  ? '-'
                  : '${t.bankRekening} ${t.noRekening}',
            ),
            if (t.tanggalTransfer.isNotEmpty)
              _Baris(label: 'Tanggal TF', nilai: t.tanggalTransfer),
            if (t.catatan.isNotEmpty) _Baris(label: 'Catatan', nilai: t.catatan),
            _Baris(label: 'Diajukan', nilai: t.diajukanPada),
            if (t.diprosesOleh.isNotEmpty) ...[
              _Baris(label: 'Diproses', nilai: '${t.diprosesOleh} ${t.diprosesPada}'),
              if (t.alasanTolak.isNotEmpty)
                _Baris(label: 'Alasan', nilai: t.alasanTolak),
            ],
            const SizedBox(height: 8),
            if (t.adaBukti)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _bukaBukti = !_bukaBukti),
                  icon: Icon(
                    _bukaBukti ? Icons.expand_less : Icons.receipt_long_outlined,
                    size: 18,
                  ),
                  label: Text(_bukaBukti ? 'Sembunyikan bukti' : 'Lihat bukti transfer'),
                ),
              )
            else
              Text('Bukti transfer tidak diunggah.', style: context.bodySmall),
            if (_bukaBukti && t.adaBukti) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  kantinTopupBuktiUrl(widget.keySesi, t.id),
                  fit: BoxFit.contain,
                  loadingBuilder: (ctx, child, progres) => progres == null
                      ? child
                      : const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                  errorBuilder: (ctx, e, _) => Text(
                    'Bukti tidak bisa dimuat.',
                    style: context.bodySmall?.copyWith(color: context.colorError),
                  ),
                ),
              ),
            ],
            if (t.menunggu) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: widget.sibuk ? null : widget.onSetuju,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Setujui'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.sibuk ? null : widget.onTolak,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Tolak'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Baris extends StatelessWidget {
  const _Baris({required this.label, required this.nilai});

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: context.bodySmall?.copyWith(color: context.colorOutline),
            ),
          ),
          Expanded(child: Text(nilai, style: context.bodySmall)),
        ],
      ),
    );
  }
}

/// Dialog minta alasan penolakan (wajib diisi server).
class _DialogAlasanTolak extends StatefulWidget {
  const _DialogAlasanTolak({required this.kode});

  final String kode;

  @override
  State<_DialogAlasanTolak> createState() => _DialogAlasanTolakState();
}

class _DialogAlasanTolakState extends State<_DialogAlasanTolak> {
  final _teks = TextEditingController();

  @override
  void dispose() {
    _teks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tolak ${widget.kode}'),
      content: TextField(
        controller: _teks,
        maxLines: 3,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Alasan penolakan',
          hintText: 'Contoh: nominal tidak sesuai bukti transfer',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_teks.text),
          child: const Text('Tolak'),
        ),
      ],
    );
  }
}
