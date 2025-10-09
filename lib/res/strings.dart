import 'package:syathiby/res/env.dart';

abstract class AppConstant {
  //    rename setAppName --targets ios,android --value "Syathiby"
  static const String appName = 'Syathiby';
  static const String youtubeChannelName = 'Syathiby';
  static const String teachingPlannerUrl = '${Env.linkBase}/rpp/';
  static const String keyLoginSession = 'login_session';
  static const String keyUserSession = 'user_session';
  static const String keyDeviceToken = 'device_token';
  static const String keyMurottalSurahSelected = 'murottal_surah_selected';
  static const String keyMurottalAyahSelected = 'murottal_ayah_selected';
  static const String keyLastReadAyah = 'last_read_ayah';
  static const String keybookmarkAyah = 'bookmark_ayah';
  // URL
  static const String storeUrl = '${Env.baseUrl}store/';
  static const String aboutUrl = '${Env.baseUrl}pages/about.php';
  static const String termUrl = '${Env.baseUrl}pages/term.php';
  static const String privacyUrl = '${Env.baseUrl}pages/privacy.php';
  static const String premiumUrl = '${Env.baseUrl}pages/premium.php?key=';
  static const String newsUrl = '${Env.baseUrl}pages/news.php';
  static const String qiblaFinderUrl =
      'https://qiblafinder.withgoogle.com/intl/id/onboarding';

}
