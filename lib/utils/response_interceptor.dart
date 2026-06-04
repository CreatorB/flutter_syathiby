import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:syathiby/models/response_entity.dart';
import 'package:syathiby/utils/rest_exception.dart';

class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
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
          print('[ResponseInterceptor] Failed to parse ResponseEntity: $e');
          print('[ResponseInterceptor] Body keys: ${body.keys.toList()}');
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
          // Jika ada field `data` berupa list → endpoint list → kembalikan []
          if (responseData.data is List) {
            response.data = responseData.data;
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