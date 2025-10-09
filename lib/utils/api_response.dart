import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

@freezed
@JsonSerializable(genericArgumentFactories: true)
class VeganItemTagV2<T> with _$VeganItemTagV2<T> {
  const VeganItemTagV2._();

  const factory VeganItemTagV2({
    required T data,
    required String status,
    required String msg,
    required String errCode,
  }) = _VeganItemTag<T>;

  //It only works with block bodies and not with expression bodies
  //I don't know why
  factory VeganItemTagV2.fromJson(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return _$VeganItemTagV2FromJson<T>(json, fromJsonT);
  }

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) {
    return _$VeganItemTagV2ToJson<T>(this, toJsonT);
  }
}

@Freezed(genericArgumentFactories: true)
class ResponseWrapper<T> with _$ResponseWrapper<T> {
  const factory ResponseWrapper({
    required String status,
    required String msg,
    required String errCode,
    final T? data,
  }) = _ResponseWrapper;

  factory ResponseWrapper.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$ResponseWrapperFromJson<T>(json, fromJsonT);
}
