import 'package:freezed_annotation/freezed_annotation.dart';

part 'food.freezed.dart';
part 'food.g.dart';

@freezed
abstract class Makan with _$Makan {
  const factory Makan({
    @JsonKey(name: 'key') String? makanKey,
    @JsonKey(name: 'id_asrama') String? idAsrama,
    @JsonKey(name: 'nama_asrama') String? namaAsrama,
    @JsonKey(name: 'jumlah_santri') int? jumlahSantri,
    @JsonKey(name: 'musrif') String? musrif,
    @JsonKey(name: 'date') String? tanggal,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'absenpagi') int? absenPagi,
    @JsonKey(name: 'tidakabsenpagi') int? tidakAbsenPagi,
    @JsonKey(name: 'absensiang') int? absenSiang,
    @JsonKey(name: 'tidakabsensiang') int? tidakAbsenSiang,
    @JsonKey(name: 'absenmalam') int? absenMalam,
    @JsonKey(name: 'tidakabsenmalam') int? tidakAbsenMalam,
  }) = _Makan;

  factory Makan.fromJson(Map<String, dynamic> json) => _$MakanFromJson(json);
}
