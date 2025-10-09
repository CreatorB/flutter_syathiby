import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'MAPS_API_KEY', obfuscate: true)
  static final String mapsApiKey = _Env.mapsApiKey;
  @EnviedField(varName: 'API_URL')
  static const String baseUrl = _Env.baseUrl;
  @EnviedField(varName: 'LINK_BASE')
  static const String linkBase = _Env.linkBase;
}
