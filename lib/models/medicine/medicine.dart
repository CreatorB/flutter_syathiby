import 'package:freezed_annotation/freezed_annotation.dart';

part 'medicine.freezed.dart';
part 'medicine.g.dart';

@freezed
class DataObat with _$DataObat {
  const factory DataObat({
    String? id_data_obat,
    String? name,
    String? unit,
    String? img,
    bool? active,
    int? price,
    String? stock,
    String? description,
    bool? posisi,
  }) = _DataObat;

  factory DataObat.fromJson(Map<String, dynamic> json) =>
      _$DataObatFromJson(json);
}
