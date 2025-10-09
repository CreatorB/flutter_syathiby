import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_visiting.g.dart';

// @freezed
// class RequestVisiting with _$RequestVisiting {
//   const factory RequestVisiting({
//     String? key,
//     String? name,
//     String? address,
//     String? date,
//     String? hour,
//     String? detail,
//     String? img,
//     double? latitude,
//     double? longitude,
//   }) = _RequestVisiting;
//
//   factory RequestVisiting.fromJson(Map<String, dynamic> json) =>
//       _$RequestVisitingFromJson(json);
// }

@JsonSerializable()
class RequestVisiting {
  final String? key;
  final String? name;
  final String? address;
  final String? date;
  final String? hour;
  final String? detail;
  final String? img;
  final double? latitude;
  final double? longitude;

  RequestVisiting({
    this.key,
    this.name,
    this.address,
    this.date,
    this.hour,
    this.detail,
    this.img,
    this.latitude,
    this.longitude,
  });

  factory RequestVisiting.fromJson(Map<String, dynamic> json) =>
      _$RequestVisitingFromJson(json);

  Map<String, dynamic> toJson() => _$RequestVisitingToJson(this);
}
