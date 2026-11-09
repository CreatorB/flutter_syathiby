import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_logout.freezed.dart';
part 'request_logout.g.dart';

@freezed
class RequestLogout with _$RequestLogout {
  const factory RequestLogout({
    String? key,
    String? token,
    double? latitude,
    double? longitude,
    bool? mock,
    String? device,
    String? lokasi,
    /// 'web' = token browser disimpan di kolom `users.token_web` (project
    /// Firebase `al-ukhuwah`), bukan `users.token` (Android).
    String? platform,
  }) = _RequestLogout;

  factory RequestLogout.fromJson(Map<String, dynamic> json) =>
      _$RequestLogoutFromJson(json);
}
