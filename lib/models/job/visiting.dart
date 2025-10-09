import 'package:freezed_annotation/freezed_annotation.dart';

part 'visiting.freezed.dart';
part 'visiting.g.dart';

@freezed
class Visiting with _$Visiting {
  const factory Visiting({
    String? invoice,
  }) = _Visiting;

  factory Visiting.fromJson(Map<String, dynamic> json) =>
      _$VisitingFromJson(json);
}
