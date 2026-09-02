import 'dart:js_interop';
import 'package:web/web.dart' as web;

@JS('removeSplashFromWeb')
external void _removeSplash();

/// Web implementation for removing the splash screen.
void removeSplashFromWeb() {
  // 1. Try direct JS call
  try {
    _removeSplash();
  } catch (e) {
    // Ignore direct call failure
  }

  // 2. Try event dispatch (often more reliable in modern web interop)
  try {
    web.window.dispatchEvent(web.Event('remove-splash'));
  } catch (e) {
    // Ignore event failure
  }
}
