import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_spend.freezed.dart';
part 'detail_spend.g.dart';

@freezed
class DetailSpend with _$DetailSpend {
  const factory DetailSpend({
    Struk? info,
    List<Data>? data,
  }) = _DetailSpend;

  factory DetailSpend.fromJson(Map<String, dynamic> json) =>
      _$DetailSpendFromJson(json);
}

@freezed
class Struk with _$Struk {
  const factory Struk({
    String? oleh,
    @JsonKey(name: 'no_invoice') String? noInvoice,
    String? date,
    @JsonKey(name: 'totalnominal') String? totalNominal,
    String? img,
  }) = _Struk;

  factory Struk.fromJson(Map<String, dynamic> json) => _$StrukFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({
    @JsonKey(name: 'name_spending') String? nameSpending,
    String? nominal,
    String? note,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
