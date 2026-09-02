import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/rest_exception.dart';
import 'package:toastification/toastification.dart';

/// A helper [AsyncValue] extension to show an alert dialog on error
extension AsyncValueUI on AsyncValue {
  void showToastOnError(BuildContext context) {
    if (!isLoading && hasError) {
      toastification.show(
        context: context,
        title: Text(
          _errorMessage(error),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
        autoCloseDuration: const Duration(seconds: 4),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        backgroundColor: Colors.red.withValues(alpha: 0.65),
        foregroundColor: Colors.white,
      );
    }
  }

  String _errorMessage(Object? error) {
    if (error is DioException) {
      final dioError = error.error;

      if (dioError is RestException) {
        return dioError.message;
      }

      if (error.type == DioExceptionType.connectionTimeout) {
        return 'Waktu koneksi dengan server habis';
      }
      if (error.type == DioExceptionType.sendTimeout) {
        return 'Waktu kirim habis saat terhubung dengan server';
      }
      if (error.type == DioExceptionType.receiveTimeout) {
        return 'Waktu terima habis saat terhubung dengan server';
      }

      if (error.type == DioExceptionType.badResponse) {
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        String detail = '';

        if (responseData is Map) {
          detail = responseData['msg'] ?? responseData['message'] ?? responseData['error'] ?? '';
          if (detail.isNotEmpty) detail = '\n$detail';
        }

        if (statusCode != null) {
          return 'Server error ($statusCode)$detail';
        }
        return 'Kesalahan respons dari server$detail';
      }

      if (error.type == DioExceptionType.cancel) {
        return 'Permintaan dibatalkan';
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
      }

      if (error.type == DioExceptionType.unknown) {
        final message = error.message ?? '';
        if (message.contains('SocketException') || message.contains('Connection')) {
          return 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
        }
        if (message.contains('FormatException') || message.contains('JSON')) {
          return 'Format data dari server tidak valid.';
        }
        return 'Terjadi kesalahan: $message';
      }

      return 'Terjadi kesalahan saat request ke server, silaturahmi periksa koneksi internet Anda';
    }

    if (error is RestException) {
      return error.message;
    }

    final errorStr = error.toString();
    if (errorStr.contains('SocketException') || errorStr.contains('Connection')) {
      return 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
    }
    if (errorStr.contains('TimeoutException')) {
      return 'Waktu tunggu habis. Server sedang sibuk, coba lagi.';
    }

    return 'Kesalahan: ${error?.toString() ?? 'Unknown error'}';
  }
}

extension SnapshotX on AsyncSnapshot {
  bool get isError => hasError && connectionState != ConnectionState.waiting;

  bool get isLoading =>
      connectionState == ConnectionState.waiting ||
      connectionState == ConnectionState.active;

  bool get isLoaded => connectionState == ConnectionState.done;
}

extension UiX on BuildContext {
  void showSnackBar(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    bool isErrorMessage = false,
  }) {
    final snackBar = SnackBar(
      backgroundColor: isErrorMessage ? colorError : null,
      content: Text(
        message,
        style: isErrorMessage
            ? labelMediumBold?.copyWith(
                color: colorOnError,
              )
            : null,
      ),
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onAction,
            )
          : null,
    );
    ScaffoldMessenger.of(this)
        .showSnackBar(snackBar)
        .closed
        .then((value) => ScaffoldMessenger.of(this).clearSnackBars());
  }

  void showSuccessMessage(
    String message, {
    VoidCallback? onComplete,
    int? autoCloseDuration,
  }) {
    toastification.show(
      context: this,
      title: Text(
        message,
        maxLines: 4,
        overflow: TextOverflow.visible,
        style: const TextStyle(fontSize: 14),
      ),
      autoCloseDuration: Duration(seconds: autoCloseDuration ?? 3),
      style: ToastificationStyle.fillColored,
      type: ToastificationType.success,
      callbacks: ToastificationCallbacks(
        onAutoCompleteCompleted: onComplete != null
            ? (value) {
                onComplete();
              }
            : null,
      ),
    );
  }

  void showErrorMessage(Object? error) {
    toastification.show(
      context: this,
      title: Text(
        _errorMessage(error),
        maxLines: 4,
        overflow: TextOverflow.visible,
        style: const TextStyle(fontSize: 14),
      ),
      autoCloseDuration: const Duration(seconds: 4),
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      backgroundColor: Colors.red.withValues(alpha: 0.65),
      foregroundColor: Colors.white,
    );
  }

  String _errorMessage(Object? error) {
    if (error is DioException) {
      final dioError = error.error;

      if (dioError is RestException) {
        return dioError.message;
      }

      if (error.type == DioExceptionType.connectionTimeout) {
        return 'Waktu koneksi dengan server habis';
      }
      if (error.type == DioExceptionType.sendTimeout) {
        return 'Waktu kirim habis saat terhubung dengan server';
      }
      if (error.type == DioExceptionType.receiveTimeout) {
        return 'Waktu terima habis saat terhubung dengan server';
      }

      if (error.type == DioExceptionType.badResponse) {
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        String detail = '';

        if (responseData is Map) {
          detail = responseData['msg'] ?? responseData['message'] ?? responseData['error'] ?? '';
          if (detail.isNotEmpty) detail = '\n$detail';
        }

        if (statusCode != null) {
          return 'Server error ($statusCode)$detail';
        }
        return 'Kesalahan respons dari server$detail';
      }

      if (error.type == DioExceptionType.cancel) {
        return 'Permintaan dibatalkan';
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
      }

      if (error.type == DioExceptionType.unknown) {
        final message = error.message ?? '';
        if (message.contains('SocketException') || message.contains('Connection')) {
          return 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
        }
        if (message.contains('FormatException') || message.contains('JSON')) {
          return 'Format data dari server tidak valid.';
        }
        return 'Terjadi kesalahan: $message';
      }

      return dioError.toString();
    }

    if (error is RestException) {
      return error.message;
    }

    final errorStr = error.toString();
    if (errorStr.contains('SocketException') || errorStr.contains('Connection')) {
      return 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
    }
    if (errorStr.contains('TimeoutException')) {
      return 'Waktu tunggu habis. Server sedang sibuk, coba lagi.';
    }

    return error.toString();
  }
}
