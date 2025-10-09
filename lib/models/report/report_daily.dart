import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_daily.freezed.dart';
part 'report_daily.g.dart';

@freezed
abstract class ReportDaily with _$ReportDaily {
  const factory ReportDaily({
    Info? info,
    List<Daily>? dailyReport,
  }) = _ReportDaily;

  factory ReportDaily.fromJson(Map<String, dynamic> json) =>
      _$ReportDailyFromJson(json);
}

@freezed
abstract class Info with _$Info {
  const factory Info({
    @JsonKey(name: 'name_store') String? nameStore,
    String? date,
    String? total,
  }) = _Info;

  factory Info.fromJson(Map<String, dynamic> json) => _$InfoFromJson(json);
}

@freezed
abstract class Daily with _$Daily {
  const factory Daily({
    String? operator,
    @JsonKey(name: 'sales_cash') String? salesCash,
    @JsonKey(name: 'sales_debt') String? salesDebt,
    @JsonKey(name: 'sales_credit_card') String? salesCreditCard,
    @JsonKey(name: 'sales_debit_card') String? salesDebitCard,
    String? gopay,
    String? ovo,
    String? dana,
    @JsonKey(name: 'sub_total') String? subTotal,
    @JsonKey(name: 'name_store') String? nameStore,
    String? date,
  }) = _Daily;

  factory Daily.fromJson(Map<String, dynamic> json) => _$DailyFromJson(json);
}
