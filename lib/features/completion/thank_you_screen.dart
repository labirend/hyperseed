import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/task.dart';
import '../../shared/widgets/neon_button.dart';
import 'particle_painter.dart';

class ThankYouScreen extends StatefulWidget {
  final List<Task> completedTasks;

  const ThankYouScreen({super.key, required this.completedTasks});

  @override
  State<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen>
    with TickerProviderStateMixin {
  bool _showParticles = false;
  bool _showMessage = false;
  Offset _particleOrigin = Offset.zero;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _particleOrigin = Offset(size.width / 2, size.height * 0.4);
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onThankYouPressed() {
    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0).then((_) {
      setState(() {
        _showParticles = true;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _showMessage = true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final shake =
                  sin(_shakeController.value * pi * 6) *
                  8 *
                  _shakeController.value;
              return Transform.translate(
                offset: Offset(shake, 0),
                child: child,
              );
            },
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(),
                    if (_showMessage)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: AppColors.primary,
                              size: 48,
                            ).animate().scale(
                              begin: const Offset(0, 0),
                              end: const Offset(1, 1),
                              duration: 600.ms,
                              curve: Curves.elasticOut,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l10n.thankYouMessageNew,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.onBackground,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                                letterSpacing: 0.3,
                              ),
                            ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                          ],
                        ),
                      )
                    else ...[
                      Text(
                        '${widget.completedTasks.length} ${l10n.tasksCount}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 16,
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 16),
                      ...widget.completedTasks.map(
                        (task) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child:
                              Text(
                                task.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 16,
                                ),
                              ).animate().fadeIn(
                                delay: Duration(
                                  milliseconds:
                                      widget.completedTasks.indexOf(task) * 100,
                                ),
                                duration: 400.ms,
                              ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      NeonButton(
                        text: l10n.thankYouButtonMain,
                        pulse: true,
                        color: AppColors.primary,
                        width: double.infinity,
                        height: 72,
                        onPressed: _onThankYouPressed,
                      ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                    ],
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
          if (_showParticles)
            ParticleSystem(
              active: true,
              origin: _particleOrigin,
              particleCount: 60,
              duration: const Duration(milliseconds: 2000),
            ),
          if (_showMessage)
            Positioned(
              bottom: 48,
              left: 24,
              right: 24,
              child: NeonButton(
                text: l10n.backToTasks,
                color: AppColors.secondary,
                width: double.infinity,
                onPressed: () => Navigator.of(context).pop(),
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
            ),
        ],
      ),
    );
  }
}
