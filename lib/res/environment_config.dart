import 'package:shared_preferences/shared_preferences.dart';
import 'package:syathiby/main.dart'; // To access globalPrefs
import 'package:syathiby/res/env.dart';

class EnvironmentConfig {
  static const String _keyBaseUrl = 'debug_base_url';
  static const String _keyLinkBase = 'debug_link_base';

  static String get baseUrl {
    return globalPrefs?.getString(_keyBaseUrl) ?? Env.baseUrl;
  }

  static String get linkBase {
    return globalPrefs?.getString(_keyLinkBase) ?? Env.linkBase;
  }

  static Future<void> updateConfig({
    required String? baseUrl,
    required String? linkBase,
  }) async {
    if (globalPrefs == null) return;
    
    if (baseUrl != null && baseUrl.isNotEmpty) {
      await globalPrefs!.setString(_keyBaseUrl, baseUrl);
    } else {
      await globalPrefs!.remove(_keyBaseUrl);
    }

    if (linkBase != null && linkBase.isNotEmpty) {
      await globalPrefs!.setString(_keyLinkBase, linkBase);
    } else {
      await globalPrefs!.remove(_keyLinkBase);
    }
  }

  static Future<void> reset() async {
    if (globalPrefs == null) return;
    await globalPrefs!.remove(_keyBaseUrl);
    await globalPrefs!.remove(_keyLinkBase);
  }
}
