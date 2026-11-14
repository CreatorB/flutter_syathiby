import 'package:flutter_test/flutter_test.dart';
import 'package:syathiby/models/kantin/kantin_models.dart';

void main() {
  test('KantinKatalog membaca angka berbentuk string dari server', () {
    final k = KantinKatalog.fromJson({
      'produk': [
        {
          'id_produk': '7',
          'kode': 'P-001',
          'nama': 'Air Mineral',
          'nama_kategori': 'Minuman',
          'harga': '3000',
          'stok': '4',
          'minimal_stok': '5',
          'satuan': '',
          'status': '1',
        },
      ],
    });
    final p = k.produk.single;
    expect(p.harga, 3000);
    expect(p.stok, 4);
    expect(p.satuan, 'pcs');
    expect(p.stokMenipis, isTrue);
    expect(p.aktif, isTrue);
  });

  test('KantinRiwayat membaca transaksi, item, dan total', () {
    final r = KantinRiwayat.fromJson({
      'jumlah': 1,
      'total': '8500',
      'transaksi': [
        {
          'id_transaksi': '3',
          'nama_santri': 'Ahmad',
          'nama_kasir': 'Barokah',
          'total': '8500',
          'jam': '09:10:00',
          'items': [
            {'nama': 'Roti', 'jumlah': '2', 'subtotal': '8500'},
          ],
        },
      ],
    });
    expect(r.total, 8500);
    expect(r.transaksi.single.namaKasir, 'Barokah');
    expect(r.transaksi.single.items.single.jumlah, 2);
  });

  test('payload kosong atau tak terduga tidak membuat crash', () {
    expect(KantinKatalog.fromJson({}).produk, isEmpty);
    expect(KantinRiwayat.fromJson({'transaksi': 'x'}).transaksi, isEmpty);
  });
}
