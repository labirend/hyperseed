import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/energy_utils.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/transitions.dart';
import '../../models/energy_level.dart';
import '../../services/hive_service.dart';
import '../../shared/widgets/app_icon_widget.dart';
import '../../shared/widgets/neon_button.dart';
import '../../shared/widgets/energy_selector.dart';
import '../../features/home/home_screen.dart';
import 'energy_provider.dart';

class EnergyScreen extends ConsumerStatefulWidget {
  final bool isOnboarding;

  const EnergyScreen({super.key, this.isOnboarding = false});

  @override
  ConsumerState<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends ConsumerState<EnergyScreen> {
  EnergyLevel? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final energyNotifier = ref.read(energyProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const AppIconWidget(size: 64),
              const SizedBox(height: 32),
              Text(
                l10n.energyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 40),
              EnergySelector(
                selected: _selected,
                onSelected: (level) => setState(() => _selected = level),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              const SizedBox(height: 40),
              NeonButton(
                text: l10n.getStarted,
                pulse: _selected != null,
                color: _selected != null
                    ? EnergyUtils.getColor(_selected!)
                    : AppColors.onSurfaceVariant,
                width: double.infinity,
                onPressed: _selected == null
                    ? () {}
                    : () {
                        energyNotifier.setEnergy(_selected!);
                        HiveService.setOnboardingSeen();
                        Navigator.of(context).pushReplacement(
                          NeonPageRoute(page: const HomeScreen()),
                        );
                      },
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
