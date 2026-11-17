import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../models/task.dart';
import '../models/energy_level.dart';

/// Tüm kalıcı veriye tek giriş noktasıdır.
///
/// İki Hive kutusu kullanır: görevler (`tasks`) ve ayarlar
/// (`settings`). Kutular [init] sırasında açılır; uygulama
/// tamamen çalıştığı sürece açık kalır. Veri yalnızca cihazda
/// saklanır, hiçbir ağ çağrısı yapılmaz.
class HiveService {
  /// Hive'ı başlatır, adaptörleri kaydeder ve kutuları açar.
  ///
  /// [init] çağrıldıktan sonra statik getter'lar güvenle kullanılabilir.
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(EnergyLevelAdapter());
    Hive.registerAdapter(TaskAdapter());
    await Hive.openBox<Task>(AppConstants.taskBoxName);
    await Hive.openBox(AppConstants.settingsBoxName);
  }

  static Box<Task> get taskBox => Hive.box<Task>(AppConstants.taskBoxName);
  static Box get settingsBox => Hive.box(AppConstants.settingsBoxName);

  static EnergyLevel? getCurrentEnergy() {
    final index = settingsBox.get(AppConstants.energyKey);
    if (index == null) return null;
    return EnergyLevel.values[index as int];
  }

  static Future<void> setCurrentEnergy(EnergyLevel level) async {
    await settingsBox.put(AppConstants.energyKey, level.index);
  }

  static bool getDailyLimitEnabled() {
    return settingsBox.get(
      AppConstants.dailyLimitEnabledKey,
      defaultValue: false,
    );
  }

  static Future<void> setDailyLimitEnabled(bool enabled) async {
    await settingsBox.put(AppConstants.dailyLimitEnabledKey, enabled);
  }

  static String? getLanguageCode() {
    return settingsBox.get(AppConstants.languageCodeKey);
  }

  static Future<void> setLanguageCode(String code) async {
    await settingsBox.put(AppConstants.languageCodeKey, code);
  }

  static bool getOnboardingSeen() {
    return settingsBox.get(AppConstants.onboardingSeenKey, defaultValue: false);
  }

  static Future<void> setOnboardingSeen() async {
    await settingsBox.put(AppConstants.onboardingSeenKey, true);
  }

  static List<String> getUserPreferences() {
    final raw = settingsBox.get(AppConstants.userPreferencesKey);
    if (raw == null) return [];
    return List<String>.from(raw as List);
  }

  static Future<void> setUserPreferences(List<String> categories) async {
    await settingsBox.put(AppConstants.userPreferencesKey, categories);
  }

  static Future<void> clearAllData() async {
    await HiveService.taskBox.clear();
    await HiveService.settingsBox.clear();
  }
}
