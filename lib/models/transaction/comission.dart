import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:syathiby/models/transaction/detail_commission.dart';

part 'comission.freezed.dart';
part 'comission.g.dart';

@freezed
class Comission with _$Comission {
  const factory Comission({
    String? totalorderall,
    String? date,
    String? totalcommision,
    List<DetailCommission>? detail,
  }) = _Comission;

  factory Comission.fromJson(Map<String, dynamic> json) =>
      _$ComissionFromJson(json);
}
