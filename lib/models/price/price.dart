import 'package:freezed_annotation/freezed_annotation.dart';

part 'price.freezed.dart';
part 'price.g.dart';

@freezed
abstract class Price with _$Price {
  const factory Price({
    @JsonKey(name: 'id_price') String? idPrice,
    @JsonKey(name: 'name_price') String? namePrice,
    @JsonKey(name: 'nominal') String? nominal,
    @JsonKey(name: 'initial') String? initial,
  }) = _Price;

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);
}
