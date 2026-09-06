import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:syathiby/models/response_entity.dart';
import 'package:syathiby/utils/rest_exception.dart';

class ResponseInterceptor extends Interceptor {
  /// Path endpoints yang mengembalikan `Future<Message>` (single-object, bukan list).
  /// Untuk endpoint ini, `errCode='02'` tanpa field `data` harus dilempar sebagai
  /// `RestException` supaya pesan backend asli tampil di UI via `showToastOnError`,
  /// alih-alih dipaksa jadi `[]` yang bikin retrofit gagal parse.
  static const _messageEndpoints = <String>[
    'absenpengampu',
    'absenpengamputahfidz',
    'absentahfidz',
    'getsantritahfidz',
    'siswa/absen',
    'siswa/absenguru',
    'siswa/absenpengampu',
    'deletehalaqah',
    'siswa/insertmakan',
    'siswa/insertkegiatan',
    'siswa/inserttransaksi',
    'siswa/insertkegiatansearch',
    'siswa/insertmakansearch',
    // Permit (staff + student izin) write endpoints
    'permit/insert',
    'permit/insertsantri',
    'permit/confirm',
    'permit/confirmsantri',
    'permit/deletesantri',
    'permit/waliinsertsantri',
    'permit/walidecancelsantri',
    // Absen pulang susulan: pesan validasi (format jam, jam melewati sekarang, dll)
    // harus sampai ke user, bukan diganti list kosong.
    'attendance/pulangsusulan',
  ];

  bool _isMessageEndpoint(String path) {
    final lower = path.toLowerCase();
    return _messageEndpoints.any(lower.contains);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // SPECIAL CASE: search_mukholif.php and detail_mukholif.php return MukholifSearchResponse/MukholifDetailResponse structures
    // We need to keep the FULL response object (not extract just data)
    final path = response.requestOptions.path;
    if (path.contains('search_mukholif') || path.contains('detail_mukholif') || path.contains('insert_izin_tap')) {
      handler.next(response);
      return;
    }

    // 1. Smart Decode (String to Map)
    dynamic body = response.data;
    if (body is String && body.isNotEmpty) {
      try {
        body = jsonDecode(body);
      } catch (e) {
        if (kDebugMode) {
          print('[ResponseInterceptor] JSON decode failed: $e');
          print('[ResponseInterceptor] Raw response: ${body.toString().substring(0, body.toString().length > 200 ? 200 : body.toString().length)}');
        }
      }
    }

    // 2. Logic Utama
    if (body is Map<String, dynamic>) {
      ResponseEntity responseData;

      try {
        responseData = ResponseEntity.fromJson(body);
      } catch (e) {
        if (kDebugMode) {
          print('[ResponseInterceptor] [$path] Failed to parse ResponseEntity: $e');
          print('[ResponseInterceptor] [$path] Body keys: ${body.keys.toList()}');
          print('[ResponseInterceptor] [$path] Body: ${body.toString().substring(0, body.toString().length > 500 ? 500 : body.toString().length)}');
        }
        // If parsing fails, check if it's an error response that needs special handling
        final errCode = body['errCode'] ?? body['error_code'] ?? body['kode'];
        final msg = body['msg'] ?? body['message'] ?? body['error'] ?? 'Unknown error';

        if (errCode != null) {
          throw RestException(msg.toString(), errCode.toString());
        }

        // Let it through - maybe the endpoint returns data directly
        handler.next(response);
        return;
      }

      switch (responseData.errCode) {

        // KASUS SUKSES (01)
        case RestException.RESPONSE_SUCCESS:
          if (responseData.data != null) {
            response.data = responseData.data;
          } else {
            response.data = body;
          }
          handler.next(response);
          break;

        case RestException.RESPONSE_ERROR: // '02'
          // Untuk endpoint Message (write/single-object), `errCode='02'` tanpa `data`
          // adalah error valid yang pesannya harus sampai ke user. Lempar exception
          // supaya `showToastOnError` menampilkan `msg` asli dari backend.
          if (responseData.data is List) {
            response.data = responseData.data;
            handler.next(response);
          } else if (responseData.data == null) {
            if (_isMessageEndpoint(path)) {
              if (kDebugMode) {
                print('[ResponseInterceptor] [$path] errCode=02 + data=null → throw RestException(${responseData.msg})');
              }
              throw RestException(responseData.msg, responseData.errCode);
            }
            // List endpoint convention: errCode='02' "no data" tanpa field `data`
            // Kembalikan list kosong agar PagedListView / DropdownSearch tidak crash
            response.data = <dynamic>[];
            handler.next(response);
          } else if (responseData.data is Map<String, dynamic>) {
            // Single object response - pass it through
            response.data = responseData.data;
            handler.next(response);
          } else if (responseData.data is String) {
            // Sometimes server returns string instead of proper structure
            // Create a synthetic response for the caller
            response.data = {
              'status': responseData.status,
              'msg': responseData.msg,
              'errCode': responseData.errCode,
              'data': responseData.data,
            };
            handler.next(response);
          } else {
            // Endpoint single-object (contoh: attendance) → lempar error agar UI bisa tampilkan pesan
            throw RestException(responseData.msg, responseData.errCode);
          }
          break;

        case RestException.RESPONSE_USER_NOT_FOUND:
          throw RestException(responseData.msg, responseData.errCode);
        case RestException.RESPONSE_MAINTENANCE:
          throw RestException(responseData.msg, responseData.errCode);
        case RestException.RESPONSE_UPDATE_APP:
          throw RestException(responseData.msg, responseData.errCode);

        default:
          throw RestException(responseData.msg, responseData.errCode);
      }
    } else if (body is List) {
      // Direct array response - pass through
      response.data = body;
      handler.next(response);
    } else if (body is String && body.isEmpty) {
      // Empty string response
      response.data = null;
      handler.next(response);
    } else {
      // Bukan JSON yang diharapkan, tapi biarkan lewat untuk didebug
      if (kDebugMode) {
        print('[ResponseInterceptor] Unexpected response type: ${body.runtimeType}');
        print('[ResponseInterceptor] Response: ${body.toString().substring(0, body.toString().length > 200 ? 200 : body.toString().length)}');
      }
      handler.next(response);
    }
  }
}
