/// Model pengajuan top-up saldo (dari wali) untuk tim keuangan.
///
/// Server (`geten/kantin/topup.php`) mengirim angka sebagai string (hasil
/// `mysqli_fetch_assoc`), jadi semua parsing toleran seperti model kantin
/// lainnya.
library;

int _int(dynamic v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
String _str(dynamic v) => v == null ? '' : '$v';

/// Satu pengajuan top-up saldo.
class TopupSaldo {
  const TopupSaldo({
    required this.id,
    required this.kode,
    required this.idSiswa,
    required this.namaSantri,
    required this.nis,
    required this.namaWali,
    required this.noWali,
    required this.nominal,
    required this.namaPengirim,
    required this.bankRekening,
    required this.noRekening,
    required this.tanggalTransfer,
    required this.catatan,
    required this.adaBukti,
    required this.status,
    required this.diajukanPada,
    required this.diprosesOleh,
    required this.diprosesPada,
    required this.alasanTolak,
  });

  final int id;
  final String kode;
  final int idSiswa;
  final String namaSantri;
  final String nis;
  final String namaWali;
  final String noWali;
  final int nominal;
  final String namaPengirim;
  final String bankRekening;
  final String noRekening;
  final String tanggalTransfer;
  final String catatan;
  final bool adaBukti;
  final String status;
  final String diajukanPada;
  final String diprosesOleh;
  final String diprosesPada;
  final String alasanTolak;

  bool get menunggu => status == 'menunggu';

  factory TopupSaldo.fromJson(Map<String, dynamic> j) => TopupSaldo(
        id: _int(j['id']),
        kode: _str(j['kode']),
        idSiswa: _int(j['id_siswa']),
        namaSantri: _str(j['nama_santri']),
        nis: _str(j['nis']),
        namaWali: _str(j['nama_wali']),
        noWali: _str(j['no_wali']),
        nominal: _int(j['nominal']),
        namaPengirim: _str(j['nama_pengirim']),
        bankRekening: _str(j['bank_rekening']),
        noRekening: _str(j['no_rekening']),
        tanggalTransfer: _str(j['tanggal_transfer']),
        catatan: _str(j['catatan']),
        adaBukti: _int(j['ada_bukti']) == 1,
        status: _str(j['status']),
        diajukanPada: _str(j['diajukan_pada']),
        diprosesOleh: _str(j['diproses_oleh']),
        diprosesPada: _str(j['diproses_pada']),
        alasanTolak: _str(j['alasan_tolak']),
      );
}

/// Daftar pengajuan + jumlahnya per status.
class TopupDaftar {
  const TopupDaftar({
    this.items = const <TopupSaldo>[],
    this.menunggu = 0,
    this.disetujui = 0,
    this.ditolak = 0,
  });

  final List<TopupSaldo> items;
  final int menunggu;
  final int disetujui;
  final int ditolak;

  factory TopupDaftar.fromJson(Map<String, dynamic> j) {
    final mentah = j['topup'];
    final list = <TopupSaldo>[];
    if (mentah is List) {
      for (final e in mentah) {
        if (e is Map) list.add(TopupSaldo.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    final n = j['jumlah'];
    final nf = n is Map ? n : const <String, dynamic>{};
    return TopupDaftar(
      items: list,
      menunggu: _int(nf['menunggu']),
      disetujui: _int(nf['disetujui']),
      ditolak: _int(nf['ditolak']),
    );
  }
}
