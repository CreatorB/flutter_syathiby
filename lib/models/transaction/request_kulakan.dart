import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_kulakan.freezed.dart';
part 'request_kulakan.g.dart';

@freezed
class RequestKulakan with _$RequestKulakan {
  const factory RequestKulakan({
    String? key,
    int? paymentType,
    int? totalOrder,
    String? idSupplier,
    String? dueDate,
    List<Barang>? product,
  }) = _RequestKulakan;

  factory RequestKulakan.fromJson(Map<String, dynamic> json) =>
      _$RequestKulakanFromJson(json);
}

@freezed
class Barang with _$Barang {
  const factory Barang({
    String? idProduct,
    int? amountProduct,
  }) = _Barang;

  factory Barang.fromJson(Map<String, dynamic> json) => _$BarangFromJson(json);
}
