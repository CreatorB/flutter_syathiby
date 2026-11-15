import 'package:flutter_test/flutter_test.dart';
import 'package:syathiby/models/kantin/kantin_models.dart';
import 'package:syathiby/models/kantin/kantin_titipan_models.dart';
import 'package:syathiby/presentation/kantin/kantin_widgets.dart';

void main() {
  test('preview: membaca siswa, item, saldo sebelum/sesudah, jatah harian, peringatan', () {
    final p = KantinPreview.fromJson({
      'siswa': {
        'id_siswa': '7', 'nama': 'Ahmad', 'nis': '2345', 'kelas': '7A', 'gender': 'Laki-laki',
        'kartu': '****1234', 'saldo': '125000', 'foto': 'https://x/y.jpg',
      },
      'items': [
        {'id': 5, 'nama': 'Roti', 'harga': 4000, 'jumlah': 2, 'subtotal': 8000},
      ],
      'total': 8000, 'metode': 'tabungan', 'saldo_sebelum': 125000, 'saldo_sesudah': 117000,
      'batas_harian': 50000, 'sisa_jatah_harian': '42000',
      'bisa_bayar': true, 'alasan_tolak': '', 'peringatan': ['Saldo tinggal Rp 2.000 setelah belanja'],
    });
    expect(p.siswa.nama, 'Ahmad');
    expect(p.siswa.kartu, '****1234');
    expect(p.siswa.kelas, '7A');
    expect(p.items.single.subtotal, 8000);
    expect(p.saldoSesudah, 117000);
    expect(p.batasHarian, 50000);
    expect(p.sisaJatahHarian, 42000);
    expect(p.peringatan.single, contains('Saldo tinggal'));
    expect(p.bolehKonfirmasi, isTrue);
  });

  test('preview: tanpa batas harian = null; alasan tolak mematikan konfirmasi', () {
    final p = KantinPreview.fromJson({
      'siswa': {'nama': 'Budi'},
      'total': 9000, 'saldo_sebelum': 1000, 'saldo_sesudah': -8000,
      'batas_harian': null, 'sisa_jatah_harian': null,
      'bisa_bayar': false, 'alasan_tolak': 'Saldo kartu tidak cukup',
    });
    expect(p.batasHarian, isNull);
    expect(p.sisaJatahHarian, isNull);
    expect(p.bisaBayar, isFalse);
    expect(p.bolehKonfirmasi, isFalse);
    // bisa_bayar true tetapi ada alasan tolak -> tetap tidak boleh
    final q = KantinPreview.fromJson({'bisa_bayar': 1, 'alasan_tolak': 'Kantin sedang tutup'});
    expect(q.bolehKonfirmasi, isFalse);
    expect(KantinPreview.fromJson({}).bolehKonfirmasi, isFalse);
  });

  test('preview tunai: metode terbaca, tetap butuh kartu (siswa terisi), bisa dikonfirmasi tanpa tolak saldo', () {
    final p = KantinPreview.fromJson({
      'siswa': {'id_siswa': 7, 'nama': 'Ahmad', 'kartu': '****1234', 'saldo': 1000},
      'items': [
        {'id': 5, 'nama': 'Roti', 'harga': 4000, 'jumlah': 2, 'subtotal': 8000},
      ],
      'total': 8000, 'metode': 'tunai', 'saldo_sebelum': 1000, 'saldo_sesudah': 1000,
      'bisa_bayar': true, 'alasan_tolak': '', 'peringatan': [],
    });
    expect(p.metode, 'tunai');
    expect(p.siswa.kartu, '****1234');
    expect(p.saldoSesudah, p.saldoSebelum); // saldo tidak berubah pada tunai
    expect(p.bolehKonfirmasi, isTrue);
  });

  test('produk titipan & kategori dibaca dari list produk', () {
    final k = KantinKatalog.fromJson({
      'kategori': [
        {'id_kategori': '2', 'nama_kategori': 'Makanan'},
      ],
      'produk': [
        {
          'id_produk': '9', 'nama': 'Keripik', 'harga': '5000', 'stok': '10', 'status': '1', 'id_kategori': '2',
          'jenis': 'titipan', 'id_penitip': '3', 'nama_penitip': 'Bu Ani', 'harga_setor': '4000',
        },
        {'id_produk': '10', 'nama': 'Roti', 'harga': '4000', 'stok': '3', 'status': '1'},
      ],
    });
    expect(k.kategori.single.nama, 'Makanan');
    final t = k.produk.first;
    expect(t.titipan, isTrue);
    expect(t.idPenitip, 3);
    expect(t.namaPenitip, 'Bu Ani');
    expect(t.hargaSetor, 4000);
    expect(t.idKategori, 2);
    final m = k.produk.last;
    expect(m.titipan, isFalse);
    expect(m.hargaSetor, 0);
  });

  test('penitip: daftar ringkasan dan laporan', () {
    final daftar = KantinPenitip.daftarDari({
      'penitip': [
        {
          'id_penitip': 1, 'nama': 'Bu Ani', 'kontak': '0812', 'catatan': '', 'aktif': 1, 'jumlah_produk': 3,
          'stok_total': 40, 'terjual_qty': 12, 'hak_penitip': '36000', 'dibayar': 20000, 'sisa_bayar': 16000,
        },
      ],
    });
    expect(daftar.single.sisaBayar, 16000);
    expect(daftar.single.aktif, isTrue);

    final l = PenitipLaporan.fromJson({
      'penitip': {'id_penitip': 1, 'nama': 'Bu Ani'},
      'produk': [
        {'id_produk': 5, 'nama': 'Keripik', 'terjual_qty': 4, 'subtotal': 20000, 'hak_penitip': 16000, 'stok': 10},
      ],
      'setoran': [
        {'id': 1, 'tanggal': '2026-11-16', 'jumlah': 20000, 'catatan': 'tunai', 'operator': 'Erlandika'},
      ],
      'ringkasan': {'hak_total': 36000, 'dibayar': 20000, 'sisa': 16000},
    });
    expect(l.penitip.nama, 'Bu Ani');
    expect(l.produk.single.hakPenitip, 16000);
    expect(l.setoran.single.operator, 'Erlandika');
    expect(l.sisa, 16000);
    expect(PenitipLaporan.fromJson({}).sisa, 0);
    expect(KantinPenitip.daftarDari({'penitip': 'x'}), isEmpty);
  });

  test('angkaDari: abaikan pemisah, dukung negatif untuk retur', () {
    expect(angkaDari('Rp 75.000'), 75000);
    expect(angkaDari(''), 0);
    expect(angkaDari('-2', bolehNegatif: true), -2);
    expect(angkaDari('-2'), 2);
    expect(rp(1250000), 'Rp 1.250.000');
  });

  test('keranjang banyak barang: total langsung berubah & format server', () {
    KantinProduk p(int id, int harga, int stok) =>
        KantinProduk.fromJson({'id_produk': '$id', 'nama': 'P$id', 'harga': '$harga', 'stok': '$stok', 'status': '1'});
    var kr = const Keranjang();
    kr = kr.tambah(p(1, 4000, 5)).tambah(p(1, 4000, 5)).tambah(p(2, 3000, 5)).tambah(p(3, 2500, 1));
    expect(kr.total, 8000 + 3000 + 2500);
    expect(kr.itemsServer.length, 3);
    expect(kr.itemsServer.first, {'id': 1, 'jumlah': 2});
  });
}
