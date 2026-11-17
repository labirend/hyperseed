import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/neon_button.dart';
import '../../shared/widgets/neon_card.dart';
import 'wait_provider.dart';

class WaitModeScreen extends ConsumerStatefulWidget {
  const WaitModeScreen({super.key});

  @override
  ConsumerState<WaitModeScreen> createState() => _WaitModeScreenState();
}

class _WaitModeScreenState extends ConsumerState<WaitModeScreen> {
  Timer? _timer;
  Duration? _remaining;
  final List<_FillingTask> _tasks = [];

  @override
  void initState() {
    super.initState();
    _tasks.addAll(_defaultFillingTasks);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _timer?.cancel();
    _updateRemaining();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(),
    );
  }

  void _updateRemaining() {
    final waitState = ref.read(waitProvider);
    setState(() => _remaining = waitState.getTimeRemaining());
  }

  void _startWaitMode() {
    ref.read(waitProvider.notifier).startWaitMode();
    _startTicker();
  }

  void _stopWaitMode() {
    ref.read(waitProvider.notifier).stopWaitMode();
    _timer?.cancel();
    setState(() => _remaining = null);
  }

  Future<void> _pickAppointmentTime() async {
    final waitState = ref.read(waitProvider);
    final now = DateTime.now();
    final initial =
        waitState.appointmentTime ?? now.add(const Duration(hours: 1));

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.secondary,
              surface: AppColors.surface,
              onSurface: AppColors.onBackground,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.surface,
              hourMinuteColor: AppColors.primary.withValues(alpha: 0.1),
              hourMinuteTextColor: AppColors.onBackground,
              dialHandColor: AppColors.secondary,
              dialBackgroundColor: AppColors.surface,
              dialTextColor: AppColors.onBackground,
              entryModeIconColor: AppColors.secondary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      final appointment = dateTime.isBefore(now)
          ? dateTime.add(const Duration(days: 1))
          : dateTime;
      ref.read(waitProvider.notifier).setAppointmentTime(appointment);
      if (ref.read(waitProvider).isActive) {
        _updateRemaining();
      }
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final waitState = ref.watch(waitProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.waitModeTitle,
          style: const TextStyle(
            color: AppColors.onBackground,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCountdownSection(l10n, waitState),
            const SizedBox(height: 24),
            _buildAppointmentPicker(l10n, waitState),
            const SizedBox(height: 32),
            _buildFillingTasksSection(l10n),
            const SizedBox(height: 32),
            _buildControlButton(l10n, waitState),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownSection(AppLocalizations l10n, WaitState waitState) {
    return Center(
      child: Column(
        children: [
          if (waitState.appointmentTime == null) ...[
            Icon(
              Icons.access_time,
              size: 64,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.setAppointmentTime,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ] else ...[
            Text(
              _remaining != null ? _formatDuration(_remaining!) : '--:--:--',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 60,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.timeUntilAppointment,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppointmentPicker(AppLocalizations l10n, WaitState waitState) {
    final timeStr = waitState.appointmentTime != null
        ? MaterialLocalizations.of(
            context,
          ).formatTimeOfDay(TimeOfDay.fromDateTime(waitState.appointmentTime!))
        : '--:--';

    return GestureDetector(
      onTap: _pickAppointmentTime,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appointmentTime,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: const TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(Icons.access_time, color: AppColors.secondary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFillingTasksSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.fillingTasks,
              style: const TextStyle(
                color: AppColors.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: _showAddTaskDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 14,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.addTask,
                      style: TextStyle(
                        color: AppColors.primary.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_tasks.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l10n.noFillingTasks,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ...List.generate(_tasks.length, (index) {
            final task = _tasks[index];
            return Dismissible(
              key: ValueKey(task.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                setState(() => _tasks.removeAt(index));
              },
              background: Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete, color: AppColors.error),
              ),
              child: NeonCard(
                margin: const EdgeInsets.symmetric(vertical: 4),
                glowColor: AppColors.primary,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              color: AppColors.onBackground,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${task.estimatedMinutes} ${AppLocalizations.of(context).minutes}',
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.timer_outlined,
                      color: AppColors.primary.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildControlButton(AppLocalizations l10n, WaitState waitState) {
    return Center(
      child: NeonButton(
        text: waitState.isActive ? l10n.stopWaitMode : l10n.startWaitMode,
        color: waitState.isActive ? AppColors.error : AppColors.primary,
        pulse: !waitState.isActive && waitState.appointmentTime != null,
        width: double.infinity,
        icon: waitState.isActive ? Icons.stop_circle : Icons.play_circle,
        onPressed: waitState.isActive
            ? _stopWaitMode
            : waitState.appointmentTime != null
            ? _startWaitMode
            : () {},
        enabled: waitState.appointmentTime != null,
      ),
    );
  }

  void _showAddTaskDialog() {
    final controller = TextEditingController();
    final durationController = TextEditingController(text: '5');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Filling Task',
          style: TextStyle(color: AppColors.onBackground),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              style: const TextStyle(color: AppColors.onBackground),
              decoration: InputDecoration(
                hintText: 'Task title',
                hintStyle: TextStyle(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.secondary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.onBackground),
              decoration: InputDecoration(
                hintText: 'Minutes',
                hintStyle: TextStyle(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.secondary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              final title = controller.text.trim();
              final minutes = int.tryParse(durationController.text) ?? 5;
              if (title.isNotEmpty) {
                setState(() {
                  _tasks.add(
                    _FillingTask(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      estimatedMinutes: minutes,
                    ),
                  );
                });
              }
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FillingTask {
  final String id;
  final String title;
  final int estimatedMinutes;

  const _FillingTask({
    required this.id,
    required this.title,
    required this.estimatedMinutes,
  });
}

const _defaultFillingTasks = [
  _FillingTask(id: '1', title: 'Quick stretch', estimatedMinutes: 2),
  _FillingTask(id: '2', title: 'Deep breathing', estimatedMinutes: 3),
  _FillingTask(id: '3', title: 'Water break', estimatedMinutes: 1),
  _FillingTask(id: '4', title: 'Tidy desk', estimatedMinutes: 5),
  _FillingTask(id: '5', title: 'Write 3 gratitude items', estimatedMinutes: 3),
];
