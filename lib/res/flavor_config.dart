/// Flavor-based configuration for different environments
/// 
/// Usage with build commands:
/// - PROD: fvm flutter run --flavor prod --dart-define=FLAVOR=prod
/// - LOCAL: fvm flutter run --flavor local --dart-define=FLAVOR=local
class FlavorConfig {
  /// Available flavor configurations
  static const Map<String, Map<String, String>> _configs = {
    'prod': {
      'API_URL': 'https://aplikasi.syathiby.id/geten/',
      'LINK_BASE': 'https://aplikasi.syathiby.id',
    },
    'local': {
      'API_URL': 'http://192.168.50.100/aplikasi/geten/',
      'LINK_BASE': 'http://192.168.50.100/aplikasi',
    },
    // Ditambahkan 5 Sep 2026. Sebelumnya build web yang di-deploy ke
    // aplikasidev.syathiby.id memakai flavor 'prod', sehingga aplikasinya
    // menembak API PRODUKSI dari origin staging. Browser memblokirnya lewat CORS
    // (prod hanya mengizinkan origin-nya sendiri) dan user melihat "Gagal
    // terhubung ke server" -- staging jadi tidak bisa dipakai menguji apa pun.
    // Blokir CORS itu sendiri BENAR: tanpanya, uji coba di staging akan menulis
    // data ke produksi.
    'staging': {
      'API_URL': 'https://aplikasidev.syathiby.id/geten/',
      'LINK_BASE': 'https://aplikasidev.syathiby.id',
    },
  };

  /// Current flavor from build-time dart-define
  /// Default to 'prod' if not specified
  static const String currentFlavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'prod',
  );

  /// Get current config based on flavor
  static Map<String, String> get _currentConfig {
    return _configs[currentFlavor] ?? _configs['prod']!;
  }

  /// API URL for current flavor
  static String get apiUrl => _currentConfig['API_URL']!;

  /// Link base URL for current flavor
  static String get linkBase => _currentConfig['LINK_BASE']!;

  /// Check if current flavor is production
  static bool get isProd => currentFlavor == 'prod';

  /// Check if current flavor is local
  static bool get isLocal => currentFlavor == 'local';

  /// Check if current flavor is staging
  static bool get isStaging => currentFlavor == 'staging';

  /// Get flavor display name
  static String get flavorName => currentFlavor.toUpperCase();
}
