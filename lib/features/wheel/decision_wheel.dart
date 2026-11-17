import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'wheel_provider.dart';

class DecisionWheelPainter extends CustomPainter {
  final double rotation;
  final List<String> options;

  DecisionWheelPainter({required this.rotation, required this.options});

  static const _labelChars = ['A', 'B', 'C', 'D', 'E'];

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    final segmentAngle = 2 * pi / options.length;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    for (var i = 0; i < options.length; i++) {
      final startAngle = i * segmentAngle - pi / 2;
      final color = Color(wheelColors[i % wheelColors.length]);

      final segmentPaint = Paint()
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        startAngle,
        segmentAngle,
        true,
        segmentPaint,
      );

      final borderPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawLine(
        Offset.zero,
        Offset(cos(startAngle) * radius, sin(startAngle) * radius),
        borderPaint,
      );

      final labelAngle = startAngle + segmentAngle / 2;
      final labelRadius = radius * 0.6;
      final labelPos = Offset(
        cos(labelAngle) * labelRadius,
        sin(labelAngle) * labelRadius,
      );

      canvas.save();
      canvas.translate(labelPos.dx, labelPos.dy);
      canvas.rotate(labelAngle + pi / 2);

      final char = i < _labelChars.length ? _labelChars[i] : '${i + 1}';

      final textPainter = TextPainter(
        text: TextSpan(
          text: char,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    final outerGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = AppColors.primary
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(Offset.zero, radius, outerGlowPaint);

    final outerBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.primary;

    canvas.drawCircle(Offset.zero, radius, outerBorderPaint);

    final innerGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.secondary
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(Offset.zero, radius * 0.92, innerGlowPaint);

    final centerGlowPaint = Paint()
      ..color = AppColors.primary
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(Offset.zero, 6, centerGlowPaint);

    final centerSolidPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset.zero, 4, centerSolidPaint);

    canvas.restore();

    final pointerPaint = Paint()
      ..color = AppColors.tertiary
      ..style = PaintingStyle.fill;

    final pointerPath = Path()
      ..moveTo(center.dx, center.dy - radius - 4)
      ..lineTo(center.dx - 10, center.dy - radius - 22)
      ..lineTo(center.dx + 10, center.dy - radius - 22)
      ..close();

    canvas.drawPath(pointerPath, pointerPaint);

    final pointerGlowPaint = Paint()
      ..color = AppColors.tertiary
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(pointerPath, pointerGlowPaint);
  }

  @override
  bool shouldRepaint(DecisionWheelPainter oldDelegate) {
    return rotation != oldDelegate.rotation || options != oldDelegate.options;
  }
}
