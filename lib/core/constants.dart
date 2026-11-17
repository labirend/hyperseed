/// Uygulama genelinde kullanılan sabitler: kutu adları, ayar
/// anahtarları ve günlük görev limiti.
abstract final class AppConstants {
  static const int dailyTaskLimit = 5;
  static const String taskBoxName = 'tasks';
  static const String settingsBoxName = 'settings';
  static const String energyKey = 'currentEnergy';
  static const String dailyLimitEnabledKey = 'dailyLimitEnabled';
  static const String languageCodeKey = 'languageCode';
  static const String onboardingSeenKey = 'onboardingSeen';
  static const String userPreferencesKey = 'userPreferences';
}
