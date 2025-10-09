import 'dart:convert';

import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/prayer/ayah/ayah_response.dart';
import 'package:syathiby/models/prayer/surah/surah.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/presentation/prayer/quran.dart';
import 'package:syathiby/res/strings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quran_controller.g.dart';

@riverpod
Future<List<Surah>> fetchSurahList(FetchSurahListRef ref) async {
  final result = await ref.watch(quranServiceProvider).getSurahList();
  List<dynamic> json = jsonDecode(result);
  final surahList = json.map((e) => Surah.fromJson(e)).toList();
  return surahList;
}

@riverpod
Future<AyahResponse> fetchAyahList(
  FetchAyahListRef ref, {
  required int surahNumber,
}) async {
  return await ref.watch(quranServiceProvider).getAyahList(surahNumber);
}

@riverpod
Future<Quran?> getLastReadQuran(GetLastReadQuranRef ref) async {
  final json = ref
      .watch(sharedPreferencesHelperProvider)
      .getObject<Map<String, dynamic>>(AppConstant.keyLastReadAyah);
  if (json == null) return null;
  final result = Quran.fromJson(json);
  return result;
}

@riverpod
Future<Quran?> getBookmarkQuran(GetBookmarkQuranRef ref) async {
  final json = ref
      .watch(sharedPreferencesHelperProvider)
      .getObject<Map<String, dynamic>>(AppConstant.keybookmarkAyah);
  if (json == null) return null;
  final result = Quran.fromJson(json);
  return result;
}

@riverpod
Future<void> saveLastReadQuran(SaveLastReadQuranRef ref,
    {required Quran quran}) async {
  await ref
      .watch(sharedPreferencesHelperProvider)
      .setObject(AppConstant.keyLastReadAyah, quran.toJson());
  ref.invalidate(getLastReadQuranProvider);
}

@riverpod
Future<void> saveBookmarkQuran(SaveBookmarkQuranRef ref,
    {required Quran quran}) async {
  await ref
      .watch(sharedPreferencesHelperProvider)
      .setObject(AppConstant.keybookmarkAyah, quran.toJson());

  ref.invalidate(getBookmarkQuranProvider);
}
