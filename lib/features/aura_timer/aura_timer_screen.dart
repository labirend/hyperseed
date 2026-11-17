import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/neon_button.dart';
import 'aura_provider.dart';

class AuraTimerScreen extends ConsumerStatefulWidget {
  const AuraTimerScreen({super.key});

  @override
  ConsumerState<AuraTimerScreen> createState() => _AuraTimerScreenState();
}

class _AuraTimerScreenState extends ConsumerState<AuraTimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _celebrateController;
  bool _showCelebration = false;

  static const _durationOptions = [15, 25, 45, 60];

  @override
  void initState() {
    super.initState();
    _celebrateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _celebrateController.dispose();
    super.dispose();
  }

  void _checkCompletion(AuraState aura) {
    if (aura.isComplete && !_showCelebration) {
      _showCelebration = true;
      _celebrateController.forward(from: 0);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showCelebration = false);
          ref.read(auraProvider.notifier).stopTimer();
        }
      });
    }
  }

  List<Color> _gradientColors(double elapsed) {
    if (elapsed <= 0.33) {
      final t = (elapsed / 0.33).clamp(0.0, 1.0);
      return [
        Color.lerp(const Color(0xFF0A1628), const Color(0xFF1A237E), t)!,
        Color.lerp(const Color(0xFF0D1B3E), const Color(0xFF1A237E), t)!,
      ];
    } else if (elapsed <= 0.66) {
      final t = ((elapsed - 0.33) / 0.33).clamp(0.0, 1.0);
      return [
        Color.lerp(const Color(0xFF1A237E), const Color(0xFFBF360C), t)!,
        Color.lerp(const Color(0xFF1A1A5E), const Color(0xFFBF360C), t)!,
      ];
    } else {
      final t = ((elapsed - 0.66) / 0.34).clamp(0.0, 1.0);
      return [
        Color.lerp(const Color(0xFFBF360C), const Color(0xFF4A148C), t)!,
        Color.lerp(const Color(0xFF8B1A00), const Color(0xFF311B92), t)!,
      ];
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final aura = ref.watch(auraProvider);
    final l10n = AppLocalizations.of(context);
    _checkCompletion(aura);

    final elapsed = aura.elapsed;
    final colors = _gradientColors(elapsed);
    final displayDuration = aura.isRunning || aura.isPaused
        ? aura.remaining
        : aura.duration;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () {
            ref.read(auraProvider.notifier).stopTimer();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          l10n.auraTimer,
          style: const TextStyle(
            color: AppColors.onBackground,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              if (aura.isRunning || aura.isPaused)
                ...colors
              else ...[
                AppColors.background,
                AppColors.surface,
              ],
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (!aura.isRunning && !_showCelebration) _durationPicker(l10n),
              const Spacer(),
              _showCelebration
                  ? _buildCelebration(l10n)
                  : _buildTimerDisplay(aura, displayDuration, l10n),
              const Spacer(),
              if (!_showCelebration) _buildControlButton(aura, l10n),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _durationPicker(AppLocalizations l10n) {
    final aura = ref.watch(auraProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          Text(
            l10n.setDuration,
            style: TextStyle(
              color: AppColors.onBackground.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _durationOptions.map((min) {
              final isActive = aura.duration.inMinutes == min;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => ref
                      .read(auraProvider.notifier)
                      .setDuration(Duration(minutes: min)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.onBackground.withValues(alpha: 0.2),
                        width: isActive ? 2 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      '$min',
                      style: TextStyle(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.onBackground.withValues(alpha: 0.5),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.auraDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.onBackground.withValues(alpha: 0.35),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(
    AuraState aura,
    Duration displayDuration,
    AppLocalizations l10n,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(240, 240),
                painter: _ProgressArcPainter(
                  progress: aura.elapsed,
                  color: AppColors.primary,
                ),
              ),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background.withValues(alpha: 0.6),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatDuration(displayDuration),
                      style: const TextStyle(
                        color: AppColors.onBackground,
                        fontSize: 48,
                        fontWeight: FontWeight.w200,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.minutesRemaining,
                      style: TextStyle(
                        color: AppColors.onBackground.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(AuraState aura, AppLocalizations l10n) {
    String text;
    VoidCallback onPressed;

    if (!aura.isRunning && !aura.isPaused) {
      text = l10n.startFocus;
      onPressed = () => ref.read(auraProvider.notifier).startTimer();
    } else if (aura.isPaused) {
      text = l10n.resumeFocus;
      onPressed = () => ref.read(auraProvider.notifier).resumeTimer();
    } else {
      text = l10n.pauseFocus;
      onPressed = () => ref.read(auraProvider.notifier).pauseTimer();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: NeonButton(
        text: text,
        icon: !aura.isRunning && !aura.isPaused
            ? Icons.play_arrow_rounded
            : aura.isPaused
            ? Icons.play_arrow_rounded
            : Icons.pause_rounded,
        pulse: aura.isRunning && !aura.isPaused,
        width: double.infinity,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCelebration(AppLocalizations l10n) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _celebrateController,
        curve: Curves.elasticOut,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 56,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.08, 1.08),
                duration: 800.ms,
                curve: Curves.easeInOut,
              )
              .then()
              .scale(
                begin: const Offset(1.08, 1.08),
                end: const Offset(1, 1),
                duration: 800.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 24),
          Text(
            l10n.focusComplete,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

class _ProgressArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 4.0;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(rect, -pi / 2, sweepAngle, false, arcPaint);

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(rect, -pi / 2, sweepAngle, false, glowPaint);
  }

  @override
  bool shouldRepaint(_ProgressArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
