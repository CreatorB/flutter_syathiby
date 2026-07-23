import 'package:flutter/foundation.dart';
import 'web_splash_stub.dart'
    if (dart.library.js_interop) 'web_splash_web.dart' as web_impl;

/// Utility to interact with the web splash screen.
class WebSplashUtility {
  /// Removes the splash screen from the DOM if running on web.
  static void remove() {
    if (kIsWeb) {
      web_impl.removeSplashFromWeb();
    }
  }
}
