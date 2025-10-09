import 'dart:io';

import 'package:dio/dio.dart';
import 'package:syathiby/models/chat/chat.dart';
import 'package:syathiby/models/chat/chat_detail.dart';
import 'package:syathiby/models/message.dart';
import 'package:retrofit/retrofit.dart';

part 'chat_service.g.dart';

@RestApi(baseUrl: 'chat')
abstract class ChatRestInterface {
  factory ChatRestInterface(Dio dio, {String baseUrl}) = _ChatRestInterface;

  @GET('list.php')
  Future<DetailChat> getChat(
    @Query('key') String key,
    @Query('id') String id,
    @Query('type') String type,
    @Query('no_invoice') String noInvoice,
  );

  @GET('posting/data.php')
  Future<List<Chat>> getsPost(
    @Query('key') String key,
  );

  @GET('posting/detaildata.php')
  Future<List<Chat>> detailPost(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('posting/coment.php')
  Future<List<Chat>> getsComent(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('posting/like.php')
  Future<List<Chat>> getLike(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('posting/likecoment.php')
  Future<List<Chat>> getLikeComent(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('posting/report.php')
  Future<List<Chat>> getReport(
    @Query('key') String key,
    @Query('id') String id,
    @Query('report') String report,
  );

  @GET('posting/coment.php')
  Future<List<Chat>> getComent(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('listuser.php')
  Future<DetailChat> getChatUser(
    @Query('key') String key,
    @Query('id') String id,
    @Query('page') int? page,
  );

  @GET('listusergrup.php')
  Future<DetailChat> getChatGrup(
    @Query('key') String key,
    @Query('id') String id,
    @Query('page') int? page,
  );

  @POST('chat.php')
  Future<Message> send(
    @Field('key') String key,
    @Field('detail') String detail,
    @Field('receiver') String receiver,
    @Field('type') String type,
    @Field('no_invoice') String noInvoice,
  );

  @POST('sendchat.php')
  @MultiPart()
  Future<Message> sendChat(
    @Part(name: 'key') String key,
    @Part(name: 'detail') String detail,
    @Part(name: 'receiver') String receiver,
    @Part(name: 'reply') String reply, {
    @Part(name: 'img') File? img,
  });

  @POST('sendchatemoji.php')
  @MultiPart()
  Future<Message> sendChatEmoji(
    @Part(name: 'key') String key,
    @Part(name: 'detail') String detail,
    @Part(name: 'receiver') String receiver, {
    @Part(name: 'img') File? img,
  });

  @POST('sendchatemojigrup.php')
  @MultiPart()
  Future<Message> sendChatEmojiGrup(
    @Part(name: 'key') String key,
    @Part(name: 'detail') String detail,
    @Part(name: 'receiver') String receiver, {
    @Part(name: 'img') File? img,
  });

  @POST('sendchatgrup.php')
  @MultiPart()
  Future<Message> sendChatGruo(
    @Part(name: 'key') String key,
    @Part(name: 'detail') String detail,
    @Part(name: 'position') String receiver,
    @Part(name: 'reply') String reply, {
    @Part(name: 'img') File? img,
  });

  @POST('sendchatloc.php')
  @MultiPart()
  Future<Message> sendChatLocation(
    @Part(name: 'key') String key,
    @Part(name: 'detail') String detail,
    @Part(name: 'receiver') String receiver,
    @Part(name: 'location') String location, {
    @Part(name: 'img') File? img,
  });

  @POST('sendchatlocgrup.php')
  @MultiPart()
  Future<Message> sendChatLocationGrup(
    @Part(name: 'key') String key,
    @Part(name: 'detail') String detail,
    @Part(name: 'position') String position,
    @Part(name: 'location') String location, {
    @Part(name: 'img') File? img,
  });

  @POST('sendchatjob.php')
  @MultiPart()
  Future<Message> sendChatJob(
    @Part(name: 'key') String key,
    @Part(name: 'detail') String detail,
    @Part(name: 'receiver') String receiver,
    @Part(name: 'no_invoice') String noInvoice, {
    @Part(name: 'img') File? img,
  });

  @POST('sendpost.php')
  @MultiPart()
  Future<Message> sendPost(
    @Part(name: 'key') String key,
    @Part(name: 'detail') String detail, {
    @Part(name: 'img') File? img,
  });

  @POST('sendcoment.php')
  @MultiPart()
  Future<Message> sendComent(
    @Part(name: 'key') String key,
    @Part(name: 'detail') String detail,
    @Part(name: 'id') String id, {
    @Part(name: 'img') File? img,
  });
}
