import 'dart:math';

/// Model read-only modul Kantin. Server (`geten/kantin/*.php`) mengirim angka
/// sebagai string (hasil `mysqli_fetch_assoc`), jadi semua parsing toleran.
int _int(dynamic v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
String _str(dynamic v) => v == null ? '' : '$v';

class KantinProduk {
  const KantinProduk({
    required this.id,
    required this.kode,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.stok,
    required this.minimalStok,
    required this.satuan,
    required this.aktif,
    this.idKategori = 0,
    this.jenis = 'milik',
    this.idPenitip = 0,
    this.namaPenitip = '',
    this.hargaSetor = 0,
  });

  final int idKategori;
  final String jenis; // 'milik' | 'titipan'
  final int idPenitip;
  final String namaPenitip;
  final int hargaSetor;
  bool get titipan => jenis == 'titipan';

  final int id;
  final String kode;
  final String nama;
  final String kategori;
  final int harga;
  final int stok;
  final int minimalStok;
  final String satuan;
  final bool aktif;

  bool get stokMenipis => minimalStok > 0 && stok <= minimalStok;

  factory KantinProduk.fromJson(Map<String, dynamic> j) => KantinProduk(
        id: _int(j['id_produk']),
        kode: _str(j['kode']),
        nama: _str(j['nama']),
        kategori: _str(j['nama_kategori']),
        harga: _int(j['harga']),
        stok: _int(j['stok']),
        minimalStok: _int(j['minimal_stok']),
        satuan: _str(j['satuan']).isEmpty ? 'pcs' : _str(j['satuan']),
        aktif: j['status'] == null || _int(j['status']) == 1,
        idKategori: _int(j['id_kategori']),
        jenis: _str(j['jenis']) == 'titipan' ? 'titipan' : 'milik',
        idPenitip: _int(j['id_penitip']),
        namaPenitip: _str(j['nama_penitip']),
        hargaSetor: _int(j['harga_setor']),
      );
}

class KantinKategori {
  const KantinKategori(this.id, this.nama);
  final int id;
  final String nama;

  factory KantinKategori.fromJson(Map<String, dynamic> j) =>
      KantinKategori(_int(j['id_kategori']), _str(j['nama_kategori']));
}

class KantinItem {
  const KantinItem({required this.nama, required this.jumlah, required this.subtotal});

  final String nama;
  final int jumlah;
  final int subtotal;

  factory KantinItem.fromJson(Map<String, dynamic> j) => KantinItem(
        nama: _str(j['nama']),
        jumlah: _int(j['jumlah']),
        subtotal: _int(j['subtotal']),
      );
}

class KantinTransaksi {
  const KantinTransaksi({
    required this.id,
    required this.noNota,
    required this.tanggal,
    required this.jam,
    required this.namaSantri,
    required this.namaKasir,
    required this.total,
    required this.status,
    required this.items,
  });

  final int id;
  final String noNota;
  final String tanggal;
  final String jam;
  final String namaSantri;
  final String namaKasir;
  final int total;
  final String status;
  final List<KantinItem> items;

  factory KantinTransaksi.fromJson(Map<String, dynamic> j) => KantinTransaksi(
        id: _int(j['id_transaksi']),
        noNota: _str(j['no_nota']),
        tanggal: _str(j['tanggal']),
        jam: _str(j['jam']),
        namaSantri: _str(j['nama_santri']),
        namaKasir: _str(j['nama_kasir']),
        total: _int(j['total']),
        status: _str(j['status']),
        items: (j['items'] is List ? j['items'] as List : const [])
            .whereType<Map>()
            .map((e) => KantinItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class KantinKatalog {
  const KantinKatalog(this.produk, [this.kategori = const []]);
  final List<KantinProduk> produk;
  final List<KantinKategori> kategori;

  factory KantinKatalog.fromJson(Map<String, dynamic> j) => KantinKatalog(
        (j['produk'] is List ? j['produk'] as List : const [])
            .whereType<Map>()
            .map((e) => KantinProduk.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        (j['kategori'] is List ? j['kategori'] as List : const [])
            .whereType<Map>()
            .map((e) => KantinKategori.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class KantinRiwayat {
  const KantinRiwayat({required this.transaksi, required this.jumlah, required this.total});
  final List<KantinTransaksi> transaksi;
  final int jumlah;
  final int total;

  factory KantinRiwayat.fromJson(Map<String, dynamic> j) => KantinRiwayat(
        transaksi: (j['transaksi'] is List ? j['transaksi'] as List : const [])
            .whereType<Map>()
            .map((e) => KantinTransaksi.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        jumlah: _int(j['jumlah']),
        total: _int(j['total']),
      );
}

/// Hasil `transaksi.php?act=cek_kartu`.
class KantinKartu {
  const KantinKartu({
    required this.idSiswa,
    required this.nis,
    required this.nama,
    required this.idCard,
    required this.saldo,
  });

  final int idSiswa;
  final String nis;
  final String nama;
  final String idCard;
  final int saldo;

  factory KantinKartu.fromJson(Map<String, dynamic> j) => KantinKartu(
        idSiswa: _int(j['id_siswa']),
        nis: _str(j['nis']),
        nama: _str(j['nama_santri']),
        idCard: _str(j['id_card']),
        saldo: _int(j['saldo']),
      );
}

class KantinNotaItem {
  const KantinNotaItem({required this.nama, required this.harga, required this.jumlah, required this.subtotal});

  final String nama;
  final int harga;
  final int jumlah;
  final int subtotal;

  factory KantinNotaItem.fromJson(Map<String, dynamic> j) => KantinNotaItem(
        nama: _str(j['nama']),
        harga: _int(j['harga']),
        jumlah: _int(j['jumlah']),
        subtotal: _int(j['subtotal']),
      );
}

/// Hasil `transaksi.php?act=simpan`.
class KantinNota {
  const KantinNota({
    required this.noNota,
    required this.tanggal,
    required this.jam,
    required this.namaSantri,
    required this.total,
    required this.metode,
    required this.saldoSebelum,
    required this.saldoSesudah,
    required this.items,
    required this.duplikat,
  });

  final String noNota;
  final String tanggal;
  final String jam;
  final String namaSantri;
  final int total;
  final String metode;
  final int saldoSebelum;
  final int saldoSesudah;
  final List<KantinNotaItem> items;
  final bool duplikat;

  factory KantinNota.fromJson(Map<String, dynamic> j) => KantinNota(
        noNota: _str(j['no_nota']),
        tanggal: _str(j['tanggal']),
        jam: _str(j['jam']),
        namaSantri: _str(j['nama_santri']),
        total: _int(j['total']),
        metode: _str(j['metode']),
        saldoSebelum: _int(j['saldo_sebelum']),
        saldoSesudah: _int(j['saldo_sesudah']),
        items: (j['items'] is List ? j['items'] as List : const [])
            .whereType<Map>()
            .map((e) => KantinNotaItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        duplikat: j['duplikat'] == true,
      );
}

class BarisKeranjang {
  const BarisKeranjang(this.produk, this.jumlah);
  final KantinProduk produk;
  final int jumlah;

  int get subtotal => produk.harga * jumlah;
}

/// Keranjang kasir. Tidak boleh melebihi stok yang ditampilkan server;
/// keputusan akhir stok tetap di server saat `simpan`.
class Keranjang {
  const Keranjang([this.baris = const []]);
  final List<BarisKeranjang> baris;

  int get total => baris.fold(0, (s, b) => s + b.subtotal);
  bool get kosong => baris.isEmpty;

  int jumlahDari(int idProduk) {
    for (final b in baris) {
      if (b.produk.id == idProduk) return b.jumlah;
    }
    return 0;
  }

  bool bisaTambah(KantinProduk p) => jumlahDari(p.id) < p.stok;

  Keranjang tambah(KantinProduk p) {
    if (!bisaTambah(p)) return this;
    final ada = jumlahDari(p.id) > 0;
    return Keranjang(ada
        ? [for (final b in baris) b.produk.id == p.id ? BarisKeranjang(b.produk, b.jumlah + 1) : b]
        : [...baris, BarisKeranjang(p, 1)]);
  }

  Keranjang kurang(KantinProduk p) => Keranjang([
        for (final b in baris)
          if (b.produk.id != p.id)
            b
          else if (b.jumlah > 1)
            BarisKeranjang(b.produk, b.jumlah - 1),
      ]);

  Keranjang hapus(int idProduk) => Keranjang([for (final b in baris) if (b.produk.id != idProduk) b]);

  /// Format yang diminta server: `[{"id":<id_produk>,"jumlah":n}]`.
  List<Map<String, int>> get itemsServer =>
      [for (final b in baris) {'id': b.produk.id, 'jumlah': b.jumlah}];
}

/// Token idempotensi: 32 karakter [A-Za-z0-9]. Dibuat SEKALI per upaya
/// transaksi dan dipakai ulang saat percobaan ulang, supaya saldo tidak
/// terpotong dua kali (server menolak/menggandakan token yang sama).
String buatTokenKantin([Random? acak]) {
  const huruf = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final r = acak ?? Random.secure();
  return List.generate(32, (_) => huruf[r.nextInt(huruf.length)]).join();
}
