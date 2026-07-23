import 'package:envied/envied.dart';

part 'env.g.dart';

/// Holds secrets that must remain obfuscated in the binary.
/// URL configuration is in [FlavorConfig] so it can be switched
/// between local / production at build time via --dart-define.
@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'MAPS_API_KEY', obfuscate: true)
  static final String mapsApiKey = _Env.mapsApiKey;
}

/// Local-only debug helpers (e.g. auto-fill credentials).
/// Reads from `.env.local` so values stay out of production builds.
/// Leave the values blank in `.env.local` to disable auto-fill.
@Envied(path: '.env.local')
abstract class LocalEnv {
  @EnviedField(varName: 'TEST_PHONE', defaultValue: '')
  static const String testPhone = _LocalEnv.testPhone;

  @EnviedField(varName: 'TEST_PASSWORD', defaultValue: '')
  static const String testPassword = _LocalEnv.testPassword;
}