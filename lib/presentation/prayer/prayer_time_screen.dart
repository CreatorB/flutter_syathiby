import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/prayer/prayer_controller.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PrayerTimeSelected {
  final String prayerName;
  final String prayerTime;
  final String date;
  final Duration duration;

  PrayerTimeSelected(
    this.prayerName,
    this.prayerTime,
    this.duration,
    this.date,
  );
}

class PrayerTimeScreen extends HookConsumerWidget {
  const PrayerTimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPosition = ref.watch(getCurrentLocationProvider);
    final fetchPrayerTime = ref.watch(
      fetchPrayerTimeProvider(
        latitude: currentPosition.valueOrNull?.latitude,
        longitude: currentPosition.valueOrNull?.longitude,
      ),
    );
    final cityName = useMemoized(
        () => getCityName(currentPosition.valueOrNull), [currentPosition]);
    final currentCityName = useFuture(cityName);
    final prayerTimeSelected = useState<PrayerTimeSelected?>(null);

    Timer? startCountdown() {
      final prayerTime = fetchPrayerTime.valueOrNull;
      if (prayerTime == null || !context.mounted) return null;
      final time = prayerTime.times.first;
      final parseTime = DateFormat('HH:mm').parse(time.fajr);
      final tomorrowDateTime = DateTime.now()
          .add(const Duration(
            days: 1,
          ))
          .copyWith(
            hour: parseTime.hour,
            minute: parseTime.minute,
            second: 0,
          );
      final tomorrowDateFormat =
          DateFormat('yyyy-MM-dd').format(tomorrowDateTime);
      final timerCount = Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) {
          // final imsakDiff = getDiffPrayerTime(time.gregorian, time.imsak);
          final fajrDiff = getDiffPrayerTime(time.gregorian, time.fajr);
          final tomorrowFajrDiff =
              getDiffPrayerTime(tomorrowDateFormat, time.fajr);
          final sunsetDiff = getDiffPrayerTime(time.gregorian, time.sunset);
          final dhuhaDiff = getDiffPrayerTime(time.gregorian, time.dhuha);
          final dhuhrDiff = getDiffPrayerTime(time.gregorian, time.dhuhr);
          final asrDiff = getDiffPrayerTime(time.gregorian, time.asr);
          final maghribDiff = getDiffPrayerTime(time.gregorian, time.maghrib);
          final ishaDiff = getDiffPrayerTime(time.gregorian, time.isha);
          if (fajrDiff.inSeconds > 0) {
            prayerTimeSelected.value = PrayerTimeSelected(
                'Shubuh', time.fajr, fajrDiff, time.gregorian);
          } else if (sunsetDiff.inSeconds > 0) {
            prayerTimeSelected.value = PrayerTimeSelected(
                'Terbit', time.sunset, sunsetDiff, time.gregorian);
          } else if (dhuhaDiff.inSeconds > 0) {
            prayerTimeSelected.value = PrayerTimeSelected(
                'Dhuha', time.dhuha, dhuhaDiff, time.gregorian);
          } else if (dhuhrDiff.inSeconds > 0) {
            prayerTimeSelected.value = PrayerTimeSelected(
                'Dzuhur', time.dhuhr, dhuhrDiff, time.gregorian);
          } else if (asrDiff.inSeconds > 0) {
            prayerTimeSelected.value =
                PrayerTimeSelected('Ashar', time.asr, asrDiff, time.gregorian);
          } else if (maghribDiff.inSeconds > 0) {
            prayerTimeSelected.value = PrayerTimeSelected(
                'Maghrib', time.maghrib, maghribDiff, time.gregorian);
          } else if (ishaDiff.inSeconds > 0) {
            prayerTimeSelected.value =
                PrayerTimeSelected('Isya', time.isha, ishaDiff, time.gregorian);
          } else if (tomorrowFajrDiff.inSeconds > 0) {
            prayerTimeSelected.value = PrayerTimeSelected(
              'Shubuh',
              time.fajr,
              tomorrowFajrDiff,
              time.gregorian,
            );
          }
        },
      );
      return timerCount;
    }

    useEffect(
      () {
        final timer = startCountdown();
        return timer?.cancel;
      },
      [fetchPrayerTime],
    );

    return Skeletonizer(
      enabled: fetchPrayerTime.isLoading || prayerTimeSelected.value == null,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${fetchPrayerTime.valueOrNull?.city}',
                style: context.titleMedium,
              ),
              Text(
                '${fetchPrayerTime.valueOrNull?.province}',
                style: context.titleSmall,
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.refresh(
            fetchPrayerTimeProvider(
              latitude: currentPosition.valueOrNull?.latitude,
              longitude: currentPosition.valueOrNull?.longitude,
            ).future,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Center(
                  child: Text(
                    '${prayerTimeSelected.value?.prayerName}',
                    style: context.titleLargeBold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Center(
                  child: Text(
                    '${prayerTimeSelected.value?.prayerTime}',
                    style: context.headlineLargeBold,
                  ),
                ),
                Center(
                  child: Text(
                    '${getDurationFormat(prayerTimeSelected.value?.duration)}',
                    style: context.titleMedium,
                  ),
                ),
                const SizedBox(height: 8.0),
                Center(
                  child: Text(
                    '${currentCityName.data}',
                    style: context.titleMedium,
                  ),
                ),
                const SizedBox(height: 32.0),
                Center(
                  child: Text(
                    '${getFullDateName(prayerTimeSelected.value?.date)}',
                    style: context.titleMediumBold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Center(
                  child: Text(
                    '${getFullDateHijri(prayerTimeSelected.value?.date)}',
                    style: context.titleSmall,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Divider(),
                const SizedBox(height: 4.0),
                ListTile(
                  title: const Text('Shubuh'),
                  visualDensity:
                      const VisualDensity(horizontal: 0, vertical: -2),
                  trailing: Text(
                    '${fetchPrayerTime.valueOrNull?.times.firstOrNull?.fajr}',
                    style: context.bodyLargeBold,
                  ),
                ),
                ListTile(
                  title: const Text('Dhuha'),
                  visualDensity:
                      const VisualDensity(horizontal: 0, vertical: -2),
                  trailing: Text(
                    '${fetchPrayerTime.valueOrNull?.times.firstOrNull?.dhuha}',
                    style: context.bodyLargeBold,
                  ),
                ),
                ListTile(
                  title: const Text('Dzuhur'),
                  visualDensity:
                      const VisualDensity(horizontal: 0, vertical: -2),
                  trailing: Text(
                    '${fetchPrayerTime.valueOrNull?.times.firstOrNull?.dhuhr}',
                    style: context.bodyLargeBold,
                  ),
                ),
                ListTile(
                  title: const Text('Ashar'),
                  visualDensity:
                      const VisualDensity(horizontal: 0, vertical: -2),
                  trailing: Text(
                    '${fetchPrayerTime.valueOrNull?.times.firstOrNull?.asr}',
                    style: context.bodyLargeBold,
                  ),
                ),
                ListTile(
                  title: const Text('Maghrib'),
                  visualDensity:
                      const VisualDensity(horizontal: 0, vertical: -2),
                  trailing: Text(
                    '${fetchPrayerTime.valueOrNull?.times.firstOrNull?.maghrib}',
                    style: context.bodyLargeBold,
                  ),
                ),
                ListTile(
                  visualDensity:
                      const VisualDensity(horizontal: 0, vertical: -2),
                  title: const Text('Isya'),
                  trailing: Text(
                    '${fetchPrayerTime.valueOrNull?.times.firstOrNull?.isha}',
                    style: context.bodyLargeBold,
                  ),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? getDurationFormat(Duration? duration) {
    if (duration == null) return null;
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    if (minutes < 1) {
      return '(-$seconds)';
    }
    if (hours < 1) {
      return '(-$minutes:$seconds)';
    }
    return '(-$hours:$minutes:$seconds)';
  }

  String? getFullDateName(String? date) {
    if (date == null) return null;
    final parseDate = DateFormat('yyyy-MM-dd').parse(date);
    final formatted = DateFormat('EEEE, d MMMM yyyy').format(parseDate);
    return formatted;
  }

  String? getFullDateHijri(String? date) {
    if (date == null) return null;
    final parseDate = DateFormat('yyyy-MM-dd').parse(date);
    var hijriDate = HijriCalendar.fromDate(parseDate);
    return hijriDate.toFormat('d MMMM yyyy');
  }

  Future<String?> getCityName(Position? position) async {
    if (position == null) return null;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      debugPrint('CITYNAME: $placemarks');
      return placemarks.firstOrNull?.subLocality;
    } catch (err) {
      return null;
    }
  }

  Duration getDiffPrayerTime(String date, String time) {
    final currentDate = DateTime.now();
    final parseDate = DateFormat('yyyy-MM-dd').parse(date);
    final parseTime = DateFormat('HH:mm').parse(time);
    final prayerTime = parseDate.copyWith(
      hour: parseTime.hour,
      minute: parseTime.minute,
      second: 0,
    );
    final diff = prayerTime.difference(currentDate);
    return diff;
  }
}
