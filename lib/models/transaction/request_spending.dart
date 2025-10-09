import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_spending.freezed.dart';
part 'request_spending.g.dart';

@freezed
class RequestSpending with _$RequestSpending {
  @JsonSerializable(includeIfNull: false, explicitToJson: true)
  const factory RequestSpending({
    String? key,
    double? amount,
    String? date,
    String? img,
    List<BarangSpending>? spending,
  }) = _RequestSpending;

  factory RequestSpending.fromJson(Map<String, dynamic> json) =>
      _$RequestSpendingFromJson(json);
}

@freezed
class BarangSpending with _$BarangSpending {
  const factory BarangSpending({
    String? id,
    @JsonKey(name: 'name_spending') String? nameSpending,
    num? nominal,
    String? note,
  }) = _BarangSpending;

  factory BarangSpending.fromJson(Map<String, dynamic> json) =>
      _$BarangSpendingFromJson(json);
}
