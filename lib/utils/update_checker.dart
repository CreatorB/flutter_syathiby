import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syathiby/res/flavor_config.dart';

/// Info tentang versi terbaru yang tersedia di GitHub.
class UpdateInfo {
  final String latestVersion;
  final String releaseDate;

  /// Konten markdown dari section versi terbaru (antara header versi ini dan versi berikutnya).
  final String changelogContent;

  const UpdateInfo({
    required this.latestVersion,
    required this.releaseDate,
    required this.changelogContent,
  });
}

class UpdateChecker {
  /// Branch CHANGELOG.md yang dibaca, mengikuti flavor:
  /// - flavor prod  -> branch 'main'    (branch production)
  /// - flavor local -> branch 'staging' (branch pra-produksi)
  ///
  /// PENTING: flavor prod HARUS baca 'main', bukan 'dev'. Sebelumnya membaca
  /// 'dev', sehingga pop-up "versi baru tersedia" muncul di HP karyawan begitu
  /// kode di-push ke dev — padahal aplikasi produksi belum di-update sama sekali.
  /// Dengan 'main', pop-up baru muncul setelah rilis benar-benar naik ke prod.
  ///
  /// Konsekuensinya: CHANGELOG.md di branch 'main' hanya boleh ditambah entri
  /// versi baru pada saat deploy prod (lihat AGENTS.md bagian alur rilis).
  /// Flavor `staging` ikut membaca branch 'staging' (ditambahkan 5 Sep 2026
  /// bersama flavor itu sendiri) -- kalau tidak, build staging akan mengecek
  /// CHANGELOG milik produksi dan memunculkan pop-up update yang menyesatkan
  /// saat sedang menguji.
  static String get _branch =>
      (FlavorConfig.isLocal || FlavorConfig.isStaging) ? 'staging' : 'main';

  /// URL raw CHANGELOG.md dari GitHub dengan branch dinamis
  static String get changelogUrl =>
      'https://raw.githubusercontent.com/CreatorB/flutter_syathiby/$_branch/CHANGELOG.md';

  /// Play Store URL untuk membuka halaman update
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=id.syathiby.app';

  /// Cek apakah ada versi baru di GitHub.
  ///
  /// [currentVersion] adalah versi saat ini dari PackageInfo (misal: "1.0.4").
  /// Returns [UpdateInfo] jika ada versi lebih baru, atau null jika sudah terbaru /
  /// gagal fetch (silent fail — jangan ganggu user jika network error).
  static Future<UpdateInfo?> check(String currentVersion) async {
    try {
      final dio = Dio();
      final response = await dio
          .get(
            changelogUrl,
            options: Options(responseType: ResponseType.plain),
          )
          .timeout(const Duration(seconds: 10));

      final content = response.data?.toString() ?? '';
      if (content.isEmpty) return null;

      return _parse(content, currentVersion);
    } catch (_) {
      // Silent fail — network error, repo private, dll.
      return null;
    }
  }

  /// Parse CHANGELOG.md dan kembalikan UpdateInfo jika ada versi lebih baru.
  static UpdateInfo? _parse(String content, String currentVersion) {
    // Match ## [x.x.x] - optional date — skip [Unreleased]
    final versionRegex = RegExp(
      r'^## \[(\d+\.\d+\.\d+)\](?:\s*-\s*(\S+))?',
      multiLine: true,
    );

    final matches = versionRegex.allMatches(content).toList();
    if (matches.isEmpty) return null;

    final latestMatch = matches.first;
    final latestVersion = latestMatch.group(1)!;
    final releaseDate = latestMatch.group(2) ?? '';

    // Jika versi sama, tidak perlu update
    if (latestVersion == currentVersion) return null;

    // Jika versi remote tidak lebih baru, tidak tampilkan
    if (!_isNewer(latestVersion, currentVersion)) return null;

    // Ambil konten antara header versi ini dan header versi berikutnya
    final start = latestMatch.end;
    final end = matches.length > 1 ? matches[1].start : content.length;
    final changelogContent = content.substring(start, end).trim();

    return UpdateInfo(
      latestVersion: latestVersion,
      releaseDate: releaseDate,
      changelogContent: changelogContent,
    );
  }

  /// Bandingkan dua versi semver. Returns true jika [remote] > [current].
  static bool _isNewer(String remote, String current) {
    final r = _parseVersion(remote);
    final c = _parseVersion(current);
    for (var i = 0; i < 3; i++) {
      if (r[i] > c[i]) return true;
      if (r[i] < c[i]) return false;
    }
    return false;
  }

  static List<int> _parseVersion(String v) {
    final parts = v.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return parts;
  }

  // ============================================================================
  // WEB-SPECIFIC CHANGELOG NOTIFICATION
  // ============================================================================

  static const String _lastSeenVersionKey = 'last_seen_version';

  /// Cek apakah perlu menampilkan changelog untuk web users.
  ///
  /// Platform web tidak dapat notifikasi update dari Play Store karena:
  /// - Web files langsung di-replace saat deployment (instant update)
  /// - Tidak ada update dialog dari app store
  ///
  /// Solusi: Track last seen version di localStorage. Jika current version berbeda
  /// dari yang terakhir dilihat, tampilkan changelog modal.
  ///
  /// [currentVersion] adalah versi saat ini dari PackageInfo.
  /// Returns [UpdateInfo] dengan changelog versi current, atau null jika sudah pernah dilihat.
  static Future<UpdateInfo?> checkForWeb(String currentVersion) async {
    if (!kIsWeb) return null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSeenVersion = prefs.getString(_lastSeenVersionKey);

      // Jika ini first visit atau versi berbeda, tampilkan changelog
      if (lastSeenVersion == null || lastSeenVersion != currentVersion) {
        // Fetch changelog dari GitHub
        final dio = Dio();
        final response = await dio
            .get(
              changelogUrl,
              options: Options(responseType: ResponseType.plain),
            )
            .timeout(const Duration(seconds: 10));

        final content = response.data?.toString() ?? '';
        if (content.isEmpty) return null;

        // Parse changelog untuk current version (bukan compare dengan remote)
        return _parseCurrentVersion(content, currentVersion);
      }

      return null;
    } catch (_) {
      // Silent fail — network error, dll.
      return null;
    }
  }

  /// Parse CHANGELOG.md dan kembalikan UpdateInfo untuk current version.
  ///
  /// Berbeda dengan [_parse] yang compare remote vs current dan hanya return jika
  /// remote lebih baru, method ini return changelog dari current version yang sedang
  /// running untuk ditampilkan di web.
  static UpdateInfo? _parseCurrentVersion(String content, String currentVersion) {
    final versionRegex = RegExp(
      r'^## \[(\d+\.\d+\.\d+)\](?:\s*-\s*(\S+))?',
      multiLine: true,
    );

    final matches = versionRegex.allMatches(content).toList();
    if (matches.isEmpty) return null;

    // Cari match untuk current version
    for (var i = 0; i < matches.length; i++) {
      final match = matches[i];
      final version = match.group(1)!;

      if (version == currentVersion) {
        final releaseDate = match.group(2) ?? '';
        final start = match.end;
        final end = i + 1 < matches.length ? matches[i + 1].start : content.length;
        final changelogContent = content.substring(start, end).trim();

        return UpdateInfo(
          latestVersion: version,
          releaseDate: releaseDate,
          changelogContent: changelogContent,
        );
      }
    }

    return null;
  }

  /// Tandai changelog current version sebagai sudah dilihat.
  ///
  /// Simpan current version ke localStorage sehingga changelog tidak
  /// muncul lagi hingga deployment versi berikutnya.
  static Future<void> markChangelogAsSeen(String currentVersion) async {
    if (!kIsWeb) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSeenVersionKey, currentVersion);
    } catch (_) {
      // Silent fail
    }
  }

  /// Get last seen version dari localStorage (web only).
  ///
  /// Berguna untuk debugging atau menampilkan info tentang changelog.
  static Future<String?> getLastSeenVersion() async {
    if (!kIsWeb) return null;

    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastSeenVersionKey);
    } catch (_) {
      return null;
    }
  }
}
