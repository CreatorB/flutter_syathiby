import 'package:freezed_annotation/freezed_annotation.dart';

part 'transfer.freezed.dart';
part 'transfer.g.dart';

@freezed
class Transfer with _$Transfer {
  const factory Transfer({
    String? name_product,
    String? name_store,
    String? img,
    String? no_invoice,
    String? date,
    String? payment,
    String? totalorder,
    String? nominal,
    String? by,
    String? status,
    String? type,
  }) = _Transfer;

  factory Transfer.fromJson(Map<String, dynamic> json) =>
      _$TransferFromJson(json);
}
