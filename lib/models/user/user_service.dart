import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/slip/absent.dart';
import 'package:syathiby/models/user/login.dart';
import 'package:syathiby/models/user/request_logout.dart';
import 'package:syathiby/models/user/user.dart';
import 'package:retrofit/retrofit.dart';

part 'user_service.g.dart';

@RestApi()
abstract class UserService {
  factory UserService(Dio dio, {String baseUrl}) = _UserService;

  @GET('profile/dataaccount.php')
  Future<List<User>> getProfile(@Query('key') String key);

  @POST('profile/gettoken.php')
  Future<User> getToken(@Body() RequestLogout requestLogout);

  @POST('profile/logout.php')
  Future<Absent> getLogout(@Body() RequestLogout requestLogout);

  @MultiPart()
  @POST('attendance/registerfoto.php')
  Future<Absent> registerPhoto(
    @Part(name: 'key') String key,
    @Part(name: 'img') File file,
  );

  @MultiPart()
  @POST('attendance/presence.php')
  Future<Absent> presence(
    @Part(name: 'key') String key,
    @Part(name: 'latitude') double latitude,
    @Part(name: 'longitude') double longitude,
    @Part(name: 'mock') bool mock,
    @Part(name: 'type') String type, {
    @Part(name: 'img') File? file,
  });

  @MultiPart()
  @POST('attendance/presencenormal.php')
  Future<Absent> presenceNormal(
    @Part(name: 'key') String key,
    @Part(name: 'latitude') double latitude,
    @Part(name: 'longitude') double longitude,
    @Part(name: 'mock') bool mock,
    @Part(name: 'type') String type, {
    @Part(name: 'img') File? file,
  });

  @MultiPart()
  @POST('attendance/presencefinger.php')
  Future<Absent> presenceFinger(
    @Part(name: 'key') String key,
    @Part(name: 'latitude') double latitude,
    @Part(name: 'longitude') double longitude,
    @Part(name: 'mock') bool mock,
    @Part(name: 'type') String type,
    @Part(name: 'token') String token, {
    @Part(name: 'img') File? file,
  });

  @MultiPart()
  @POST('attendance/regfinger.php')
  Future<Absent> registerFinger(
    @Part(name: 'key') String key,
    @Part(name: 'token') String token,
  );

  @MultiPart()
  @POST('attendance/reason.php')
  Future<Absent> reason(
    @Part(name: 'key') String key,
    @Part(name: 'alasan') String reason,
  );

  @MultiPart()
  @POST('attendance/reasonfinish.php')
  Future<Absent> reasonOut(
    @Part(name: 'key') String key,
    @Part(name: 'alasan') String reason,
  );

  @MultiPart()
  @POST('settings/updateaccount.php')
  Future<Message> updateProfile(
    @Part(name: 'key') String key,
    @Part(name: 'full_name') String fullName,
    @Part(name: 'email') String email,
    @Part(name: 'phone_number') String phoneNumber,
    @Part(name: 'address') String address, {
    @Part(name: 'img') File? file,
  });

  @POST('settings/updatepassword.php')
  @FormUrlEncoded()
  Future<Message> changePassword(
    @Field('key') String key,
    @Field('old_password') String oldPassword,
    @Field('new_password') String newPassword,
  );

  @POST('profile/login.php')
  @FormUrlEncoded()
  Future<List<Login>> login(
    @Field('user') String phoneNumber,
    @Field('password') String password,
  );

  @POST('profile/signup.php')
  @FormUrlEncoded()
  Future<Message> register(
    @Field('name_store') String nameStore,
    @Field('currency') String currency,
    @Field('full_name') String fullName,
    @Field('email') String email,
    @Field('phone_number') String phoneNumber,
    @Field('password') String password,
    @Field('address') String address,
    @Field('referal') String referal,
    @Field('typestore') String typeStore,
    @Field('decimal') String decimal,
  );

  @POST('profile/forgetpassword.php')
  @FormUrlEncoded()
  Future<Message> forgotPassword(
    @Field('email') String email,
    @Field('user') String phoneNumber,
  );

  @GET('profile/datauser.php')
  Future<List<User>> getProfileUser(
    @Query('key') String key,
  );
}
