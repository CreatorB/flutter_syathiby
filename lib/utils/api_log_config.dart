import 'package:flutter/foundation.dart';

/// Konfigurasi untuk mengatur logging API
///
/// Contoh penggunaan:
/// ```dart
/// // Set global logging (default: false di release, true di debug)
/// ApiLogConfig.enableGlobalLog = true;
///
/// // Log spesifik API tertentu saja
/// ApiLogConfig.addLogPath('/api/login');
/// ApiLogConfig.addLogPath('/api/user/profile');
///
/// // Atau gunakan pattern regex
/// ApiLogConfig.addLogPattern(RegExp(r'/api/auth/.*'));
/// ```
class ApiLogConfig {
  ApiLogConfig._();

  /// Global toggle untuk semua log API
  /// Default: true di debug mode, false di release mode
  static bool _enableGlobalLog = kDebugMode;

  /// Getter untuk global log status
  static bool get enableGlobalLog => _enableGlobalLog;

  /// Setter untuk global log status
  static set enableGlobalLog(bool value) {
    _enableGlobalLog = value;
    if (kDebugMode) {
      debugPrint('🔧 ApiLogConfig: Global logging ${value ? "ENABLED" : "DISABLED"}');
    }
  }

  /// Daftar path API yang akan di-log secara spesifik
  /// Jika kosong dan globalLog = false, tidak ada yang di-log
  /// Jika ada isinya, path ini akan di-log meskipun globalLog = false
  static final Set<String> _logPaths = {};

  /// Daftar pattern regex untuk matching path yang akan di-log
  static final List<RegExp> _logPatterns = [];

  /// Menambahkan path spesifik yang akan di-log
  /// Path ini akan di-log meskipun [enableGlobalLog] = false
  static void addLogPath(String path) {
    _logPaths.add(path);
    if (kDebugMode) {
      debugPrint('🔧 ApiLogConfig: Added log path: $path');
    }
  }

  /// Menghapus path dari daftar log
  static void removeLogPath(String path) {
    _logPaths.remove(path);
  }

  /// Menambahkan pattern regex untuk matching path
  static void addLogPattern(RegExp pattern) {
    _logPatterns.add(pattern);
    if (kDebugMode) {
      debugPrint('🔧 ApiLogConfig: Added log pattern: ${pattern.pattern}');
    }
  }

  /// Menghapus semua path dan pattern
  static void clearLogFilters() {
    _logPaths.clear();
    _logPatterns.clear();
  }

  /// Mendapatkan semua path yang di-log
  static Set<String> get logPaths => Set.unmodifiable(_logPaths);

  /// Mengecek apakah path tertentu harus di-log
  ///
  /// Returns true jika:
  /// 1. [enableGlobalLog] = true, ATAU
  /// 2. Path ada di [_logPaths], ATAU
  /// 3. Path match dengan salah satu [_logPatterns]
  static bool shouldLog(String path) {
    // Jika global log aktif, log semua
    if (_enableGlobalLog) return true;

    // Cek apakah path ada di daftar spesifik
    if (_logPaths.contains(path)) return true;

    // Cek apakah path match dengan pattern
    for (final pattern in _logPatterns) {
      if (pattern.hasMatch(path)) return true;
    }

    return false;
  }

  /// Helper untuk mengecek apakah URL (full) harus di-log
  static bool shouldLogUrl(String url) {
    // Extract path dari URL
    try {
      final uri = Uri.parse(url);
      return shouldLog(uri.path);
    } catch (e) {
      return shouldLog(url);
    }
  }

  /// Print current configuration (untuk debugging)
  static void printConfig() {
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('🔧 ApiLogConfig Status:');
      debugPrint('   Global Log: $_enableGlobalLog');
      debugPrint('   Specific Paths: ${_logPaths.isEmpty ? "(none)" : ""}');
      for (final path in _logPaths) {
        debugPrint('     - $path');
      }
      debugPrint('   Patterns: ${_logPatterns.isEmpty ? "(none)" : ""}');
      for (final pattern in _logPatterns) {
        debugPrint('     - ${pattern.pattern}');
      }
      debugPrint('═══════════════════════════════════════');
    }
  }
}
