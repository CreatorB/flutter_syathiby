import 'package:freezed_annotation/freezed_annotation.dart';

part 'slip.freezed.dart';
part 'slip.g.dart';

@freezed
class Slip with _$Slip {
  const factory Slip({
    String? key,
    String? email,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    String? address,
    String? period,
    String? part,
    @JsonKey(name: 'id_store') String? idStore,
    @JsonKey(name: 'name_store') String? nameStore,
    @JsonKey(name: 'salary_fixed') String? salaryFixed,
    String? commission,
    String? allowance,
    String? piece,
    @JsonKey(name: 'total_sales') String? totalSales,
    @JsonKey(name: 'total_salary') String? totalSalary,
    String? presence,
    @JsonKey(name: 'gajilembur') String? gajiLembur,
    @JsonKey(name: 'jamlembur') String? jamLembur,
    @JsonKey(name: 'totallembur') String? totalLembur,
  }) = _Slip;

  factory Slip.fromJson(Map<String, dynamic> json) => _$SlipFromJson(json);
}
