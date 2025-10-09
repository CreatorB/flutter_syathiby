import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_label.freezed.dart';
part 'detail_label.g.dart';

@freezed
class DetailLabel with _$DetailLabel {
  const factory DetailLabel({
    Struk? struk,
    List<Data>? data,
  }) = _DetailLabel;

  factory DetailLabel.fromJson(Map<String, dynamic> json) =>
      _$DetailLabelFromJson(json);
}

@freezed
class Struk with _$Struk {
  const factory Struk({
    String? noInvoice,
  }) = _Struk;

  factory Struk.fromJson(Map<String, dynamic> json) => _$StrukFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({
    String? nameStore,
    String? codeproduct,
    String? nameProduct,
    String? noInvoice,
    String? idProduct,
    String? date,
    String? amount,
    String? img,
    String? description,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
