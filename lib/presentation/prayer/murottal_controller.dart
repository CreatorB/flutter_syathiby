import 'dart:convert';

import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/prayer/murottal/murottal.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/res/strings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'murottal_controller.g.dart';

@riverpod
Future<List<Murottal>> fetchMurottalSurah(FetchMurottalSurahRef ref) async {
  final result = await ref.watch(murottalServiceProvider).getMurottalAudio();
  List<dynamic> json = jsonDecode(result);
  final murottal = json.map((e) => Murottal.fromJson(e)).toList();
  final audioSurah =
      murottal.where((element) => element.type == 'surah').toList();
  return audioSurah;
}

@riverpod
Future<List<Murottal>> fetchMurottalAyah(FetchMurottalSurahRef ref) async {
  final result = await ref.watch(murottalServiceProvider).getMurottalAudio();
  List<dynamic> json = jsonDecode(result);
  final murottal = json.map((e) => Murottal.fromJson(e)).toList();
  final audioAyah =
      murottal.where((element) => element.type == 'ayah').toList();
  return audioAyah;
}

@riverpod
Future<void> saveMurottalAyahSelected(
  SaveMurottalAyahSelectedRef ref,
  Murottal murottal,
) async {
  ref
      .watch(sharedPreferencesHelperProvider)
      .setObject(AppConstant.keyMurottalAyahSelected, jsonEncode(murottal));
}

@riverpod
Future<Murottal?> getMurottalAyahSelected(
  GetMurottalAyahSelectedRef ref,
) async {
  final json = ref
      .watch(sharedPreferencesHelperProvider)
      .getObject<String>(AppConstant.keyMurottalAyahSelected);
  if (json == null) return null;
  return Murottal.fromJson(jsonDecode(json));
}

@riverpod
Future<List<Murottal>> fetchMurottalEveryAyah(
  FetchMurottalEveryAyahRef ref,
) async {
  final result = await ref.watch(murottalServiceProvider).getMurottalAudio();
  List<dynamic> json = jsonDecode(result);
  final murottal = json.map((e) => Murottal.fromJson(e)).toList();
  final audioEveryAyah =
      murottal.where((element) => element.type == 'ayah').toList();
  return audioEveryAyah;
}

@riverpod
Future<void> saveMurottalSelected(
  SaveMurottalSelectedRef ref,
  Murottal murottal,
) async {
  ref
      .watch(sharedPreferencesHelperProvider)
      .setObject(AppConstant.keyMurottalSurahSelected, jsonEncode(murottal));
}

@riverpod
Future<Murottal?> getMurottalSelected(GetMurottalSelectedRef ref) async {
  final json = ref
      .watch(sharedPreferencesHelperProvider)
      .getObject<String>(AppConstant.keyMurottalSurahSelected);
  if (json == null) return null;
  return Murottal.fromJson(jsonDecode(json));
}
