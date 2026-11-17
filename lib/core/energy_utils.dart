import 'package:flutter/material.dart';
import '../models/energy_level.dart';
import 'l10n/app_localizations.dart';

/// [EnergyLevel] için görsel yardımcılar: renk, etiket, ikon ve emoji.
///
/// Renk paleti uygulamanın neon-karanlık temasıyla tutarlıdır:
/// düşük enerji → mor, hiperfocus → elektrik mavisi, kaos → neon yeşil.
abstract final class EnergyUtils {
  /// Seviyenin tema rengini döndürür.
  static Color getColor(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.low:
        return const Color(0xFFBC13FE);
      case EnergyLevel.hyperfocus:
        return const Color(0xFF00FFFF);
      case EnergyLevel.chaos:
        return const Color(0xFF39FF14);
    }
  }

  static String getLabel(EnergyLevel level, AppLocalizations l10n) {
    switch (level) {
      case EnergyLevel.low:
        return l10n.lowEnergy;
      case EnergyLevel.hyperfocus:
        return l10n.highEnergy;
      case EnergyLevel.chaos:
        return l10n.mediumEnergy;
    }
  }

  static IconData getIcon(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.low:
        return Icons.battery_1_bar;
      case EnergyLevel.hyperfocus:
        return Icons.center_focus_strong;
      case EnergyLevel.chaos:
        return Icons.flash_on;
    }
  }

  static String getEmoji(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.low:
        return '\u{1F7E3}';
      case EnergyLevel.hyperfocus:
        return '\u{1F535}';
      case EnergyLevel.chaos:
        return '\u{1F7E0}';
    }
  }
}
