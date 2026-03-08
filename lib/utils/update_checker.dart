import 'package:dio/dio.dart';
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
  /// Get the appropriate branch based on current flavor
  /// - local flavor: uses 'test' branch
  /// - prod flavor: uses 'dev' branch
  static String get _branch => FlavorConfig.isLocal ? 'test' : 'dev';

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
}
