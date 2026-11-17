import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/energy_utils.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/energy_level.dart';

class EnergySelector extends StatelessWidget {
  final EnergyLevel? selected;
  final ValueChanged<EnergyLevel> onSelected;

  const EnergySelector({super.key, this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        _EnergyOption(
          level: EnergyLevel.low,
          label: l10n.energyLow,
          desc: l10n.energyLowDesc,
          isSelected: selected == EnergyLevel.low,
          onTap: () {
            HapticFeedback.lightImpact();
            onSelected(EnergyLevel.low);
          },
        ),
        const SizedBox(height: 12),
        _EnergyOption(
          level: EnergyLevel.hyperfocus,
          label: l10n.energyHyper,
          desc: l10n.energyHyperDesc,
          isSelected: selected == EnergyLevel.hyperfocus,
          onTap: () {
            HapticFeedback.lightImpact();
            onSelected(EnergyLevel.hyperfocus);
          },
        ),
        const SizedBox(height: 12),
        _EnergyOption(
          level: EnergyLevel.chaos,
          label: l10n.energyChaos,
          desc: l10n.energyChaosDesc,
          isSelected: selected == EnergyLevel.chaos,
          onTap: () {
            HapticFeedback.lightImpact();
            onSelected(EnergyLevel.chaos);
          },
        ),
      ],
    );
  }
}

class _EnergyOption extends StatelessWidget {
  final EnergyLevel level;
  final String label;
  final String desc;
  final bool isSelected;
  final VoidCallback onTap;

  const _EnergyOption({
    required this.level,
    required this.label,
    required this.desc,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = EnergyUtils.getColor(level);
    final icon = EnergyUtils.getIcon(level);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? color : AppColors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}
