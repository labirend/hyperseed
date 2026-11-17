import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/neon_button.dart';
import 'buddy_provider.dart';

class FocusBuddyScreen extends ConsumerStatefulWidget {
  const FocusBuddyScreen({super.key});

  @override
  ConsumerState<FocusBuddyScreen> createState() => _FocusBuddyScreenState();
}

class _FocusBuddyScreenState extends ConsumerState<FocusBuddyScreen>
    with TickerProviderStateMixin {
  late final AnimationController _blinkController;
  late final AnimationController _bobController;
  late final AnimationController _zzzController;
  late final AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _zzzController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _bobController.dispose();
    _zzzController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final buddy = ref.watch(buddyProvider);
    final buddyNotifier = ref.read(buddyProvider.notifier);
    final remaining = buddy.remaining;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    final progress = buddy.duration.inSeconds > 0
        ? (buddy.duration.inSeconds - remaining.inSeconds) /
              buddy.duration.inSeconds
        : 0.0;

    if (buddy.mood == BuddyMood.working) {
      if (!_bobController.isAnimating) {
        _bobController.repeat(reverse: true);
      }
      _scheduleBlink();
    } else {
      _bobController.stop();
      _bobController.reset();
      _blinkController.stop();
      _blinkController.reset();
    }

    final String moodText;
    switch (buddy.mood) {
      case BuddyMood.working:
        moodText = l10n.buddyWorking;
        break;
      case BuddyMood.sleeping:
        moodText = l10n.buddySleeping;
        break;
      case BuddyMood.cheering:
        moodText = l10n.buddyCheering;
        break;
      case BuddyMood.idle:
        moodText = l10n.buddyIdle;
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () {
            buddyNotifier.stopTimer();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          l10n.focusBuddy,
          style: const TextStyle(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCharacter(buddy),
                      const SizedBox(height: 16),
                      Text(
                        moodText,
                        style: TextStyle(
                          color: _moodColor(buddy.mood),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                      const SizedBox(height: 32),
                      _buildTimerRing(progress, minutes, seconds, buddy),
                      if (buddy.isComplete)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child:
                              Text(
                                    l10n.focusComplete,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .scale(
                                    begin: const Offset(1, 1),
                                    end: const Offset(1.1, 1.1),
                                    duration: 600.ms,
                                  ),
                        ),
                      const SizedBox(height: 32),
                      if (!buddy.isRunning && !buddy.isComplete)
                        _buildDurationChips(buddy, buddyNotifier),
                      const SizedBox(height: 24),
                      _buildControls(buddy, buddyNotifier, l10n),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleBlink() {
    if (_blinkController.isAnimating) return;
    Future.delayed(Duration(seconds: 2 + Random().nextInt(3)), () {
      if (!mounted) return;
      final buddy = ref.read(buddyProvider);
      if (buddy.mood == BuddyMood.working) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            if (mounted && ref.read(buddyProvider).mood == BuddyMood.working) {
              _scheduleBlink();
            }
          });
        });
      }
    });
  }

  Color _moodColor(BuddyMood mood) {
    switch (mood) {
      case BuddyMood.working:
        return AppColors.primary;
      case BuddyMood.sleeping:
        return AppColors.onSurfaceVariant;
      case BuddyMood.cheering:
        return AppColors.tertiary;
      case BuddyMood.idle:
        return AppColors.secondary;
    }
  }

  Widget _buildCharacter(BuddyState buddy) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _bobController,
        _blinkController,
        _zzzController,
        _sparkleController,
      ]),
      builder: (context, _) {
        final bobOffset = _bobController.value * 6.0;
        return SizedBox(
          width: 200,
          height: 200 + (buddy.mood == BuddyMood.sleeping ? 40 : 0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (buddy.mood == BuddyMood.cheering)
                CustomPaint(
                  size: const Size(260, 260),
                  painter: _SparklePainter(
                    progress: _sparkleController.value,
                    color: AppColors.primary,
                  ),
                ),
              Transform.translate(
                offset: Offset(0, -bobOffset),
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: _BuddyPainter(
                    mood: buddy.mood,
                    blinkProgress: _blinkController.value,
                  ),
                ),
              ),
              if (buddy.mood == BuddyMood.sleeping) ..._buildZzzLetters(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildZzzLetters() {
    return List.generate(3, (i) {
      final t = (_zzzController.value + i * 0.33) % 1.0;
      final opacity = (1.0 - t).clamp(0.0, 1.0);
      final y = -20.0 - t * 80.0;
      final x = 60.0 + i * 15.0;
      return Positioned(
        right: 20,
        top: 40,
        child: Transform.translate(
          offset: Offset(x - 60, y),
          child: Opacity(
            opacity: opacity,
            child: Text(
              'Z',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 18.0 + i * 4.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTimerRing(
    double progress,
    int minutes,
    int seconds,
    BuddyState buddy,
  ) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                buddy.isComplete ? AppColors.tertiary : AppColors.primary,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChips(BuddyState buddy, BuddyNotifier notifier) {
    const durations = [15, 25, 45, 60];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: durations.map((m) {
        final isSelected = buddy.duration.inMinutes == m;
        return GestureDetector(
          onTap: () => notifier.setDuration(Duration(minutes: m)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.surface,
                width: 1.5,
              ),
            ),
            child: Text(
              '$m',
              style: TextStyle(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildControls(
    BuddyState buddy,
    BuddyNotifier notifier,
    AppLocalizations l10n,
  ) {
    if (buddy.isComplete) {
      return NeonButton(
        text: l10n.wakeBuddy,
        color: AppColors.tertiary,
        width: 220,
        onPressed: () => notifier.stopTimer(),
      );
    }

    if (!buddy.isRunning) {
      return NeonButton(
        text: l10n.startFocus,
        color: AppColors.primary,
        pulse: true,
        width: 220,
        onPressed: () {
          HapticFeedback.heavyImpact();
          notifier.startTimer();
        },
      );
    }

    if (buddy.isPaused) {
      return NeonButton(
        text: l10n.resumeFocus,
        color: AppColors.primary,
        width: 220,
        onPressed: () {
          HapticFeedback.mediumImpact();
          notifier.resumeTimer();
        },
      );
    }

    return NeonButton(
      text: l10n.pauseFocus,
      color: AppColors.tertiary,
      width: 220,
      onPressed: () {
        HapticFeedback.mediumImpact();
        notifier.pauseTimer();
      },
    );
  }
}

class _BuddyPainter extends CustomPainter {
  final BuddyMood mood;
  final double blinkProgress;

  _BuddyPainter({required this.mood, this.blinkProgress = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final bodyPaint = Paint()..color = AppColors.secondary;
    final accentPaint = Paint()..color = AppColors.primary;
    final darkPaint = Paint()..color = AppColors.surface;
    final outlinePaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final headW = 120.0;
    final headH = 110.0;
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: headW, height: headH),
      const Radius.circular(20),
    );
    canvas.drawRRect(headRect, bodyPaint);
    canvas.drawRRect(headRect, outlinePaint);

    final earW = 24.0;
    final earH = 30.0;
    final earOffsets = [
      Offset(cx - headW / 2 + 12, cy - headH / 2 - earH + 10),
      Offset(cx + headW / 2 - 12 - earW, cy - headH / 2 - earH + 10),
    ];
    for (final pos in earOffsets) {
      final earRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx, pos.dy, earW, earH),
        const Radius.circular(4),
      );
      canvas.drawRRect(earRect, bodyPaint);
      canvas.drawRRect(earRect, outlinePaint);
    }

    final antennaY = cy - headH / 2 - 6;
    canvas.drawLine(
      Offset(cx, cy - headH / 2 + 4),
      Offset(cx, antennaY - 8),
      accentPaint..strokeWidth = 2,
    );
    canvas.drawCircle(Offset(cx, antennaY - 12), 5, accentPaint);

    final eyeSpacing = 22.0;
    final eyeY = cy - 8.0;
    final eyeSize = 12.0;

    final isClosed = mood == BuddyMood.sleeping || blinkProgress > 0.5;
    if (isClosed) {
      final linePaint = Paint()
        ..color = AppColors.onBackground
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx - eyeSpacing - eyeSize / 2, eyeY),
        Offset(cx - eyeSpacing + eyeSize / 2, eyeY),
        linePaint,
      );
      canvas.drawLine(
        Offset(cx + eyeSpacing - eyeSize / 2, eyeY),
        Offset(cx + eyeSpacing + eyeSize / 2, eyeY),
        linePaint,
      );
    } else {
      final pupilColor = mood == BuddyMood.cheering
          ? AppColors.tertiary
          : AppColors.onBackground;
      canvas.drawCircle(Offset(cx - eyeSpacing, eyeY), eyeSize / 2, darkPaint);
      canvas.drawCircle(
        Offset(cx - eyeSpacing, eyeY),
        eyeSize / 2,
        Paint()
          ..color = pupilColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        Offset(cx - eyeSpacing, eyeY),
        3,
        Paint()..color = pupilColor,
      );

      canvas.drawCircle(Offset(cx + eyeSpacing, eyeY), eyeSize / 2, darkPaint);
      canvas.drawCircle(
        Offset(cx + eyeSpacing, eyeY),
        eyeSize / 2,
        Paint()
          ..color = pupilColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        Offset(cx + eyeSpacing, eyeY),
        3,
        Paint()..color = pupilColor,
      );
    }

    final mouthY = cy + 24.0;
    final mouthPaint = Paint()
      ..color = AppColors.onBackground
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    if (mood == BuddyMood.cheering) {
      final smilePath = Path();
      smilePath.moveTo(cx - 20, mouthY - 4);
      smilePath.quadraticBezierTo(cx, mouthY + 18, cx + 20, mouthY - 4);
      canvas.drawPath(smilePath, mouthPaint);
    } else if (mood == BuddyMood.sleeping) {
      canvas.drawLine(
        Offset(cx - 4, mouthY),
        Offset(cx + 4, mouthY),
        mouthPaint,
      );
    } else {
      canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, mouthY + 2), width: 22, height: 6),
        Paint()..color = AppColors.onBackground,
      );
    }

    final cheekR = 6.0;
    final cheekY = cy + 12.0;
    canvas.drawCircle(
      Offset(cx - 38, cheekY),
      cheekR,
      Paint()..color = AppColors.tertiary.withValues(alpha: 0.3),
    );
    canvas.drawCircle(
      Offset(cx + 38, cheekY),
      cheekR,
      Paint()..color = AppColors.tertiary.withValues(alpha: 0.3),
    );

    final boltX = cx - headW / 2 - 8;
    final boltY = cy - 10;
    final boltPaint = Paint()
      ..color = accentPaint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final boltPath = Path()
      ..moveTo(boltX + 4, boltY)
      ..lineTo(boltX, boltY + 8)
      ..lineTo(boltX + 5, boltY + 6)
      ..lineTo(boltX + 1, boltY + 14);
    canvas.drawPath(boltPath, boltPaint);
  }

  @override
  bool shouldRepaint(_BuddyPainter old) =>
      old.mood != mood || old.blinkProgress != blinkProgress;
}

class _SparklePainter extends CustomPainter {
  final double progress;
  final Color color;

  _SparklePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final sparklePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) + (progress * pi * 2);
      final innerR = 85.0;
      final outerR = 100.0;
      final twinkle = (sin(progress * pi * 4 + i) + 1) / 2;
      final r = innerR + (outerR - innerR) * twinkle;

      final x1 = cx + cos(angle) * r;
      final y1 = cy + sin(angle) * r;

      final starPaint = Paint()
        ..color = color.withValues(alpha: 0.4 + twinkle * 0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x1, y1), 2 + twinkle * 2, starPaint);

      final starAngle = angle + pi / 4;
      final sx = cx + cos(starAngle) * (r - 10);
      final sy = cy + sin(starAngle) * (r - 10);
      _drawMiniStar(canvas, sx, sy, 4 + twinkle * 2, sparklePaint);
    }
  }

  void _drawMiniStar(Canvas canvas, double x, double y, double r, Paint paint) {
    final path = Path()
      ..moveTo(x, y - r)
      ..lineTo(x + r * 0.3, y - r * 0.3)
      ..lineTo(x + r, y)
      ..lineTo(x + r * 0.3, y + r * 0.3)
      ..lineTo(x, y + r)
      ..lineTo(x - r * 0.3, y + r * 0.3)
      ..lineTo(x - r, y)
      ..lineTo(x - r * 0.3, y - r * 0.3)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.progress != progress;
}
