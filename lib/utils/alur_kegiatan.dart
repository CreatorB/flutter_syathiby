/// Aturan jenis kegiatan untuk alur pengajuan.
///
/// Alur TIM (perbaikan & jasa):
///   ACC atasan manual -> Mudir otomatis -> Tim Perbaikan -> pemohon
///   mengesahkan. Tanpa keuangan & logistik.
///
/// Daftar jenis di sini harus sama dengan `syathiby_alur_jenis_tim()` di
/// backend (`apps/aplikasi/geten/pengadaan/alur_pengajuan.php`).
library;

/// Jenis kegiatan yang memakai alur Tim Perbaikan.
const alurTimJenis = <String>['Perbaikan', 'Jasa'];

/// Apakah jenis kegiatan ini memakai alur tim (perbaikan & jasa)?
bool isAlurTim(String? jenis) {
  final nilai = jenis?.trim().toLowerCase() ?? '';
  return alurTimJenis.any((e) => e.toLowerCase() == nilai);
}

/// Hanya "Perbaikan" (bukan "Jasa").
bool isJenisPerbaikan(String? jenis) {
  final nilai = jenis?.trim().toLowerCase() ?? '';
  return nilai == 'perbaikan';
}
