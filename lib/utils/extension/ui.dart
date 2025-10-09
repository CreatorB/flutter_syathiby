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
        autoCloseDuration: const Duration(seconds: 3),
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
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
        return 'Kesalahan respons tanpa detail respons';
      }
      if (error.type == DioExceptionType.unknown) {
        return 'Kesalahan lainnya terjadi';
      }
      return 'Terjadi kesalahan saat request ke server, silahkan periksa koneksi internet Anda';
    }
    return 'Kesalahan lainnya terjadi: $error';
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
      title: Text(message),
      autoCloseDuration: Duration(seconds: autoCloseDuration ?? 2),
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
      ),
      autoCloseDuration: const Duration(seconds: 3),
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
    );
  }

  String _errorMessage(Object? error) {
    if (error is DioException) {
      final dioError = error.error;
      if (dioError is RestException) {
        return dioError.message;
      }
      return dioError.toString();
    } else {
      return error.toString();
    }
  }
}
