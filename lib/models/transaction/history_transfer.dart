import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:syathiby/models/transaction/transfer.dart';

part 'history_transfer.freezed.dart';
part 'history_transfer.g.dart';

@freezed
class HistoryTransfer with _$HistoryTransfer {
  const factory HistoryTransfer({
    String? totalorderall,
    String? totalnominal,
    String? date,
    List<Transfer>? detail,
  }) = _HistoryTransfer;

  factory HistoryTransfer.fromJson(Map<String, dynamic> json) =>
      _$HistoryTransferFromJson(json);
}
