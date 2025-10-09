import 'dart:math' show pi, atan2, sin, cos, log, tan;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/generated/assets.dart'; 

final qiblaDirectionProvider = StreamProvider.autoDispose<double>((ref) async* {

  final locationPermission = await Geolocator.checkPermission();
  if (locationPermission == LocationPermission.denied ||
      locationPermission == LocationPermission.deniedForever) {
    final permissionStatus = await Geolocator.requestPermission();
    if (permissionStatus != LocationPermission.whileInUse &&
        permissionStatus != LocationPermission.always) {
      throw Exception('Izin lokasi ditolak untuk mengakses arah kiblat.');
    }
  }

  final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium);

  final bearing = _calculateBearing(position.latitude, position.longitude);

  await for (final event in FlutterCompass.events!) {
    final heading = event.heading;
    if (heading != null) {

      final qiblaDirectionInDegrees = bearing - heading;
      yield _toRadians(qiblaDirectionInDegrees); 
    }
  }
});

const double _kaabaLatitude = 21.4224779;
const double _kaabaLongitude = 39.8251832;

double _calculateBearing(double startLat, double startLng) {
  startLat = _toRadians(startLat);
  startLng = _toRadians(startLng);
  double endLat = _toRadians(_kaabaLatitude);
  double endLng = _toRadians(_kaabaLongitude);

  double dLng = endLng - startLng;
  double dPhi =
      log(tan(endLat / 2.0 + pi / 4.0) / tan(startLat / 2.0 + pi / 4.0));

  if (dLng.abs() > pi) {
    dLng = dLng > 0.0 ? -(2.0 * pi - dLng) : (2.0 * pi + dLng);
  }

  return (_toDegrees(atan2(dLng, dPhi)) + 360.0) % 360.0;
}

double _toRadians(double degree) => degree * pi / 180.0;
double _toDegrees(double radian) => radian * 180.0 / pi;

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaDirectionAsync = ref.watch(qiblaDirectionProvider);
    final needleSvg = SvgPicture.asset(
      Assets.imagesNeedle, 
      fit: BoxFit.contain,
      height: 300,
      alignment: Alignment.center,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arah Kiblat'),
      ),
      body: Center(
        child: qiblaDirectionAsync.when(
          data: (direction) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[

                SvgPicture.asset(Assets.imagesCompass), 

                Transform.rotate(
                  angle: direction,
                  alignment: Alignment.center,
                  child: needleSvg,
                ),
              ],
            );
          },
          loading: () => const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Mencari lokasi dan arah...'),
            ],
          ),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error: ${error.toString()}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}