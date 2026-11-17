import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/energy_utils.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final Future<bool> Function(DismissDirection)? confirmDismiss;

  const TaskCard({
    super.key,
    required this.task,
    this.onComplete,
    this.onDelete,
    this.onTap,
    this.confirmDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final energyColor = EnergyUtils.getColor(task.energyLevel);
    final l10n = AppLocalizations.of(context);

    return Dismissible(
          key: Key(task.id),
          direction: onDelete != null
              ? DismissDirection.endToStart
              : DismissDirection.none,
          confirmDismiss: confirmDismiss,
          onDismissed: (_) => onDelete?.call(),
          background: Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: AppColors.error),
          ),
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? AppColors.surface.withValues(alpha: 0.5)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: task.isCompleted
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : energyColor.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: task.isCompleted
                    ? []
                    : [
                        BoxShadow(
                          color: energyColor.withValues(alpha: 0.08),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onComplete?.call();
                    },
                    child: _buildCheckbox(energyColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            color: task.isCompleted
                                ? AppColors.onSurfaceVariant.withValues(
                                    alpha: 0.5,
                                  )
                                : AppColors.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: AppColors.onSurfaceVariant.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.durationMin} dk',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: energyColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                EnergyUtils.getLabel(task.energyLevel, l10n),
                                style: TextStyle(
                                  color: energyColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0, duration: 300.ms);
  }

  Widget _buildCheckbox(Color energyColor) {
    final isCompleted = task.isCompleted;

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCompleted
                      ? AppColors.primary
                      : energyColor.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: AppColors.primary, size: 18)
                  : null,
            )
            .animate(target: isCompleted ? 1 : 0)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 300.ms,
              curve: Curves.elasticOut,
            ),
        if (isCompleted)
          ...List.generate(6, (i) {
            return Positioned(
              left: 16 + 20 * i / 6 * 0.5 * (i.isEven ? 1 : -1),
              top: 16 + 20 * (i % 3 - 1) * 0.3,
              child:
                  Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      )
                      .animate()
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        delay: Duration(milliseconds: i * 30),
                        curve: Curves.elasticOut,
                      )
                      .then()
                      .fade(
                        begin: 1,
                        end: 0,
                        duration: 300.ms,
                        delay: Duration(milliseconds: 100 + i * 30),
                      ),
            );
          }),
      ],
    );
  }
}
