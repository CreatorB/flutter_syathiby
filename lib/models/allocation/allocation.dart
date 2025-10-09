import 'package:freezed_annotation/freezed_annotation.dart';

part 'allocation.freezed.dart';
part 'allocation.g.dart';

@freezed
class Allocation with _$Allocation {
  const factory Allocation({
    @JsonKey(name: 'id_alokasi') String? allocationId,
    @JsonKey(name: 'name_alokasi') String? allocationName,
  }) = _Allocation;

  factory Allocation.fromJson(Map<String, dynamic> json) =>
      _$AllocationFromJson(json);
}
