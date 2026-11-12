import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

/// Placeholder modul Kantin (12 Nov 2026).
///
/// Menu "Kantin" sudah tersedia di dashboard supaya alurnya jelas sebelum
/// fiturnya jadi. Sisi server (katalog produk, transaksi kasir, riwayat,
/// vendor & settlement) sudah ada di `geten/kantin/` dan panel web
/// `userpanel/kantin*`; sisi aplikasi masih menyusul.
class KantinScreen extends HookConsumerWidget {
  const KantinScreen({super.key});

  static const _fitur = <(String, String)>[
    (
      'Katalog Produk',
      'Harga, stok, dan kategori produk kantin. Sudah ada di panel web.',
    ),
    (
      'Transaksi Kasir',
      'Potong saldo kartu santri, kembalian, dan cetak struk.',
    ),
    (
      'Riwayat Belanja',
      'Rekap belanja per santri, per tanggal, dan per kasir.',
    ),
    (
      'Vendor & Settlement',
      'Paket barang masuk dari vendor, utang, dan pelunasan.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kantin'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.construction, color: context.colorPrimary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Modul kantin untuk aplikasi masih dikerjakan. '
                      'Data produk, transaksi, dan vendor sudah tersedia di '
                      'panel web, jadi pemodal bisa memakai panel dulu.',
                      style: context.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final fitur in _fitur)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.hourglass_empty, color: context.colorPrimary),
                title: Text(fitur.$1, style: context.bodyMediumBold),
                subtitle: Text(fitur.$2, style: context.bodySmall),
              ),
            ),
        ],
      ),
    );
  }
}
