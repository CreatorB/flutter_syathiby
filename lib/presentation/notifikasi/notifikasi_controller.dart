import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:syathiby/models/notifikasi/notifikasi.dart';
import 'package:syathiby/models/service_injection.dart';

part 'notifikasi_controller.g.dart';

/// Keadaan daftar notifikasi (dipaginasi).
///
/// Dipakai sebagai state agar setiap perubahan memicu rebuild widget yang
/// berbeda -- bukan menyimpan daftar di dalam notifier.
class NotifikasiListState {
  const NotifikasiListState({
    this.items = const <Notifikasi>[],
    this.page = 1,
    this.hasMore = true,
    this.loading = false,
  });

  final List<Notifikasi> items;
  final int page;
  final bool hasMore;
  final bool loading;

  int get unread => items.where((n) => (n.status ?? 'baru') == 'baru').length;

  NotifikasiListState copyWith({
    List<Notifikasi>? items,
    int? page,
    bool? hasMore,
    bool? loading,
  }) {
    return NotifikasiListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loading: loading ?? this.loading,
    );
  }
}

/// Daftar notifikasi staff dengan pagination (muat halaman berikutnya saat
/// layar di-scroll ke bawah).
@riverpod
class NotifikasiList extends _$NotifikasiList {
  static const int perHalaman = 20;

  @override
  NotifikasiListState build() => const NotifikasiListState();

  /// Muat ulang dari awal (tarik ke bawah).
  Future<void> muatAwal(String key) async {
    if (key.isEmpty || key == 'null') return;
    state = state.copyWith(loading: true);
    try {
      final data = await ref
          .read(notifikasiServiceProvider)
          .getNotifikasi(key, 1);
      state = NotifikasiListState(
        items: data,
        page: 1,
        hasMore: data.length >= perHalaman,
        loading: false,
      );
    } catch (e) {
      debugPrint('Gagal memuat daftar notifikasi: $e');
      state = state.copyWith(loading: false);
    }
  }

  /// Muat halaman berikutnya (dipanggil saat nearing akhir daftar).
  Future<void> muatLagi(String key) async {
    if (key.isEmpty || key == 'null') return;
    if (state.loading || !state.hasMore) return;
    final next = state.page + 1;
    state = state.copyWith(loading: true);
    try {
      final data = await ref
          .read(notifikasiServiceProvider)
          .getNotifikasi(key, next);
      state = state.copyWith(
        items: [...state.items, ...data],
        page: next,
        hasMore: data.length >= perHalaman,
        loading: false,
      );
    } catch (e) {
      debugPrint('Gagal memuat halaman notifikasi berikutnya: $e');
      state = state.copyWith(loading: false);
    }
  }

  /// Tandai semua notifikasi di daftar sebagai terbaca (perubahan lokal).
  void tandaiSemuaTerbacaDiDaftar() {
    if (state.items.isEmpty) return;
    final baru = state.items
        .map(
          (n) => (n.status ?? 'baru') == 'dibaca'
              ? n
              : n.copyWith(status: 'dibaca', readAt: DateTime.now().toString()),
        )
        .toList();
    state = state.copyWith(items: baru);
  }

  /// Tandai satu notifikasi terbaca di daftar (tanpa menambah ulang).
  void tandaiTerbacaDiDaftar(int id) {
    if (state.items.isEmpty) return;
    var adaUbah = false;
    final baru = state.items.map((n) {
      if ((n.id ?? 0) == id && (n.status ?? 'baru') != 'dibaca') {
        adaUbah = true;
        return n.copyWith(status: 'dibaca', readAt: DateTime.now().toString());
      }
      return n;
    }).toList();
    if (adaUbah) {
      state = state.copyWith(items: baru);
    }
  }
}

/// Detail satu notifikasi.
@riverpod
Future<Notifikasi> fetchNotifikasiDetail(
  FetchNotifikasiDetailRef ref, {
  required String key,
  required int id,
}) async {
  if (key.isEmpty || key == 'null' || id <= 0) {
    return const Notifikasi();
  }
  return ref.watch(notifikasiServiceProvider).getNotifikasiDetail(key, id);
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
    // PENTING: provider daftar (notifikasiListProvider) TIDAK boleh di-invalidate
    // di sini. Provider itu auto-dispose: invalidate akan membuatnya di-create
    // ulang dengan state KOSONG, jadi daftar yang barusan di-load lenyap dan
    // layar tampil "Belum ada notifikasi" padahal server sudah mengirim data.
    // Daftar diperbarui secara lokal (tandaiTerbacaDiDaftar); yang perlu
    // disegarkan hanya jumlah belum dibaca untuk badge lonceng.
    ref.invalidate(fetchNotifikasiUnreadProvider);
  }
}
