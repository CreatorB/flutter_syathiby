import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/message.dart';
import '../../models/place/tempat.dart';

part 'place_controller.g.dart';

@riverpod
class PlacesController extends _$PlacesController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addPlace({
    required String key,
    required String name,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(placeServiceProvider).add(key, name),
    );
    state = result;

    return result.valueOrNull;
  }

  Future<Message?> updatePlace({
    required String key,
    required String placeId,
    required String name,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(placeServiceProvider).update(key, placeId, name),
    );
    state = result;

    return result.valueOrNull;
  }
}

@riverpod
Future<List<Tempat>> fetchAllPlace(
  FetchAllPlaceRef ref, {
  required String key,
  required String id,
}) async {
  final result = ref.watch(placeServiceProvider).getGedung(key, id);
  return result;
}
