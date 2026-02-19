import 'package:geolocator/geolocator.dart';

/// Stub untuk non-web platform. Tidak akan pernah dipanggil.
class WebLocationHelper {
  static Future<Position> getCurrentPosition({
    Duration timeout = const Duration(seconds: 30),
  }) {
    throw UnsupportedError('WebLocationHelper hanya untuk web');
  }
}
