import 'package:freezed_annotation/freezed_annotation.dart';

part 'non_tunai.freezed.dart';
part 'non_tunai.g.dart';

@freezed
class NonTunai with _$NonTunai {
  const factory NonTunai({
    String? idLink,
    String? nameLink,
    String? img,
    String? inc,
  }) = _NonTunai;

  factory NonTunai.fromJson(Map<String, dynamic> json) =>
      _$NonTunaiFromJson(json);
}
