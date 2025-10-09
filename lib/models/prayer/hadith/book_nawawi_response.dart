import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_nawawi_response.freezed.dart';
part 'book_nawawi_response.g.dart';

@freezed
class BookNawawiResponse with _$BookNawawiResponse {
  const factory BookNawawiResponse({
    required List<BookNawawi> data,
  }) = _BookNawawiResponse;

  factory BookNawawiResponse.fromJson(Map<String, dynamic> json) =>
      _$BookNawawiResponseFromJson(json);
}

@freezed
class BookNawawi with _$BookNawawi {
  const factory BookNawawi({
    required String arab,
    required String indo,
    required String judul,
    required String no,
  }) = _BookNawawi;

  factory BookNawawi.fromJson(Map<String, dynamic> json) =>
      _$BookNawawiFromJson(json);
}
