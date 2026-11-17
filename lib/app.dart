import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/l10n/app_localizations.dart';
import 'shared/splash/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'features/energy/energy_screen.dart';
import 'features/preferences/preferences_screen.dart';
import 'features/language/language_selection_screen.dart';
import 'services/hive_service.dart';

class HyperSeedApp extends StatefulWidget {
  const HyperSeedApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_HyperSeedAppState>();
    state?.setLocale(locale);
  }

  @override
  State<HyperSeedApp> createState() => _HyperSeedAppState();
}

class _HyperSeedAppState extends State<HyperSeedApp> {
  Locale _locale = _getDeviceLocale();

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
    HiveService.setLanguageCode(locale.languageCode);
  }

  static Locale _getDeviceLocale() {
    final saved = HiveService.getLanguageCode();
    if (saved != null) return Locale(saved);
    return WidgetsBinding.instance.platformDispatcher.locale;
  }

  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HyperSeed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (!_splashDone) {
      return SplashScreen(
        onComplete: () {
          setState(() => _splashDone = true);
        },
      );
    }

    final languageCode = HiveService.getLanguageCode();
    final userPrefs = HiveService.getUserPreferences();
    final currentEnergy = HiveService.getCurrentEnergy();

    if (languageCode == null) {
      return const LanguageScreen();
    }

    if (userPrefs.isEmpty) {
      return const PreferencesScreen(isOnboarding: true);
    }

    if (currentEnergy == null) {
      return const EnergyScreen();
    }

    return const HomeScreen();
  }
}
