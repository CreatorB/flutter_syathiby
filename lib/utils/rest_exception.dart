class RestException implements Exception {
  final String message;
  final String errorCode;

  RestException(this.message, this.errorCode);

  static const String RESPONSE_USER_NOT_FOUND = "00";
  static const String RESPONSE_SUCCESS = "01";
  static const String RESPONSE_ERROR = "02";
  static const String RESPONSE_UPDATE_APP = "98";
  static const String RESPONSE_MAINTENANCE = "99";

  static const int CODE_UPDATE_APP = 98;
  static const int CODE_MAINTENANCE = 99;
  static const int CODE_ERROR_UNKNOWN = 999;
  static const int CODE_USER_NOT_FOUND = 0;
}
