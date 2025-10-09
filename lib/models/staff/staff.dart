import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff.freezed.dart';
part 'staff.g.dart';

@freezed
class Staff with _$Staff {
  const factory Staff({
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
    @JsonKey(name: 'gajilembur') String? gajilembur,
    @JsonKey(name: 'commission') String? commission,
    @JsonKey(name: 'allowance') String? allowance,
    @JsonKey(name: 'piece') String? piece,
    @JsonKey(name: 'total_work') int? totalWork,
    @JsonKey(name: 'work_procces') int? workProcces,
    @JsonKey(name: 'work_finish') int? workFinish,
    @JsonKey(name: 'work_paid') int? workPaid,
    @JsonKey(name: 'date_update') String? dateUpdate,
    @JsonKey(name: 'latlong') String? latlong,
    @JsonKey(name: 'latitude') String? latitude,
    @JsonKey(name: 'longitude') String? longitude,
    @JsonKey(name: 'last_chat') String? lastChat,
    @JsonKey(name: 'detail') String? detail,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'chat') String? chat,
    @JsonKey(name: 'kinerja') String? kinerja,
  }) = _Staff;

  factory Staff.fromJson(Map<String, dynamic> json) => _$StaffFromJson(json);
}
