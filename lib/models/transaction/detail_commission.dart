import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_commission.freezed.dart';
part 'detail_commission.g.dart';

@freezed
class DetailCommission with _$DetailCommission {
  const factory DetailCommission({
    String? detail,
    String? date,
    String? amount,
    String? status,
    String? type,
  }) = _DetailCommission;

  factory DetailCommission.fromJson(Map<String, dynamic> json) =>
      _$DetailCommissionFromJson(json);
}
