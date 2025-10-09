import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_response.freezed.dart';
part 'book_response.g.dart';

@freezed
class BookResponse with _$BookResponse {
  const factory BookResponse({
    required int code,
    required String message,
    required List<Book> data,
    required bool error,
  }) = _BookResponse;

  factory BookResponse.fromJson(Map<String, dynamic> json) =>
      _$BookResponseFromJson(json);
}

@freezed
class Book with _$Book {
  const factory Book({
    required String name,
    required String id,
    required int available,
  }) = _Book;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
}
