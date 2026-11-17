import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  double maxLife;
  double size;
  Color color;
  double gravity;
  double rotation;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.size,
    required this.color,
    this.gravity = 1.0,
    this.rotation = 0.0,
  }) : maxLife = life;
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final opacity = (particle.life / particle.maxLife).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.5);

      if (particle.rotation > 0.5) {
        final half = particle.size * opacity;
        canvas.save();
        canvas.translate(particle.x, particle.y);
        canvas.rotate(pi / 4);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: half * 2,
            height: half * 2,
          ),
          paint,
        );
        canvas.restore();
      } else {
        canvas.drawCircle(
          Offset(particle.x, particle.y),
          particle.size * opacity,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => particles.isNotEmpty;
}

class ParticleSystem extends StatefulWidget {
  final bool active;
  final Offset origin;
  final int particleCount;
  final Duration duration;

  const ParticleSystem({
    super.key,
    required this.active,
    required this.origin,
    this.particleCount = 40,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();
  Duration? _lastElapsed;

  static const List<Color> _neonColors = [
    Color(0xFF39FF14),
    Color(0xFF00FFFF),
    Color(0xFFBC13FE),
    Color(0xFFFFD700),
    Color(0xFFFF6B9D),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.addListener(_updateParticles);
  }

  @override
  void didUpdateWidget(ParticleSystem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _spawnParticles();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spawnParticles() {
    _lastElapsed = null;
    _particles.clear();
    for (int i = 0; i < widget.particleCount; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 50 + _random.nextDouble() * 150;
      _particles.add(
        Particle(
          x: widget.origin.dx,
          y: widget.origin.dy,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 30,
          life: 0.8 + _random.nextDouble() * 0.7,
          size: 3 + _random.nextDouble() * 6,
          color: _neonColors[_random.nextInt(_neonColors.length)],
          gravity: 0.5 + _random.nextDouble(),
          rotation: _random.nextDouble(),
        ),
      );
    }
  }

  void _updateParticles() {
    final elapsed = _controller.lastElapsedDuration;
    if (elapsed == null) return;
    final dt = (_lastElapsed == null)
        ? 0.016
        : ((elapsed - _lastElapsed!).inMicroseconds / 1000000.0).clamp(
            0.0,
            0.05,
          );
    _lastElapsed = elapsed;
    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 80 * p.gravity * dt;
      p.life -= dt;
    }
    _particles.removeWhere((p) => p.life <= 0);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(particles: _particles),
      size: Size.infinite,
    );
  }
}
