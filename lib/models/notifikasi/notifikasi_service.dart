import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/notifikasi/notifikasi.dart';

part 'notifikasi_service.g.dart';

@RestApi()
abstract class NotifikasiService {
  factory NotifikasiService(Dio dio, {String baseUrl}) = _NotifikasiService;

  /// Daftar notifikasi staff yang sedang login, satu MINGGU per permintaan.
  ///
  /// `week` 0 = minggu berjalan, 1 = minggu lalu, dst. Server mengembalikan
  /// `ada_lagi` kalau masih ada minggu yang lebih lama -- itu yang dipakai
  /// aplikasi untuk memuat minggu berikutnya saat daftar di-scroll.
  @GET('notifikasi/list.php')
  Future<NotifikasiMinggu> getNotifikasi(
    @Query('key') String key,
    @Query('week') int week,
  );

  /// Detail satu notifikasi. Server hanya mengembalikan notifikasi milik
  /// staff yang sedang login -- id milik orang lain dibalas "tidak ditemukan".
  @GET('notifikasi/detail.php')
  Future<Notifikasi> getNotifikasiDetail(
    @Query('key') String key,
    @Query('id') int id,
  );

  /// Jumlah notifikasi yang belum dibaca (untuk badge lonceng).
  @GET('notifikasi/unread.php')
  Future<NotifikasiUnread> getNotifikasiUnread(
    @Query('key') String key,
  );

  /// Tandai satu notifikasi (id) atau semua yang belum dibaca sebagai dibaca.
  @GET('notifikasi/read.php')
  Future<Message> readNotifikasi(
    @Query('key') String key,
    @Query('id') int id,
  );
}
