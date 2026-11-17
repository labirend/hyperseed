import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import '../../core/constants.dart';
import '../../core/energy_utils.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/transitions.dart';
import '../../models/energy_level.dart';
import '../../services/hive_service.dart';
import '../energy/energy_provider.dart';
import '../energy/energy_screen.dart';
import '../preferences/preferences_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = Localizations.localeOf(context).languageCode;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 16),
        _SettingsSection(
          title: l10n.language,
          children: [
            _LanguageTile(
              label: l10n.turkish,
              code: 'tr',
              isActive: currentLocale == 'tr',
              onTap: () {
                HyperSeedApp.setLocale(context, const Locale('tr'));
              },
            ),
            _LanguageTile(
              label: l10n.english,
              code: 'en',
              isActive: currentLocale == 'en',
              onTap: () {
                HyperSeedApp.setLocale(context, const Locale('en'));
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SettingsSection(
          title: l10n.dailyLimit,
          children: [
            SwitchListTile(
              title: Text(
                l10n.dailyLimitDesc,
                style: const TextStyle(color: AppColors.onSurface),
              ),
              subtitle: Text(
                '${AppConstants.dailyTaskLimit} ${l10n.tasks}',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              value: HiveService.getDailyLimitEnabled(),
              activeThumbColor: AppColors.primary,
              onChanged: (value) {
                HiveService.setDailyLimitEnabled(value);
                setState(() {});
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SettingsSection(
          title: l10n.energyTitle,
          children: [
            ListTile(
              title: Text(
                EnergyUtils.getLabel(
                  ref.read(energyProvider) ?? EnergyLevel.low,
                  l10n,
                ),
                style: const TextStyle(color: AppColors.onSurface),
              ),
              subtitle: Text(
                l10n.changeEnergy,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.onSurfaceVariant,
              ),
              onTap: () {
                Navigator.of(
                  context,
                ).push(NeonPageRoute(page: const EnergyScreen()));
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SettingsSection(
          title: l10n.interests,
          children: [
            ListTile(
              leading: Icon(Icons.tune, color: AppColors.secondary),
              title: Text(
                l10n.selectInterests,
                style: const TextStyle(color: AppColors.onSurface),
              ),
              subtitle: Text(
                l10n.interestsDesc,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.onSurfaceVariant,
              ),
              onTap: () {
                Navigator.of(
                  context,
                ).push(NeonPageRoute(page: const PreferencesScreen()));
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SettingsSection(
          title: l10n.dangerZone,
          titleColor: AppColors.error,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.error),
              title: Text(
                l10n.deleteAllData,
                style: const TextStyle(color: AppColors.error),
              ),
              subtitle: Text(
                l10n.deleteAllDataWarning,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              onTap: () => _showDeleteDialog(context, l10n),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.deleteAllData,
          style: const TextStyle(color: AppColors.error),
        ),
        content: Text(
          l10n.deleteAllDataConfirm,
          style: const TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await HiveService.clearAllData();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HyperSeedApp()),
                  (route) => false,
                );
              }
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color? titleColor;

  const _SettingsSection({
    required this.title,
    required this.children,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: (titleColor ?? AppColors.primary).withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (titleColor ?? AppColors.primary).withValues(alpha: 0.1),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final String code;
  final bool isActive;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.label,
    required this.code,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.primary : AppColors.onSurface,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isActive
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}
