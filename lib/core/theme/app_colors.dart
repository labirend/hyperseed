import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color background = Color(0xFF000000);
  static const Color primary = Color(0xFF39FF14);
  static const Color secondary = Color(0xFF00FFFF);
  static const Color tertiary = Color(0xFFBC13FE);
  static const Color surface = Color(0xFF111111);
  static const Color surfaceVariant = Color(0xFF1A1A1A);
  static const Color error = Color(0xFFFF1744);
  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFF000000);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFFB0B0B0);

  static Color primaryGlow(double opacity) =>
      primary.withValues(alpha: opacity);
  static Color secondaryGlow(double opacity) =>
      secondary.withValues(alpha: opacity);
  static Color tertiaryGlow(double opacity) =>
      tertiary.withValues(alpha: opacity);
}
