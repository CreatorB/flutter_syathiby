import 'dart:convert';
import 'package:dio/dio.dart';
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
      } catch (e) {}
    }

    // 2. Logic Utama
    if (body is Map<String, dynamic>) {
      final responseData = ResponseEntity.fromJson(body);

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
    } else {
      // Bukan JSON (mungkin HTML error), biarkan lewat untuk didebug
      handler.next(response);
    }
  }
}