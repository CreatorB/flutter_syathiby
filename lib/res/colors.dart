import 'package:flutter/material.dart';

// Base Color Palette
// Primary: #26774e (Forest Green)
// Dark: #19633f (Deep Forest)
// Light: #82aa68 (Sage Green)

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF26774e), // Primary green
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF82aa68), // Light green
  onPrimaryContainer: Color(0xFF002201),
  secondary: Color(0xFF446813),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFC4F18C),
  onSecondaryContainer: Color(0xFF102000),
  tertiary: Color(0xFF5B6400),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFDFEB76),
  onTertiaryContainer: Color(0xFF1A1D00),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFFFFBFF), // Slightly off-white for better contrast
  onSurface: Color(0xFF1A1C19),
  surfaceContainerHighest: Color(0xFFE1E3DD),
  onSurfaceVariant: Color(0xFF42493F),
  outline: Color(0xFF73796E),
  onInverseSurface: Color(0xFFF0F1EB),
  inverseSurface: Color(0xFF2F312C),
  inversePrimary: Color(0xFF82aa68), // Light green
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF26774e), // Primary green
  outlineVariant: Color(0xFFC2C8BC),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF82aa68), // Light green for dark mode
  onPrimary: Color(0xFF003A03),
  primaryContainer: Color(0xFF19633f), // Dark green
  onPrimaryContainer: Color(0xFF82aa68),
  secondary: Color(0xFFA9D473),
  onSecondary: Color(0xFF1F3700),
  secondaryContainer: Color(0xFF2F4F00),
  onSecondaryContainer: Color(0xFFC4F18C),
  tertiary: Color(0xFFC3CE5D),
  onTertiary: Color(0xFF2E3300),
  tertiaryContainer: Color(0xFF444B00),
  onTertiaryContainer: Color(0xFFDFEB76),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF1A1C19),
  onSurface: Color(0xFFE1E3DD),
  surfaceContainerHighest: Color(0xFF42493F),
  onSurfaceVariant: Color(0xFFC2C8BC),
  outline: Color(0xFF8C9387),
  onInverseSurface: Color(0xFF1A1C19),
  inverseSurface: Color(0xFFE1E3DD),
  inversePrimary: Color(0xFF26774e), // Primary green
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF82aa68), // Light green
  outlineVariant: Color(0xFF42493F),
  scrim: Color(0xFF000000),
);
