import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_on.freezed.dart';
part 'add_on.g.dart';

@freezed
abstract class AddOn with _$AddOn {
  const factory AddOn({
    @JsonKey(name: 'id_addon') String? idAddon,
    @JsonKey(name: 'id_product') String? idProduct,
    String? name,
    @JsonKey(name: 'name_addon') String? nameAddon,
    String? nominal,
    String? datanya,
    String? posisi,
    @JsonKey(name: 'posisis') bool? posisis,
    String? price,
    String? inc,
    String? type,
    String? status,
    String? number,
  }) = _AddOn;

  factory AddOn.fromJson(Map<String, dynamic> json) => _$AddOnFromJson(json);
}
