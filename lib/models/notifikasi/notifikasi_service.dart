import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/notifikasi/notifikasi.dart';

part 'notifikasi_service.g.dart';

@RestApi()
abstract class NotifikasiService {
  factory NotifikasiService(Dio dio, {String baseUrl}) = _NotifikasiService;

  /// Daftar notifikasi staff yang sedang login (satu halaman).
  @GET('notifikasi/list.php')
  Future<List<Notifikasi>> getNotifikasi(
    @Query('key') String key,
    @Query('page') int page,
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
