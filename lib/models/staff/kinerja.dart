import 'package:freezed_annotation/freezed_annotation.dart';

part 'kinerja.freezed.dart';
part 'kinerja.g.dart';

@freezed
class Kinerja with _$Kinerja {
  const factory Kinerja({
    @JsonKey(name: 'key') String? key,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'address') String? address,
    @JsonKey(name: 'city') String? city,
    @JsonKey(name: 'img') String? img,
    @JsonKey(name: 'level') String? level,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'position') String? position,
    @JsonKey(name: 'id_store') String? idStore,
    @JsonKey(name: 'name_store') String? nameStore,
    @JsonKey(name: 'salary') String? salary,
    @JsonKey(name: 'kinerja') String? kinerja,
    @JsonKey(name: 'date') String? date,
    @JsonKey(name: 'hour') String? hour,
    @JsonKey(name: 'nama_kinerja') String? namaKinerja,
    @JsonKey(name: 'bobot') dynamic bobot,
    @JsonKey(name: 'status') String? status,
  }) = _Kinerja;

  factory Kinerja.fromJson(Map<String, dynamic> json) =>
      _$KinerjaFromJson(json);
}
