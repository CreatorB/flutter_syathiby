import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:syathiby/utils/api_log_config.dart';

/// Interceptor untuk logging API yang dapat dikonfigurasi
///
/// Fitur:
/// - Global toggle on/off
/// - Per-API logging dengan path spesifik
/// - Pattern matching untuk group API
///
/// Contoh penggunaan:
/// ```dart
/// // Di awal aplikasi atau di providers.dart
/// ApiLogConfig.enableGlobalLog = false; // Matikan global log
/// ApiLogConfig.addLogPath('/api/login'); // Hanya log endpoint login
/// ```
class ConfigurableLogInterceptor extends Interceptor {
  final bool logRequest;
  final bool logRequestHeader;
  final bool logRequestBody;
  final bool logResponseHeader;
  final bool logResponseBody;
  final bool logError;

  /// Jika true, akan menggunakan setting dari [ApiLogConfig]
  /// Jika false, akan selalu log (legacy behavior)
  final bool useConfig;

  ConfigurableLogInterceptor({
    this.logRequest = true,
    this.logRequestHeader = true,
    this.logRequestBody = true,
    this.logResponseHeader = true,
    this.logResponseBody = true,
    this.logError = true,
    this.useConfig = true,
  });

  bool _shouldLog(String path) {
    if (!useConfig) return true;
    return ApiLogConfig.shouldLog(path);
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  String _prettyJson(dynamic data) {
    try {
      if (data is String) {
        final decoded = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } else if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      return data.toString();
    } catch (e) {
      return data.toString();
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;

    if (_shouldLog(path)) {
      _log('');
      _log('╔══════════════════════════════════════════════════════════════');
      _log('║ 🚀 REQUEST');
      _log('╠══════════════════════════════════════════════════════════════');
      _log('║ ${options.method} ${options.baseUrl}$path');
      _log('║ Time: ${DateTime.now().toIso8601String()}');

      if (logRequestHeader && options.headers.isNotEmpty) {
        _log('╠──────────────────────────────────────────────────────────────');
        _log('║ Headers:');
        options.headers.forEach((key, value) {
          // Mask sensitive headers
          if (key.toLowerCase().contains('authorization') ||
              key.toLowerCase().contains('token')) {
            _log('║   $key: ***MASKED***');
          } else {
            _log('║   $key: $value');
          }
        });
      }

      if (logRequestBody && options.data != null) {
        _log('╠──────────────────────────────────────────────────────────────');
        _log('║ Body:');
        final prettyBody = _prettyJson(options.data);
        for (final line in prettyBody.split('\n')) {
          _log('║   $line');
        }
      }

      if (options.queryParameters.isNotEmpty) {
        _log('╠──────────────────────────────────────────────────────────────');
        _log('║ Query Parameters:');
        options.queryParameters.forEach((key, value) {
          _log('║   $key: $value');
        });
      }

      _log('╚══════════════════════════════════════════════════════════════');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final path = response.requestOptions.path;

    if (_shouldLog(path)) {
      final statusCode = response.statusCode ?? 0;
      final statusEmoji = statusCode >= 200 && statusCode < 300 ? '✅' : '⚠️';

      _log('');
      _log('╔══════════════════════════════════════════════════════════════');
      _log('║ $statusEmoji RESPONSE [$statusCode]');
      _log('╠══════════════════════════════════════════════════════════════');
      _log('║ ${response.requestOptions.method} ${response.requestOptions.baseUrl}$path');
      _log('║ Time: ${DateTime.now().toIso8601String()}');

      if (logResponseHeader) {
        _log('╠──────────────────────────────────────────────────────────────');
        _log('║ Headers:');
        response.headers.forEach((name, values) {
          _log('║   $name: ${values.join(", ")}');
        });
      }

      if (logResponseBody && response.data != null) {
        _log('╠──────────────────────────────────────────────────────────────');
        _log('║ Body:');
        final prettyBody = _prettyJson(response.data);
        // Limit panjang output untuk response besar
        final lines = prettyBody.split('\n');
        const maxLines = 100;
        for (var i = 0; i < lines.length && i < maxLines; i++) {
          _log('║   ${lines[i]}');
        }
        if (lines.length > maxLines) {
          _log('║   ... (${lines.length - maxLines} more lines)');
        }
      }

      _log('╚══════════════════════════════════════════════════════════════');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final path = err.requestOptions.path;

    // Error selalu di-log jika logError = true (untuk debugging)
    if (logError && _shouldLog(path)) {
      _log('');
      _log('╔══════════════════════════════════════════════════════════════');
      _log('║ ❌ ERROR');
      _log('╠══════════════════════════════════════════════════════════════');
      _log('║ ${err.requestOptions.method} ${err.requestOptions.baseUrl}$path');
      _log('║ Time: ${DateTime.now().toIso8601String()}');
      _log('╠──────────────────────────────────────────────────────────────');
      _log('║ Type: ${err.type}');
      _log('║ Message: ${err.message}');

      if (err.response != null) {
        _log('║ Status Code: ${err.response?.statusCode}');
        if (err.response?.data != null) {
          _log('╠──────────────────────────────────────────────────────────────');
          _log('║ Response Body:');
          final prettyBody = _prettyJson(err.response?.data);
          for (final line in prettyBody.split('\n')) {
            _log('║   $line');
          }
        }
      }

      _log('╚══════════════════════════════════════════════════════════════');
    }

    handler.next(err);
  }
}
