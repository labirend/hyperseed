import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/transitions.dart';
import '../../services/hive_service.dart';
import '../../shared/widgets/neon_button.dart';
import '../../features/completion/thank_you_screen.dart';
import 'task_card.dart';
import 'task_form_screen.dart';
import 'tasks_provider.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final completedToday = ref.watch(completedTodayProvider);
    final poolExhausted = ref.watch(poolExhaustedProvider).valueOrNull ?? false;
    final l10n = AppLocalizations.of(context);
    final limitEnabled = HiveService.getDailyLimitEnabled();
    final completedCount = completedToday.length;
    final limit = AppConstants.dailyTaskLimit;
    final canAdd = (!limitEnabled || completedCount < limit) && !poolExhausted;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco,
                    size: 64,
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noTasks,
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  NeonButton(
                    text: l10n.randomTask,
                    icon: Icons.casino_outlined,
                    enabled: canAdd,
                    onPressed: canAdd
                        ? () async {
                            final locale = Localizations.localeOf(
                              context,
                            ).languageCode;
                            final added = await ref
                                .read(tasksProvider.notifier)
                                .addRandomTask(locale: locale);
                            if (!added && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.dailyLimitReached),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          }
                        : () {},
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${tasks.where((t) => !t.isCompleted).length} ${l10n.tasks}',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: canAdd
                              ? () async {
                                  final locale = Localizations.localeOf(
                                    context,
                                  ).languageCode;
                                  final added = await ref
                                      .read(tasksProvider.notifier)
                                      .addRandomTask(locale: locale);
                                  if (!added && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.dailyLimitReached),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: AppColors.surface,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          child: Opacity(
                            opacity: canAdd ? 1.0 : 0.4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.casino_outlined,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.randomTask,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (limitEnabled)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.dailyTasks,
                                style: const TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$completedCount/$limit',
                                style: TextStyle(
                                  color: canAdd
                                      ? AppColors.primary
                                      : AppColors.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: completedCount / limit,
                              minHeight: 4,
                              backgroundColor: AppColors.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                canAdd ? AppColors.primary : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final task = tasks[index];
                    return TaskCard(
                      task: task,
                      confirmDismiss: (_) async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              l10n.delete,
                              style: const TextStyle(
                                color: AppColors.onSurface,
                              ),
                            ),
                            content: Text(
                              l10n.deleteConfirmation,
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: Text(
                                  l10n.no,
                                  style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: Text(
                                  l10n.yes,
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        );
                        return confirmed == true;
                      },
                      onComplete: () {
                        ref.read(tasksProvider.notifier).completeTask(task.id);
                      },
                      onDelete: () {
                        ref.read(tasksProvider.notifier).deleteTask(task.id);
                      },
                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(NeonPageRoute(page: TaskFormScreen(task: task)));
                      },
                    );
                  }, childCount: tasks.length),
                ),
                if (completedToday.isEmpty && tasks.any((t) => !t.isCompleted))
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Text(
                        l10n.noCompletedToday,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                if (completedToday.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          Navigator.of(context).push(
                            NeonSlideUpRoute(
                              page: ThankYouScreen(
                                completedTasks: completedToday,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${completedToday.length} ${l10n.tasksCount}',
                                style: const TextStyle(
                                  color: AppColors.onPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.thankYouButtonMain,
                                style: const TextStyle(
                                  color: AppColors.onPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
      floatingActionButton: GestureDetector(
        onTap: canAdd
            ? () {
                HapticFeedback.mediumImpact();
                Navigator.of(
                  context,
                ).push(NeonSlideUpRoute(page: const TaskFormScreen()));
              }
            : null,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: canAdd
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
            boxShadow: canAdd
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            Icons.add,
            color: canAdd ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
