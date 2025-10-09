import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:syathiby/models/transaction/transaction.dart';

part 'history_transaction.freezed.dart';
part 'history_transaction.g.dart';

@freezed
class HistoryTransaction with _$HistoryTransaction {
  const factory HistoryTransaction({
    dynamic totalorderall,
    @JsonKey(name: 'totalnominal') dynamic totalNominal,
    String? date,
    List<Transaction>? detail,
  }) = _HistoryTransaction;

  factory HistoryTransaction.fromJson(Map<String, dynamic> json) =>
      _$HistoryTransactionFromJson(json);
}
