import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/transitions.dart';
import '../../shared/widgets/app_icon_widget.dart';
import '../../features/preferences/preferences_screen.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  void _selectLanguage(BuildContext context, String langCode) {
    HapticFeedback.mediumImpact();
    HyperSeedApp.setLocale(context, Locale(langCode));
    Navigator.of(context).pushReplacement(
      NeonPageRoute(page: const PreferencesScreen(isOnboarding: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const AppIconWidget(size: 64),
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context).language,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 12),
              Text(
                'Choose your language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 40),
              _LanguageOption(
                label: 'Türkçe',
                flag: '🇹🇷',
                onTap: () => _selectLanguage(context, 'tr'),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 14),
              _LanguageOption(
                label: 'English',
                flag: '🇬🇧',
                onTap: () => _selectLanguage(context, 'en'),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String flag;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.flag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
