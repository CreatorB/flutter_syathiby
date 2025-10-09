import 'package:syathiby/models/prayer/time/prayer_time.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'prayer_controller.g.dart';

@riverpod
Future<PrayerTime?> fetchPrayerTime(
  FetchPrayerTimeRef ref, {
  double? latitude,
  double? longitude,
}) async {
  if (latitude == null || longitude == null) return null;
  return await ref
      .watch(prayerTimeServiceProvider)
      .getPrayerTime(latitude, longitude);
}
