import 'dart:math' show pi, atan2, sin, cos, log, tan; 
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final qiblaDirectionProvider = StreamProvider<double>((ref) async* {

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

class QiblaCompassScreen extends ConsumerWidget {
  const QiblaCompassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final qiblaDirectionAsync = ref.watch(qiblaDirectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arah Kiblat'),
      ),
      body: Center(
        child: qiblaDirectionAsync.when(

          data: (direction) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(_toDegrees(direction) % 360).toStringAsFixed(0)}°',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),

                Transform.rotate(
                  angle: direction,
                  child: Image.asset(
                    'assets/images/qibla_compass.png', 
                    width: 250,
                    height: 250,
                  ),
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