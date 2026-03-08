/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/uthmanic_hafs_v20.ttf
  String get uthmanicHafsV20 => 'assets/fonts/uthmanic_hafs_v20.ttf';

  /// List of all assets
  List<String> get values => [uthmanicHafsV20];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/compass.svg
  String get compass => 'assets/images/compass.svg';

  /// File path: assets/images/icon.png
  AssetGenImage get icon => const AssetGenImage('assets/images/icon.png');

  /// File path: assets/images/logo.png
  AssetGenImage get logo => const AssetGenImage('assets/images/logo.png');

  /// File path: assets/images/needle.svg
  String get needle => 'assets/images/needle.svg';

  /// File path: assets/images/syathiby_splash_1152.png
  AssetGenImage get syathibySplash1152 =>
      const AssetGenImage('assets/images/syathiby_splash_1152.png');

  /// File path: assets/images/syathiby_splash_1152_backup.png
  AssetGenImage get syathibySplash1152Backup =>
      const AssetGenImage('assets/images/syathiby_splash_1152_backup.png');

  /// List of all assets
  List<dynamic> get values => [
        compass,
        icon,
        logo,
        needle,
        syathibySplash1152,
        syathibySplash1152Backup
      ];
}

class $AssetsJsonGen {
  const $AssetsJsonGen();

  /// File path: assets/json/evening_dhikr.json
  String get eveningDhikr => 'assets/json/evening_dhikr.json';

  /// File path: assets/json/morning_dhikr.json
  String get morningDhikr => 'assets/json/morning_dhikr.json';

  /// List of all assets
  List<String> get values => [eveningDhikr, morningDhikr];
}

class Assets {
  Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsJsonGen json = $AssetsJsonGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
