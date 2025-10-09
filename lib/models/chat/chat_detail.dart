import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_detail.freezed.dart';
part 'chat_detail.g.dart';

@freezed
class DetailChat with _$DetailChat {
  const factory DetailChat({
    Info? info,
    List<Data>? data,
  }) = _DetailChat;

  factory DetailChat.fromJson(Map<String, dynamic> json) =>
      _$DetailChatFromJson(json);
}

@freezed
class Info with _$Info {
  const factory Info({
    String? id,
    String? name,
    @Default("") String? detail,
    @Default("0") String date,
    @Default("0") String? status,
    String? chat,
    String? no_invoice,
  }) = _Info;

  factory Info.fromJson(Map<String, dynamic> json) => _$InfoFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({
    String? id,
    String? name,
    String? phone_number,
    String? detail,
    String? date,
    String? status,
    String? chat,
    String? img,
    String? no_invoice,
    String? read,
    String? chat_images,
    String? photo,
    String? active,
    String? emoji,
    String? location,
    String? peserta,
    String? position,
    String? reply,
    String? chat_reply,
    String? user_reply,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
