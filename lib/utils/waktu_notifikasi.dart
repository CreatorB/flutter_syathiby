/// Format waktu untuk daftar & detail notifikasi.
///
/// Server mengirim waktu dalam format MySQL ('Y-m-d H:i:s') dalam zona waktu
/// SERVER, yaitu UTC (`@@system_time_zone` = UTC di VPS Syathiby). Jadi
/// string itu dibaca sebagai UTC lalu dikonversi ke waktu lokal perangkat
/// sebelum ditampilkan -- kalau tidak, jamnya meleset 7 jam di WIB.
///
/// Format ditulis manual (bukan `package:intl`) supaya nama bulan dan hari
/// selalu berbahasa Indonesia tanpa perlu inisialisasi data locale.
class WaktuNotifikasi {
  const WaktuNotifikasi._();

  static const List<String> _bulan = <String>[
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _hari = <String>[
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  /// '5 menit lalu', '2 jam lalu', 'Kemarin, 14:30', '19 Nov 2026, 08:17'.
  static String relatif(String? mentah) {
    final dt = parse(mentah);
    if (dt == null) return (mentah ?? '').trim().isEmpty ? '-' : '$mentah';
    final now = DateTime.now();
    final selisih = now.difference(dt);
    if (!selisih.isNegative) {
      if (selisih.inMinutes < 1) return 'Baru saja';
      if (selisih.inMinutes < 60) return '${selisih.inMinutes} menit lalu';
      if (selisih.inHours < 24) return '${selisih.inHours} jam lalu';
    }
    return _format(dt);
  }

  /// '19 Nov 2026, 08:17' (lengkap, tanpa relatif).
  static String lengkap(String? mentah, {DateTime? now}) {
    final dt = parse(mentah);
    if (dt == null) return (mentah ?? '').trim().isEmpty ? '-' : '$mentah';
    return _format(dt.toLocal());
  }

  static String _format(DateTime dt) =>
      '${dt.day} ${_bulan[dt.month - 1]} ${dt.year}, ${_jamMenit(dt)}';

  /// Judul kelompok tanggal: 'Hari ini', 'Kemarin', atau tanggal lengkap.
  static String kelompokTanggal(String? mentah, {DateTime? now}) {
    final dt = parse(mentah);
    if (dt == null) return 'Lainnya';
    final lokal = dt.toLocal();
    final hariIni = now ?? DateTime.now();
    final hariIniTanggal = DateTime(hariIni.year, hariIni.month, hariIni.day);
    final tanggal = DateTime(lokal.year, lokal.month, lokal.day);
    final beda = hariIniTanggal.difference(tanggal).inDays;
    if (beda == 0) return 'Hari ini';
    if (beda == 1) return 'Kemarin';
    if (beda < 7) {
      return '${_hari[lokal.weekday - 1]}, ${_formatTanggal(lokal)}';
    }
    return _formatTanggal(lokal);
  }

  static String _formatTanggal(DateTime dt) =>
      '${dt.day} ${_bulan[dt.month - 1]} ${dt.year}';

  static String _jamMenit(DateTime dt) =>
      '${_duaDigit(dt.hour)}:${_duaDigit(dt.minute)}';

  static String _duaDigit(int n) => n.toString().padLeft(2, '0');

  /// Tanggal '2026-11-19 08:17:00' (UTC, zona waktu server) -> DateTime UTC.
  ///
  /// Suffix 'Z' dipakai karena waktu server disimpan dalam UTC. Tanpa itu
  /// string itu dibaca sebagai waktu lokal dan jamnya meleset 7 jam di WIB.
  static DateTime? parse(String? mentah) {
    final teks = (mentah ?? '').trim();
    if (teks.isEmpty) return null;
    return DateTime.tryParse('${teks.replaceFirst(' ', 'T')}Z');
  }
}
