import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/kantin/kantin_repository.dart';
import 'package:syathiby/models/kantin/kantin_titipan_models.dart';
import 'package:syathiby/models/kantin/kantin_titipan_repository.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

import 'kantin_widgets.dart';

/// Daftar santri yang berhutang di kantin (saldo negatif) + kontak wali untuk
/// penagihan. Wali melunasi lewat top-up di Walsan; top-up otomatis melunasi
/// hutang lebih dulu. Hak akses diputuskan server.
class HutangTab extends HookConsumerWidget {
  const HutangTab({super.key, required this.keySesi});
  final String keySesi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cari = useState('');
    final data = ref.watch(kantinHutangProvider((key: keySesi, cari: cari.value)));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Cari nama atau NIS santri',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (v) => cari.value = v.trim(),
            onChanged: (v) {
              if (v.isEmpty && cari.value.isNotEmpty) cari.value = '';
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(kantinHutangProvider((key: keySesi, cari: cari.value)).future),
            child: data.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => KantinPesan(ikon: Icons.lock_outline, teks: kantinPesanError(e)),
              data: (d) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                children: [
                  Card(
                    color: context.colorPrimary.withValues(alpha: 0.06),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          BarisNilai('Total hutang', rp(d.totalHutang), tebal: true, warna: d.totalHutang > 0 ? Colors.red : null),
                          BarisNilai('Santri berhutang', '${d.jumlah}'),
                          BarisNilai('Batas hutang per santri', d.batasHutang > 0 ? rp(d.batasHutang) : 'Tidak boleh berhutang'),
                        ],
                      ),
                    ),
                  ),
                  if (d.hutang.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline, size: 56, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('Tidak ada hutang'),
                        ],
                      ),
                    ),
                  for (final h in d.hutang) _KartuHutang(h: h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _KartuHutang extends StatelessWidget {
  const _KartuHutang({required this.h});
  final KantinHutangSantri h;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(h.nama, style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Text(
                  'Hutang ${rp(h.hutang)}',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text([
              'NIS ${h.nis}',
              if (h.kelas.isNotEmpty) 'Kelas ${h.kelas}',
              if (h.terakhirBelanja.isNotEmpty) 'belanja terakhir ${h.terakhirBelanja}',
            ].join(' · '), style: context.bodySmall),
            if (h.wali.isNotEmpty) const Divider(height: 16),
            for (final w in h.wali)
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text('${w.nama.isEmpty ? 'Wali' : w.nama} · ${w.telepon}', style: context.bodySmall)),
                  if (w.telepon.isNotEmpty)
                    IconButton(
                      tooltip: 'Salin nomor',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: w.telepon));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(SnackBar(content: Text('Nomor ${w.telepon} disalin')));
                        }
                      },
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
