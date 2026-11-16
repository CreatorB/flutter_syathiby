/// Aturan jenis kegiatan untuk alur pengajuan.
///
/// Dua alur, dua tim penerima (permintaan user 16 Nov 2026):
///
///   PERBAIKAN & JASA (Tim Maintenance)
///     pengajuan --(ACC atasan, manual)--> disetujui --(otomatis)--> disetujui mudir
///       --> dikerjakan Tim Maintenance --(klaim selesai)--> diklaim selesai
///       --(pemohon)--> diterima. Tanpa nominal barang: yang diperbaiki ditulis
///       bebas, tidak ada harga maupun jumlah.
///
///   PENGADAAN BARANG (Tim Admin Keuangan)
///     pengajuan --(ACC atasan, manual)--> disetujui --(otomatis)--> disetujui mudir
///       --> ACC & cairkan dana oleh Tim Admin Keuangan --> barang datang
///       --> disetujui pemohon. Ada nominal barang.
///
/// Kedua alur bisa ditolak selama pengerjaan belum dilakukan.
///
/// Daftar jenis di sini harus sama dengan `syathiby_alur_jenis_tim()` di
/// backend (`apps/aplikasi/geten/pengadaan/alur_pengajuan.php`).
library;

/// Jenis kegiatan yang memakai alur Tim Maintenance (perbaikan & jasa).
const alurTimJenis = <String>['Perbaikan', 'Jasa'];

/// Nama tim yang mengerjakan perbaikan/jasa.
const namaTimMaintenance = 'Tim Maintenance';

/// Nama tim yang menangani pengadaan barang.
const namaTimKeuangan = 'Tim Admin Keuangan';

/// Apakah jenis kegiatan ini memakai alur tim maintenance (perbaikan & jasa)?
bool isAlurTim(String? jenis) {
  final nilai = jenis?.trim().toLowerCase() ?? '';
  return alurTimJenis.any((e) => e.toLowerCase() == nilai);
}

/// Hanya "Perbaikan" (bukan "Jasa").
bool isJenisPerbaikan(String? jenis) {
  final nilai = jenis?.trim().toLowerCase() ?? '';
  return nilai == 'perbaikan';
}

/// Pengadaan barang: alur tim admin keuangan (bukan alur maintenance).
bool isAlurPengadaan(String? jenis) => !isAlurTim(jenis);

/// Nama tim yang ditugaskan untuk jenis pengajuan ini.
String namaTimUntukJenis(String? jenis) =>
    isAlurTim(jenis) ? namaTimMaintenance : namaTimKeuangan;

/// Pengajuan perbaikan tidak memakai nominal barang.
bool jenisTanpaNominal(String? jenis) => isAlurTim(jenis);

/// Label ramah status pengajuan. Cerminan `syathiby_alur_label_status()`
/// di backend `geten/pengadaan/alur_pengajuan.php`.
String labelStatus(String? status) {
  const peta = <String, String>{
    'pengajuan': 'Menunggu ACC Atasan',
    'disetujui': 'Sudah ACC Atasan',
    'disetujui mudir': 'Sudah ACC Mudir',
    'disetujui keuangan': 'Sudah ACC Keuangan',
    'dicairkan': 'Dana Cair, Menunggu Barang',
    'diorder': 'Barang Dipesan',
    'dikerjakan maintenance': 'Dikerjakan Tim Maintenance',
    'diklaim selesai': 'Diklaim Selesai Tim Maintenance',
    'diselesaikan': 'Selesai',
    'ditolak': 'Ditolak',
  };
  final s = status?.trim() ?? '';
  if (s.isEmpty) return 'Pengajuan';
  return peta[s] ?? s;
}

/// Satu langkah alur pengajuan.
class LangkahAlur {
  const LangkahAlur(this.status, this.label);

  final String status;
  final String label;
}

/// Urutan langkah alur sesuai jenis pengajuan.
List<LangkahAlur> langkahAlur(String? jenis) {
  if (isAlurTim(jenis)) {
    return const [
      LangkahAlur('pengajuan', 'Diajukan'),
      LangkahAlur('disetujui', 'ACC Atasan'),
      LangkahAlur('disetujui mudir', 'ACC Mudir (otomatis)'),
      LangkahAlur('dikerjakan maintenance', 'Dikerjakan Tim Maintenance'),
      LangkahAlur('diklaim selesai', 'Klaim Selesai'),
      LangkahAlur('diselesaikan', 'Disesahkan Pemohon'),
    ];
  }
  return const [
    LangkahAlur('pengajuan', 'Diajukan'),
    LangkahAlur('disetujui', 'ACC Atasan'),
    LangkahAlur('disetujui mudir', 'ACC Mudir (otomatis)'),
    LangkahAlur('dicairkan', 'ACC & Cairkan Dana (Tim Admin Keuangan)'),
    LangkahAlur('diselesaikan', 'Barang Datang & Disesahkan Pemohon'),
  ];
}

/// Status pengajuan sedang berjalan pada langkah ke berapa.
class ProgressAlur {
  const ProgressAlur({
    required this.index,
    required this.total,
    required this.label,
    required this.selesai,
    required this.ditolak,
  });

  /// Indeks langkah berjalan (0 = belum mulai). -1 bila status di luar alur.
  final int index;

  /// Jumlah langkah alur.
  final int total;

  /// Label langkah berjalan.
  final String label;

  /// Sudah selesai (status terakhir).
  final bool selesai;

  /// Ditolak.
  final bool ditolak;

  /// Rasio progres 0..1 untuk progress bar.
  double get nilai =>
      total <= 0 ? 0 : ((index + 1) / total).clamp(0.0, 1.0).toDouble();

  /// Teks ringkas untuk daftar, mis. "Langkah 3 dari 6".
  String get ringkas => 'Langkah ${index + 1} dari $total';
}

/// Hitung posisi status sekarang pada alur jenis pengajuan tersebut.
ProgressAlur progressAlur(String? jenis, String? status) {
  final langkah = langkahAlur(jenis);
  final s = status?.trim() ?? '';
  if (s == 'ditolak') {
    return ProgressAlur(
      index: 0,
      total: langkah.length,
      label: labelStatus(s),
      selesai: false,
      ditolak: true,
    );
  }
  final index = langkah.indexWhere((e) => e.status == s);
  if (index < 0) {
    return ProgressAlur(
      index: 0,
      total: langkah.length,
      label: labelStatus(s),
      selesai: false,
      ditolak: false,
    );
  }
  return ProgressAlur(
    index: index,
    total: langkah.length,
    label: langkah[index].label,
    selesai: s == 'diselesaikan',
    ditolak: false,
  );
}
