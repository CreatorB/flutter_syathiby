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
  });

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
      );
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
  const KantinKatalog(this.produk);
  final List<KantinProduk> produk;

  factory KantinKatalog.fromJson(Map<String, dynamic> j) => KantinKatalog(
        (j['produk'] is List ? j['produk'] as List : const [])
            .whereType<Map>()
            .map((e) => KantinProduk.fromJson(Map<String, dynamic>.from(e)))
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
