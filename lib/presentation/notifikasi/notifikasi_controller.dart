import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:syathiby/models/notifikasi/notifikasi.dart';
import 'package:syathiby/models/service_injection.dart';

part 'notifikasi_controller.g.dart';

/// Daftar notifikasi staff (kotak masuk).
///
/// Backend menyimpan setiap notifikasi yang dikirim ke staff ke tabel
/// `notifikasi`, jadi push FCM yang tidak sampai (token hilang, browser
/// tanpa izin) tetap terlihat di sini.
@riverpod
Future<List<Notifikasi>> fetchNotifikasi(
  FetchNotifikasiRef ref, {
  required String key,
  int page = 1,
}) async {
  if (key.isEmpty || key == 'null') return const <Notifikasi>[];
  final result = await ref
      .watch(notifikasiServiceProvider)
      .getNotifikasi(key, page);
  return result;
}

/// Jumlah notifikasi yang belum dibaca -- untuk badge lonceng.
@riverpod
Future<int> fetchNotifikasiUnread(
  FetchNotifikasiUnreadRef ref, {
  required String key,
}) async {
  if (key.isEmpty || key == 'null') return 0;
  try {
    final result = await ref
        .watch(notifikasiServiceProvider)
        .getNotifikasiUnread(key);
    return result.unread ?? 0;
  } catch (_) {
    // Lonceng tidak boleh membuat beranda error; angka 0 cukup.
    return 0;
  }
}

/// Menandai notifikasi sudah dibaca.
@riverpod
class NotifikasiRead extends _$NotifikasiRead {
  @override
  FutureOr<void> build() async {}

  Future<void> tandaiDibaca({required String key, int id = 0}) async {
    try {
      await ref.read(notifikasiServiceProvider).readNotifikasi(key, id);
    } catch (_) {
      // Gagal menandai tidak boleh menggagalkan UI.
    }
    ref.invalidate(fetchNotifikasiProvider);
    ref.invalidate(fetchNotifikasiUnreadProvider);
  }
}
