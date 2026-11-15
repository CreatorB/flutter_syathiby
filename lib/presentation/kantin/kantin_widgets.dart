import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

String rp(int v) => 'Rp ${NumberFormat.decimalPattern('id_ID').format(v)}';

/// Angka bulat dari teks isian (abaikan titik/spasi). Kosong -> 0.
int angkaDari(String s, {bool bolehNegatif = false}) {
  final neg = bolehNegatif && s.trim().startsWith('-');
  final n = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  return neg ? -n : n;
}

/// Saldo santri: negatif ditulis sebagai hutang ("Hutang Rp 8.000").
String labelSaldo(int saldo) => saldo < 0 ? 'Hutang ${rp(-saldo)}' : rp(saldo);

enum JenisBanner { merah, kuning, info }

class KantinBanner extends StatelessWidget {
  const KantinBanner({super.key, required this.teks, this.jenis = JenisBanner.info});
  final String teks;
  final JenisBanner jenis;

  @override
  Widget build(BuildContext context) {
    final warna = switch (jenis) {
      JenisBanner.merah => Colors.red,
      JenisBanner.kuning => Colors.orange.shade800,
      JenisBanner.info => context.colorPrimary,
    };
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

class KantinStepper extends StatelessWidget {
  const KantinStepper({
    super.key,
    required this.jumlah,
    required this.bisaTambah,
    required this.onTambah,
    required this.onKurang,
  });
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

class KantinPesan extends StatelessWidget {
  const KantinPesan({super.key, required this.ikon, required this.teks});
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

/// Baris "label ... nilai".
class BarisNilai extends StatelessWidget {
  const BarisNilai(this.label, this.nilai, {super.key, this.tebal = false, this.warna});
  final String label;
  final String nilai;
  final bool tebal;
  final Color? warna;

  @override
  Widget build(BuildContext context) {
    final gaya = TextStyle(fontWeight: tebal ? FontWeight.bold : null, color: warna);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: gaya)),
          Text(nilai, style: gaya),
        ],
      ),
    );
  }
}
