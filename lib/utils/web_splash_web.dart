import 'dart:js_interop';

@JS('removeSplashFromWeb')
external void _removeSplash();

/// Web implementation for removing the splash screen.
void removeSplashFromWeb() {
  try {
    _removeSplash();
  } catch (e) {
    // Fallback or ignore if not found
  }
}
