import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:syathiby/models/notifikasi/notifikasi.dart';
import 'package:syathiby/models/service_injection.dart';

part 'notifikasi_controller.g.dart';

/// Satu blok notifikasi: satu MINGGU (server yang menentukan batasnya).
class BlokMinggu {
  const BlokMinggu({
    required this.week,
    required this.label,
    required this.items,
  });

  final int week;
  final String label;
  final List<Notifikasi> items;
}

/// Keadaan daftar notifikasi (dimuat per minggu).
///
/// Dipakai sebagai state agar setiap perubahan memicu rebuild widget yang
/// berbeda -- bukan menyimpan daftar di dalam notifier.
class NotifikasiListState {
  const NotifikasiListState({
    this.blok = const <BlokMinggu>[],
    this.adaLagi = true,
    this.loading = false,
    this.unread = 0,
    this.total = 0,
  });

  /// Notifikasi yang sudah dimuat, dikelompokkan per minggu.
  final List<BlokMinggu> blok;

  /// Masih ada minggu yang lebih lama belum dimuat?
  final bool adaLagi;
  final bool loading;

  /// Jumlah belum dibaca (dari server, bukan dihitung dari daftar yang
  /// sudah dimuat -- daftar hanya berisi sebagian minggu).
  final int unread;

  /// Jumlah seluruh notifikasi.
  final int total;

  int get jumlahItem =>
      blok.fold(0, (total, b) => total + b.items.length);

  NotifikasiListState copyWith({
    List<BlokMinggu>? blok,
    bool? adaLagi,
    bool? loading,
    int? unread,
    int? total,
  }) {
    return NotifikasiListState(
      blok: blok ?? this.blok,
      adaLagi: adaLagi ?? this.adaLagi,
      loading: loading ?? this.loading,
      unread: unread ?? this.unread,
      total: total ?? this.total,
    );
  }
}

/// Daftar notifikasi staff dengan pagination per MINGGU.
///
/// Minggu berikutnya dimuat saat layar di-scroll ke bawah. Judul minggu
/// ("Pekan ini", "Pekan lalu") dikirim server, jadi daftar di aplikasi dan
/// di panel web selalu menunjukkan batas minggu yang sama.
@riverpod
class NotifikasiList extends _$NotifikasiList {
  @override
  NotifikasiListState build() => const NotifikasiListState();

  /// Muat ulang dari awal (tarik ke bawah).
  Future<void> muatAwal(String key) async {
    if (key.isEmpty || key == 'null') return;
    state = state.copyWith(loading: true);
    try {
      final hasil = await ref
          .read(notifikasiServiceProvider)
          .getNotifikasi(key, 0);
      final items = hasil.notifikasi ?? const <Notifikasi>[];
      state = NotifikasiListState(
        blok: <BlokMinggu>[
          BlokMinggu(
            week: hasil.week ?? 0,
            label: hasil.label ?? 'Pekan ini',
            items: items,
          ),
        ],
        adaLagi: hasil.adaLagi ?? false,
        loading: false,
        unread: hasil.unread ?? 0,
        total: hasil.total ?? 0,
      );
    } catch (e) {
      debugPrint('Gagal memuat daftar notifikasi: $e');
      state = state.copyWith(loading: false);
    }
  }

  /// Muat minggu berikutnya (dipanggil saat nearing akhir daftar).
  Future<void> muatMingguBerikutnya(String key) async {
    if (key.isEmpty || key == 'null') return;
    if (state.loading || !state.adaLagi) return;
    final next = (state.blok.isEmpty ? 0 : state.blok.last.week) + 1;
    state = state.copyWith(loading: true);
    try {
      final hasil = await ref
          .read(notifikasiServiceProvider)
          .getNotifikasi(key, next);
      final items = hasil.notifikasi ?? const <Notifikasi>[];
      final blok = <BlokMinggu>[
        ...state.blok,
        BlokMinggu(
          week: hasil.week ?? next,
          label: hasil.label ?? 'Minggu ${hasil.week ?? next}',
          items: items,
        ),
      ];
      state = state.copyWith(
        blok: blok,
        adaLagi: hasil.adaLagi ?? false,
        loading: false,
        unread: hasil.unread ?? state.unread,
        total: hasil.total ?? state.total,
      );
    } catch (e) {
      debugPrint('Gagal memuat minggu notifikasi berikutnya: $e');
      state = state.copyWith(loading: false);
    }
  }

  /// Tandai semua notifikasi di daftar sebagai terbaca (perubahan lokal).
  void tandaiSemuaTerbacaDiDaftar() {
    if (state.blok.isEmpty) return;
    final blok = state.blok.map((b) {
      return BlokMinggu(
        week: b.week,
        label: b.label,
        items: b.items
            .map(
              (n) => (n.status ?? 'baru') == 'dibaca'
                  ? n
                  : n.copyWith(
                      status: 'dibaca',
                      readAt: DateTime.now().toString(),
                    ),
            )
            .toList(),
      );
    }).toList();
    state = state.copyWith(blok: blok, unread: 0);
  }

  /// Tandai satu notifikasi terbaca di daftar (tanpa menambah ulang).
  void tandaiTerbacaDiDaftar(int id) {
    if (state.blok.isEmpty) return;
    var adaUbah = false;
    var belumTersisa = 0;
    final blok = state.blok.map((b) {
      final items = b.items.map((n) {
        if ((n.id ?? 0) == id && (n.status ?? 'baru') != 'dibaca') {
          adaUbah = true;
          return n.copyWith(status: 'dibaca', readAt: DateTime.now().toString());
        }
        return n;
      }).toList();
      belumTersisa += items.where((n) => (n.status ?? 'baru') == 'baru').length;
      return BlokMinggu(week: b.week, label: b.label, items: items);
    }).toList();
    if (adaUbah) {
      state = state.copyWith(blok: blok, unread: belumTersisa);
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
