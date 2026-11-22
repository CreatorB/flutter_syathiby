// Self-heal bundle web (lihat `web_bundle_refresh_web.dart`).
//
// Implementasi web memakai `dart:js_interop` yang hanya tersedia di build
// web, jadi di Android/iOS dipakai versi stub yang tidak melakukan apa-apa.
export 'web_bundle_refresh_stub.dart'
    if (dart.library.js_interop) 'web_bundle_refresh_web.dart';
