import 'package:syathiby/models/prayer/hadith/book_nawawi_response.dart';
import 'package:syathiby/models/prayer/hadith/book_response.dart';
import 'package:syathiby/models/prayer/hadith/hadith_detail_response.dart';
import 'package:syathiby/models/prayer/hadith/hadith_response.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hadith_controller.g.dart';

@riverpod
Future<BookResponse> fetchBookList(FetchBookListRef ref) async {
  return await ref.watch(hadithServiceProvider).getBooks();
}

@riverpod
Future<HadithResponse> fetchHadithList(
  FetchHadithListRef ref, {
  required String bookId,
  required String range,
}) async {
  return await ref
      .watch(hadithServiceProvider)
      .getHadith(bookId: bookId, range: range);
}

@riverpod
Future<HadithDetailResponse> fetchHadithDetail(
  FetchHadithDetailRef ref, {
  required String bookId,
  required int hadithNumber,
}) async {
  return await ref.watch(hadithServiceProvider).getHadithDetail(
        bookId: bookId,
        number: hadithNumber,
      );
}

@riverpod
Future<BookNawawiResponse> fetchArbainNawawi(FetchArbainNawawiRef ref) async {
  return await ref.watch(hadithServiceProvider).getArbainNawawi();
}
