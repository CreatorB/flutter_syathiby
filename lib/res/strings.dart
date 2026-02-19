import 'package:syathiby/res/env.dart';
import 'package:syathiby/res/environment_config.dart';

abstract class AppConstant {
  //    rename setAppName --targets ios,android --value "Syathiby"
  static const String appName = 'Syathiby';
  static const String youtubeChannelName = 'Syathiby';
  static String get teachingPlannerUrl => '${EnvironmentConfig.linkBase}/rpp/';
  static const String keyLoginSession = 'login_session';
  static const String keyUserSession = 'user_session';
  static const String keyDeviceToken = 'device_token';
  static const String keyMurottalSurahSelected = 'murottal_surah_selected';
  static const String keyMurottalAyahSelected = 'murottal_ayah_selected';
  static const String keyLastReadAyah = 'last_read_ayah';
  static const String keybookmarkAyah = 'bookmark_ayah';
  // URL
  static String get storeUrl => '${EnvironmentConfig.baseUrl}store/';
  static String get aboutUrl => '${EnvironmentConfig.baseUrl}pages/about.php';
  static String get termUrl => '${EnvironmentConfig.baseUrl}pages/term.php';
  static String get privacyUrl => '${EnvironmentConfig.baseUrl}pages/privacy.php';
  static String get premiumUrl => '${EnvironmentConfig.baseUrl}pages/premium.php?key=';
  static String get newsUrl => '${EnvironmentConfig.baseUrl}pages/news.php';
  static const String qiblaFinderUrl =
      'https://qiblafinder.withgoogle.com/intl/id/onboarding';

}
