import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:syathiby/models/response_entity.dart';
import 'package:syathiby/utils/rest_exception.dart';

class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final responseData = ResponseEntity.fromJson(jsonDecode(response.data));
    switch (responseData.errCode) {
      case RestException.RESPONSE_SUCCESS:
        if (responseData.data != null) {
          response.data = responseData.data;
        } else {
          response.data = jsonDecode(response.data);
        }
        handler.next(response);
        break;
      case RestException.RESPONSE_USER_NOT_FOUND:
        throw RestException(responseData.msg, responseData.errCode);
      case RestException.RESPONSE_ERROR:
        throw RestException(responseData.msg, responseData.errCode);
      case RestException.RESPONSE_MAINTENANCE:
        throw RestException(responseData.msg, responseData.errCode);
      case RestException.RESPONSE_UPDATE_APP:
        throw RestException(responseData.msg, responseData.errCode);
    }
  }
}
