import 'package:freezed_annotation/freezed_annotation.dart';

part 'surah.freezed.dart';
part 'surah.g.dart';

@freezed
class Surah with _$Surah {
  const factory Surah({
    required int nomor,
    required String nama,
    @JsonKey(name: 'nama_latin') required String namaLatin,
    @JsonKey(name: 'jumlah_ayat') required int jumlahAyat,
    @JsonKey(name: 'tempat_turun') required String tempatTurun,
    required String arti,
    required String deskripsi,
    required String audio,
  }) = _Surah;

  factory Surah.fromJson(Map<String, dynamic> json) => _$SurahFromJson(json);
}
