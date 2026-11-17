import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final bool pulse;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool enabled;

  const NeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.primary,
    this.pulse = false,
    this.width,
    this.height,
    this.icon,
    this.enabled = true,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.pulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NeonButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !oldWidget.pulse) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.pulse && oldWidget.pulse) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.enabled
        ? widget.color
        : widget.color.withValues(alpha: 0.3);

    final button = AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glowIntensity = widget.pulse
            ? 0.4 + (_pulseController.value * 0.6)
            : 0.6;
        return Container(
          width: widget.width,
          height: widget.height ?? 56,
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: effectiveColor, width: 2),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: effectiveColor.withValues(
                        alpha: glowIntensity * 0.5,
                      ),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: effectiveColor.withValues(
                        alpha: glowIntensity * 0.3,
                      ),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.enabled
              ? () {
                  HapticFeedback.heavyImpact();
                  widget.onPressed();
                }
              : null,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: effectiveColor, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    color: effectiveColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return button
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }
}
