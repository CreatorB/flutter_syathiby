import 'package:freezed_annotation/freezed_annotation.dart';

part 'store.freezed.dart';
part 'store.g.dart';

@freezed
class Store with _$Store {
  const factory Store({
    @JsonKey(name: 'id_store') String? idStore,
    @JsonKey(name: 'name_store') String? nameStore,
    @JsonKey(name: 'number_store') String? numberStore,
    String? address,
    String? email,
    String? nohp,
    String? tax,
    @JsonKey(name: 'service_charge') String? serviceCharge,
    String? saldo,
    String? point,
    String? order,
    String? type,
    dynamic omset,
    String? level,
    String? position,
    String? shift,
    dynamic initial,
    dynamic footer,
    String? photo,
    @JsonKey(name: 'name_staff') String? nameStaff,
    int? attandence,
    int? job,
    String? today,
    String? workhour,
    String? timeattand,
    String? during,
    String? late,
    int? notif,
    int? notifpelanggaran,
    int? notifizin,
    int? notifizinsantri,
    int? notifmudir,
    int? notifmanager,
    int? notifkeuangan,
    int? notiflogistik,
    int? notifpermintaanobatmanager,
    int? notifukp,
    String? absen,
    String? guru,
    String? holiday,
    int? chat,
    int? kepengasuhan,
    int? kependidikan,
    int? kerumahtanggaan,
    int? tahfidz,
    int? kesehatan,
    int? permohonan,
    int? keuangan,
    int? meeting,
    int? unitusaha,
  }) = _Store;

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
}
