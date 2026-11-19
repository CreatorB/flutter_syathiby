import 'package:freezed_annotation/freezed_annotation.dart';

part 'notifikasi.freezed.dart';
part 'notifikasi.g.dart';

/// Satu notifikasi di kotak masuk staff.
///
/// Datanya dibaca dari tabel `notifikasi` (migration 051). Backend juga
/// mengirim push FCM untuk notifikasi yang sama -- push memberi tahu
/// seketika, kotak masuk memastikan tidak ada yang terlewat (token push bisa
/// hilang, dan browser sering tidak punya izin notifikasi).
@freezed
class Notifikasi with _$Notifikasi {
  const factory Notifikasi({
    int? id,
    String? judul,
    String? pesan,
    String? source,
    @JsonKey(name: 'ref_id') String? refId,
    String? status,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'read_at') String? readAt,
  }) = _Notifikasi;

  factory Notifikasi.fromJson(Map<String, dynamic> json) =>
      _$NotifikasiFromJson(json);
}

/// Jumlah notifikasi yang belum dibaca (untuk badge lonceng).
@freezed
class NotifikasiUnread with _$NotifikasiUnread {
  const factory NotifikasiUnread({
    int? unread,
  }) = _NotifikasiUnread;

  factory NotifikasiUnread.fromJson(Map<String, dynamic> json) =>
      _$NotifikasiUnreadFromJson(json);
}
