import 'package:flutter/material.dart';

extension Typography on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  TextStyle? get displayLarge => textTheme.displayLarge;

  TextStyle? get displayLargeBold =>
      displayLarge?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get displayMedium => textTheme.displayMedium;

  TextStyle? get displayMediumBold =>
      displayMedium?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get displaySmall => textTheme.displaySmall;

  TextStyle? get displaySmallBold =>
      displaySmall?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get headlineLarge => textTheme.headlineLarge;

  TextStyle? get headlineLargeBold =>
      headlineLarge?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get headlineMedium => textTheme.headlineMedium;

  TextStyle? get headlineMediumBold =>
      headlineMedium?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get headlineSmall => textTheme.headlineSmall;

  TextStyle? get headlineSmallBold =>
      headlineSmall?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get titleLarge => textTheme.titleLarge;

  TextStyle? get titleLargeBold =>
      titleLarge?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get titleMedium => textTheme.titleMedium;

  TextStyle? get titleMediumBold =>
      titleMedium?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get titleSmall => textTheme.titleSmall;

  TextStyle? get titleSmallBold =>
      titleSmall?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get bodyLarge => textTheme.bodyLarge;

  TextStyle? get bodyLargeBold =>
      bodyLarge?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get bodyMedium => textTheme.bodyMedium;

  TextStyle? get bodyMediumBold =>
      bodyMedium?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get bodySmall => textTheme.bodySmall;

  TextStyle? get bodySmallBold =>
      bodySmall?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get labelLarge => textTheme.labelLarge;

  TextStyle? get labelLargeBold =>
      labelLarge?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get labelMedium => textTheme.labelMedium;

  TextStyle? get labelMediumBold =>
      labelMedium?.copyWith(fontWeight: FontWeight.bold);

  TextStyle? get labelSmall => textTheme.labelSmall;

  TextStyle? get labelSmallBold =>
      labelSmall?.copyWith(fontWeight: FontWeight.bold);
}
