import 'package:flutter_test/flutter_test.dart';
import 'package:syathiby/models/kantin/kantin_models.dart';

void main() {
  kasirTests();
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

void kasirTests() {
  KantinProduk produk(int id, int harga, int stok) => KantinProduk.fromJson({
        'id_produk': '$id', 'kode': 'P$id', 'nama': 'Produk $id', 'harga': '$harga', 'stok': '$stok', 'status': '1',
      });

  test('cek_kartu: membaca identitas dan saldo (string dari MySQL)', () {
    final k = KantinKartu.fromJson({
      'id_siswa': 5, 'nis': '2345', 'nama_santri': 'Ahmad', 'id_card': '0012345678', 'id_kelas': 3,
      'tahun_ajaran': '2026-2027', 'saldo': '125000',
    });
    expect(k.nama, 'Ahmad');
    expect(k.saldo, 125000);
    expect(k.idCard, '0012345678');
  });

  test('simpan: membaca nota, item, saldo, dan penanda duplikat', () {
    final n = KantinNota.fromJson({
      'id_transaksi': 9, 'no_nota': 'KNT-20261116-0009', 'tanggal': '2026-11-16', 'jam': '09:12',
      'nama_santri': 'Ahmad', 'total': 8000, 'metode': 'tabungan', 'saldo_sebelum': 125000, 'saldo_sesudah': 117000,
      'duplikat': true,
      'items': [
        {'id_produk': 1, 'kode': 'P1', 'nama': 'Roti', 'harga': 4000, 'jumlah': 2, 'subtotal': 8000},
      ],
    });
    expect(n.noNota, 'KNT-20261116-0009');
    expect(n.saldoSesudah, 117000);
    expect(n.items.single.subtotal, 8000);
    expect(n.duplikat, isTrue);
    expect(KantinNota.fromJson({'no_nota': 'x'}).duplikat, isFalse);
  });

  test('keranjang: total, batas stok, kurang & hapus, format server', () {
    final roti = produk(1, 4000, 2);
    final air = produk(2, 3000, 5);
    var kr = const Keranjang();
    expect(kr.kosong, isTrue);
    kr = kr.tambah(roti).tambah(roti).tambah(roti); // stok hanya 2
    expect(kr.jumlahDari(1), 2);
    expect(kr.bisaTambah(roti), isFalse);
    kr = kr.tambah(air);
    expect(kr.total, 4000 * 2 + 3000);
    kr = kr.kurang(roti);
    expect(kr.jumlahDari(1), 1);
    kr = kr.kurang(roti); // habis -> baris hilang
    expect(kr.jumlahDari(1), 0);
    expect(kr.itemsServer, [
      {'id': 2, 'jumlah': 1},
    ]);
    expect(kr.hapus(2).kosong, isTrue);
  });

  test('token idempotensi: 32 karakter alfanumerik, tidak berulang', () {
    final a = buatTokenKantin();
    final b = buatTokenKantin();
    expect(a.length, 32);
    expect(RegExp(r'^[A-Za-z0-9]{32}$').hasMatch(a), isTrue);
    expect(a == b, isFalse);
  });
}
