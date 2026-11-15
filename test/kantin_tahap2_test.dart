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

  test('pencairan: tersedia_cair & pending_cair dibaca; fallback server lama = sisa - pending', () {
    final p = KantinPenitip.daftarDari({
      'penitip': [
        {'id_penitip': 1, 'nama': 'A', 'sisa_bayar': 16000, 'pending_cair': 6000, 'tersedia_cair': 10000},
        {'id_penitip': 2, 'nama': 'B', 'sisa_bayar': 9000, 'pending_cair': 4000}, // tanpa tersedia_cair
        {'id_penitip': 3, 'nama': 'C', 'sisa_bayar': 5000},
      ],
    });
    expect(p[0].pendingCair, 6000);
    expect(p[0].tersediaCair, 10000);
    expect(p[1].tersediaCair, 5000);
    expect(p[2].pendingCair, 0);
    expect(p[2].tersediaCair, 5000);
  });

  test('daftar_cair: membaca status, pengaju, alasan tolak, no pengeluaran', () {
    final d = PenitipPencairan.daftarDari({
      'pencairan': [
        {
          'id_pencairan': '1', 'kode': 'PT-20261116-0001', 'id_penitip': 2, 'nama_penitip': 'Bu Ani', 'jumlah': '10000',
          'catatan': 'minggu 1', 'status': 'menunggu', 'nama_pengaju': 'Barokah', 'diajukan_pada': '2026-11-16 10:00:00',
          'diproses_oleh': '', 'nama_pemroses': '', 'diproses_pada': null, 'alasan_tolak': '', 'no_pengeluaran': '',
        },
        {
          'id_pencairan': 2, 'kode': 'PT-20261116-0002', 'jumlah': 5000, 'status': 'ditolak', 'alasan_tolak': 'Nominal salah',
        },
        {
          'id_pencairan': 3, 'kode': 'PT-20261116-0003', 'jumlah': 6000, 'status': 'disetujui', 'nama_pemroses': 'Erlandika',
          'no_pengeluaran': 'PT-20261116-0003',
        },
      ],
    });
    expect(d.length, 3);
    expect(d[0].menunggu, isTrue);
    expect(d[0].jumlah, 10000);
    expect(d[0].namaPengaju, 'Barokah');
    expect(d[0].diprosesPada, '');
    expect(d[1].menunggu, isFalse);
    expect(d[1].alasanTolak, 'Nominal salah');
    expect(d[2].noPengeluaran, 'PT-20261116-0003');
    expect(PenitipPencairan.daftarDari({'pencairan': 'x'}), isEmpty);
  });

  test('daftar_cair: boleh_proses di level respons atau per baris; bawaan false', () {
    final ya = DaftarPencairan.fromJson({
      'boleh_proses': true,
      'pencairan': [
        {'id_pencairan': 1, 'kode': 'PT-1', 'jumlah': 1000, 'status': 'menunggu'},
      ],
    });
    expect(ya.bolehProses, isTrue);
    expect(ya.daftar.single.menunggu, isTrue);
    expect(DaftarPencairan.fromJson({'boleh_proses': 1, 'pencairan': []}).bolehProses, isTrue);
    expect(DaftarPencairan.fromJson({'boleh_proses': false, 'pencairan': []}).bolehProses, isFalse);
    expect(DaftarPencairan.fromJson({'pencairan': []}).bolehProses, isFalse);
    final perBaris = DaftarPencairan.fromJson({
      'pencairan': [
        {'id_pencairan': 1, 'kode': 'PT-1', 'status': 'menunggu', 'boleh_proses': true},
      ],
    });
    expect(perBaris.bolehProses, isTrue);
    expect(DaftarPencairan.fromJson({}).daftar, isEmpty);
  });

  test('laporan memuat riwayat pencairan; validasi nominal ajuan', () {
    final l = PenitipLaporan.fromJson({
      'penitip': {'id_penitip': 1, 'nama': 'A', 'sisa_bayar': 16000},
      'pencairan': [
        {'id_pencairan': 1, 'kode': 'PT-1', 'jumlah': 6000, 'status': 'menunggu'},
      ],
    });
    expect(l.pencairan.single.kode, 'PT-1');
    expect(PenitipLaporan.fromJson({}).pencairan, isEmpty);
    expect(galatAjuanCair(0, 10000), isNotNull);
    expect(galatAjuanCair(10001, 10000), contains('melebihi'));
    expect(galatAjuanCair(10000, 10000), isNull);
    expect(galatAjuanCair(1, 0), isNotNull);
  });

  test('preview hutang: saldo sesudah negatif, batas, sisa, menjadi_hutang', () {
    final p = KantinPreview.fromJson({
      'siswa': {'nama': 'Ahmad', 'saldo': 2000},
      'total': 8000, 'metode': 'tabungan', 'saldo_sebelum': 2000, 'saldo_sesudah': -6000,
      'hutang_sebelum': 0, 'hutang_sesudah': 6000, 'batas_hutang': 20000, 'sisa_batas_hutang': 14000,
      'menjadi_hutang': true, 'bisa_bayar': true, 'alasan_tolak': '',
      'peringatan': ['Santri akan berhutang Rp 6.000'],
    });
    expect(p.saldoSesudah, -6000);
    expect(p.hutangSesudah, 6000);
    expect(p.batasHutang, 20000);
    expect(p.sisaBatasHutang, 14000);
    expect(p.menjadiHutang, isTrue);
    expect(p.bolehKonfirmasi, isTrue);
    expect(labelSaldo(-6000), 'Hutang Rp 6.000');
    expect(labelSaldo(6000), 'Rp 6.000');

    final lewat = KantinPreview.fromJson({
      'saldo_sebelum': -15000, 'saldo_sesudah': -25000, 'hutang_sesudah': 25000, 'batas_hutang': 20000,
      'sisa_batas_hutang': 0, 'menjadi_hutang': true,
      'bisa_bayar': false, 'alasan_tolak': 'Melebihi batas hutang Rp 20.000',
    });
    expect(lewat.bolehKonfirmasi, isFalse);
    expect(lewat.hutangSebelum, 15000);
  });

  test('preview hutang: server lama tanpa field baru diturunkan dari saldo', () {
    final lama = KantinPreview.fromJson({'saldo_sebelum': 1000, 'saldo_sesudah': -3000, 'metode': 'tabungan', 'bisa_bayar': true});
    expect(lama.hutangSebelum, 0);
    expect(lama.hutangSesudah, 3000);
    expect(lama.menjadiHutang, isTrue);
    expect(lama.batasHutang, 0);
    expect(lama.sisaBatasHutang, isNull);
    final tunai = KantinPreview.fromJson({'saldo_sebelum': 1000, 'saldo_sesudah': 1000, 'metode': 'tunai'});
    expect(tunai.menjadiHutang, isFalse);
  });

  test('nota & kartu: hutang dari saldo negatif', () {
    final n = KantinNota.fromJson({'metode': 'tabungan', 'total': 8000, 'saldo_sebelum': 2000, 'saldo_sesudah': -6000});
    expect(n.hutangSesudah, 6000);
    expect(KantinNota.fromJson({'metode': 'tabungan', 'saldo_sesudah': 500}).hutangSesudah, 0);
    expect(KantinNota.fromJson({'metode': 'tunai', 'saldo_sesudah': -500}).hutangSesudah, 0);
    expect(KantinKartu.fromJson({'saldo': -8000}).hutang, 8000);
    expect(KantinKartu.fromJson({'saldo': 8000}).hutang, 0);
  });

  test('hutang.php list: ringkasan, santri, wali; server lama tanpa total', () {
    final d = KantinHutangDaftar.fromJson({
      'hutang': [
        {
          'id_siswa': '1', 'nama_santri': 'Ahmad', 'nis': '2345', 'kelas': '7A', 'saldo': -8000, 'hutang': 8000,
          'terakhir_belanja': '2026-11-16', 'wali': [{'nama': 'Pak Budi', 'telepon': '0812'}],
        },
        {'id_siswa': 2, 'nama_santri': 'Zaid', 'saldo': '-2000'},
      ],
      'total_hutang': 10000, 'jumlah': 2, 'batas_hutang': 20000,
    });
    expect(d.jumlah, 2);
    expect(d.totalHutang, 10000);
    expect(d.batasHutang, 20000);
    expect(d.hutang.first.wali.single.telepon, '0812');
    expect(d.hutang.first.terakhirBelanja, '2026-11-16');
    expect(d.hutang.last.hutang, 2000); // diturunkan dari saldo
    expect(d.hutang.last.wali, isEmpty);

    final tanpa = KantinHutangDaftar.fromJson({
      'hutang': [
        {'id_siswa': 1, 'saldo': -3000},
        {'id_siswa': 2, 'saldo': -4000},
      ],
    });
    expect(tanpa.totalHutang, 7000);
    expect(tanpa.jumlah, 2);
    expect(KantinHutangDaftar.fromJson({}).hutang, isEmpty);
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
