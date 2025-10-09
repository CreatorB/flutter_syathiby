import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_history.freezed.dart';
part 'detail_history.g.dart';

@freezed
class DetailHistory with _$DetailHistory {
  const factory DetailHistory({
    @JsonKey(name: 'name_product') String? nameProduct,
    @JsonKey(name: 'name_store') String? nameStore,
    String? img,
    String? detail, //Important
    String? date, //Important
    String? stock, //Important
    String? nominal,
    String? by,
    String? status, //Important
    String? unit,
  }) = _DetailHistory;

  factory DetailHistory.fromJson(Map<String, dynamic> json) =>
      _$DetailHistoryFromJson(json);
}
