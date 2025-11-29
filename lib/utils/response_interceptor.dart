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

        // ============================================================
        // PERBAIKAN: TAMBAHKAN CASE '02' (DATA KOSONG)
        // ============================================================
        case '02': 
          // Jangan throw Error! Berikan List Kosong agar UI tidak crash.
          // Retrofit akan membacanya sebagai List kosong dan UI menampilkan "No Data".
          response.data = []; 
          handler.next(response);
          break;
        // ============================================================

        case RestException.RESPONSE_USER_NOT_FOUND:
          throw RestException(responseData.msg, responseData.errCode);
        case RestException.RESPONSE_ERROR:
          throw RestException(responseData.msg, responseData.errCode);
        case RestException.RESPONSE_MAINTENANCE:
          throw RestException(responseData.msg, responseData.errCode);
        case RestException.RESPONSE_UPDATE_APP:
          throw RestException(responseData.msg, responseData.errCode);
        
        default:
          // Jika kode aneh, baru lempar error
          throw RestException(responseData.msg, responseData.errCode);
      }
    } else {
      // Bukan JSON (mungkin HTML error), biarkan lewat untuk didebug
      handler.next(response);
    }
  }
}