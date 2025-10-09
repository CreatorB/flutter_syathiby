import 'package:freezed_annotation/freezed_annotation.dart';

part 'response_entity.freezed.dart';
part 'response_entity.g.dart';

@freezed
class ResponseEntity with _$ResponseEntity {
  const factory ResponseEntity({
    required dynamic data,
    required String status,
    required String msg,
    required String errCode,
  }) = _ResponseEntity;

  factory ResponseEntity.fromJson(Map<String, dynamic> json) =>
      _$ResponseEntityFromJson(json);
}
