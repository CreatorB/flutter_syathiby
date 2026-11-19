import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/notifikasi/notifikasi.dart';

part 'notifikasi_service.g.dart';

@RestApi()
abstract class NotifikasiService {
  factory NotifikasiService(Dio dio, {String baseUrl}) = _NotifikasiService;

  /// Daftar notifikasi staff yang sedang login.
  @GET('notifikasi/list.php')
  Future<List<Notifikasi>> getNotifikasi(
    @Query('key') String key,
    @Query('page') int page,
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
