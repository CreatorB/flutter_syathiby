import 'kantin_models.dart';

int _int(dynamic v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
int? _intN(dynamic v) => (v == null || '$v'.isEmpty) ? null : (v is num ? v.toInt() : int.tryParse('$v'));
String _str(dynamic v) => v == null ? '' : '$v';
bool _bool(dynamic v) => v == true || v == 1 || '$v' == '1' || '$v' == 'true';
Map<String, dynamic> _map(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
List<Map<String, dynamic>> _list(dynamic v) =>
    (v is List ? v : const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

/// Siswa pada hasil `transaksi.php?act=preview`.
class KantinPreviewSiswa {
  const KantinPreviewSiswa({
    required this.idSiswa,
    required this.nama,
    required this.nis,
    required this.kelas,
    required this.gender,
    required this.kartu,
    required this.saldo,
    required this.foto,
  });

  final int idSiswa;
  final String nama;
  final String nis;
  final String kelas;
  final String gender;
  final String kartu; // sudah tersamar server, mis. ****1234
  final int saldo;
  final String foto;

  factory KantinPreviewSiswa.fromJson(Map<String, dynamic> j) => KantinPreviewSiswa(
        idSiswa: _int(j['id_siswa']),
        nama: _str(j['nama']),
        nis: _str(j['nis']),
        kelas: _str(j['kelas']),
        gender: _str(j['gender']),
        kartu: _str(j['kartu']),
        saldo: _int(j['saldo']),
        foto: _str(j['foto']),
      );
}

/// Hasil `transaksi.php?act=preview` (tidak menulis apa pun di server).
class KantinPreview {
  const KantinPreview({
    required this.siswa,
    required this.items,
    required this.total,
    required this.metode,
    required this.saldoSebelum,
    required this.saldoSesudah,
    required this.batasHarian,
    required this.sisaJatahHarian,
    required this.bisaBayar,
    required this.alasanTolak,
    required this.peringatan,
  });

  final KantinPreviewSiswa siswa;
  final List<KantinNotaItem> items;
  final int total;
  final String metode;
  final int saldoSebelum;
  final int saldoSesudah;
  final int? batasHarian; // null = tanpa batas
  final int? sisaJatahHarian;
  final bool bisaBayar;
  final String alasanTolak;
  final List<String> peringatan;

  /// Tombol konfirmasi hanya aktif bila server mengizinkan DAN tidak ada alasan tolak.
  bool get bolehKonfirmasi => bisaBayar && alasanTolak.isEmpty;

  factory KantinPreview.fromJson(Map<String, dynamic> j) => KantinPreview(
        siswa: KantinPreviewSiswa.fromJson(_map(j['siswa'])),
        items: _list(j['items']).map(KantinNotaItem.fromJson).toList(),
        total: _int(j['total']),
        metode: _str(j['metode']),
        saldoSebelum: _int(j['saldo_sebelum']),
        saldoSesudah: _int(j['saldo_sesudah']),
        batasHarian: _intN(j['batas_harian']),
        sisaJatahHarian: _intN(j['sisa_jatah_harian']),
        bisaBayar: _bool(j['bisa_bayar']),
        alasanTolak: _str(j['alasan_tolak']),
        peringatan: (j['peringatan'] is List ? j['peringatan'] as List : const []).map((e) => '$e').toList(),
      );
}

/// Ringkasan penitip pada `penitip.php?act=list`.
class KantinPenitip {
  const KantinPenitip({
    required this.id,
    required this.nama,
    required this.kontak,
    required this.catatan,
    required this.aktif,
    required this.jumlahProduk,
    required this.stokTotal,
    required this.terjualQty,
    required this.hakPenitip,
    required this.dibayar,
    required this.sisaBayar,
  });

  final int id;
  final String nama;
  final String kontak;
  final String catatan;
  final bool aktif;
  final int jumlahProduk;
  final int stokTotal;
  final int terjualQty;
  final int hakPenitip;
  final int dibayar;
  final int sisaBayar;

  factory KantinPenitip.fromJson(Map<String, dynamic> j) => KantinPenitip(
        id: _int(j['id_penitip']),
        nama: _str(j['nama']),
        kontak: _str(j['kontak']),
        catatan: _str(j['catatan']),
        aktif: j['aktif'] == null || _int(j['aktif']) == 1,
        jumlahProduk: _int(j['jumlah_produk']),
        stokTotal: _int(j['stok_total']),
        terjualQty: _int(j['terjual_qty']),
        hakPenitip: _int(j['hak_penitip']),
        dibayar: _int(j['dibayar']),
        sisaBayar: _int(j['sisa_bayar']),
      );

  static List<KantinPenitip> daftarDari(Map<String, dynamic> j) =>
      _list(j['penitip']).map(KantinPenitip.fromJson).toList();
}

class PenitipProduk {
  const PenitipProduk({
    required this.id,
    required this.nama,
    required this.terjualQty,
    required this.subtotal,
    required this.hakPenitip,
    required this.stok,
  });

  final int id;
  final String nama;
  final int terjualQty;
  final int subtotal;
  final int hakPenitip;
  final int stok;

  factory PenitipProduk.fromJson(Map<String, dynamic> j) => PenitipProduk(
        id: _int(j['id_produk']),
        nama: _str(j['nama']),
        terjualQty: _int(j['terjual_qty']),
        subtotal: _int(j['subtotal']),
        hakPenitip: _int(j['hak_penitip']),
        stok: _int(j['stok']),
      );
}

class PenitipSetoran {
  const PenitipSetoran({
    required this.id,
    required this.tanggal,
    required this.jumlah,
    required this.catatan,
    required this.operator,
  });

  final int id;
  final String tanggal;
  final int jumlah;
  final String catatan;
  final String operator;

  factory PenitipSetoran.fromJson(Map<String, dynamic> j) => PenitipSetoran(
        id: _int(j['id']),
        tanggal: _str(j['tanggal']),
        jumlah: _int(j['jumlah']),
        catatan: _str(j['catatan']),
        operator: _str(j['operator']),
      );
}

/// Hasil `penitip.php?act=laporan`.
class PenitipLaporan {
  const PenitipLaporan({
    required this.penitip,
    required this.produk,
    required this.setoran,
    required this.hakTotal,
    required this.dibayar,
    required this.sisa,
  });

  final KantinPenitip penitip;
  final List<PenitipProduk> produk;
  final List<PenitipSetoran> setoran;
  final int hakTotal;
  final int dibayar;
  final int sisa;

  factory PenitipLaporan.fromJson(Map<String, dynamic> j) {
    final r = _map(j['ringkasan']);
    return PenitipLaporan(
      penitip: KantinPenitip.fromJson(_map(j['penitip'])),
      produk: _list(j['produk']).map(PenitipProduk.fromJson).toList(),
      setoran: _list(j['setoran']).map(PenitipSetoran.fromJson).toList(),
      hakTotal: _int(r['hak_total']),
      dibayar: _int(r['dibayar']),
      sisa: _int(r['sisa']),
    );
  }
}
