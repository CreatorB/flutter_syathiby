import 'package:freezed_annotation/freezed_annotation.dart';

part 'siswa.freezed.dart';
part 'siswa.g.dart';

@freezed
abstract class Siswa with _$Siswa {
  const factory Siswa({
    @JsonKey(name: 'key') String? key,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'nis', defaultValue: '') String? nis,
    @JsonKey(name: 'id_siswa') String? idSiswa,
    @JsonKey(name: 'nama_lengkap') String? namaLengkap,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'alamat') String? alamat,
    @JsonKey(name: 'id_kelas') String? idKelas,
    @JsonKey(name: 'id_asrama') String? idAsrama,
    @JsonKey(name: 'kelas') String? kelas,
    @JsonKey(name: 'id_tingkat') String? idTingkat,
    @JsonKey(name: 'tingkat') String? tingkat,
    @JsonKey(name: 'img') String? img,
    @JsonKey(name: 'semester') String? semester,
    @JsonKey(name: 'tahun_ajaran') String? tahunAjaran,
    @JsonKey(name: 'id_store') String? idStore,
    @JsonKey(name: 'name_sekolah') String? nameSekolah,
    @JsonKey(name: 'rekeningspp') String? rekeningspp,
    @JsonKey(name: 'rekeningdaftarulang') String? rekeningdaftarulang,
    @JsonKey(name: 'rekeningtabungan') String? rekeningtabungan,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'status_absen') String? statusAbsen,
    @JsonKey(name: 'wali_kelas') String? waliKelas,
    @JsonKey(name: 'rangking') String? rangking,
    @JsonKey(name: 'jumlah_siswa') int? jumlahSiswa,
    @JsonKey(name: 'date') String? date,
    @JsonKey(name: 'staff') String? staff,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'tabungan') String? tabungan,
    @JsonKey(name: 'limit_transaksi') String? limitTransaksi,
  }) = _Siswa;

  factory Siswa.fromJson(Map<String, dynamic> json) => _$SiswaFromJson(json);
}
