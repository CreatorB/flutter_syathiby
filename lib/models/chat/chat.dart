import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
class Chat with _$Chat {
  const factory Chat({
    String? id,
    String? name,
    String? detail,
    String? img,
    String? detail_images,
    String? date,
    String? status,
    String? like,
    String? coment,
    int? mylike,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
}
