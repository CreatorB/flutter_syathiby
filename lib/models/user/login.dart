import 'package:freezed_annotation/freezed_annotation.dart';

part 'login.freezed.dart';
part 'login.g.dart';

@freezed
class Login with _$Login {
  const factory Login({
    String? key,
    String? currency,
    String? user,
    String? level,
    String? master,
    String? packages,
    String? typestore,
    String? decimal,
    String? id_store,
    String? device,
  }) = _Login;

  factory Login.fromJson(Map<String, dynamic> json) => _$LoginFromJson(json);
}
