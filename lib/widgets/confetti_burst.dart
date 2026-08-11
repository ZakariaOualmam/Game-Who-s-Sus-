import 'dart:math';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// One-shot falling confetti burst used on the winner screen.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({
    super.key,
    this.colors = const [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
    ],
    this.particleCount = 70,
    this.duration = const Duration(milliseconds: 2400),
  });

  final List<Color> colors;
  final int particleCount;
  final Duration duration;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(
      widget.particleCount,
      (_) => _Particle(
        x: rng.nextDouble(),
        delay: rng.nextDouble() * 0.35,
        fall: 0.35 + rng.nextDouble() * 0.65,
        drift: (rng.nextDouble() - 0.5) * 0.6,
        spin: (rng.nextDouble() - 0.5) * 6,
        width: 6 + rng.nextDouble() * 7,
        height: 10 + rng.nextDouble() * 8,
        colorIndex: rng.nextInt(widget.colors.length),
      ),
    );
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(
            progress: _controller.value,
            particles: _particles,
            colors: widget.colors,
          ),
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.x,
    required this.delay,
    required this.fall,
    required this.drift,
    required this.spin,
    required this.width,
    required this.height,
    required this.colorIndex,
  });

  final double x;
  final double delay;
  final double fall;
  final double drift;
  final double spin;
  final double width;
  final double height;
  final int colorIndex;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.progress,
    required this.particles,
    required this.colors,
  });

  final double progress;
  final List<_Particle> particles;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    for (final particle in particles) {
      final t = ((progress - particle.delay) / (1 - particle.delay))
          .clamp(0.0, 1.0);
      if (t <= 0) continue;

      final x = particle.x * size.width + particle.drift * t * size.width;
      final y = t * (size.height + 40) - 20;
      final alpha = (1 - t).clamp(0.0, 1.0);
      final angle = particle.spin * t * 2 * pi;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.width,
            height: particle.height,
          ),
          const Radius.circular(2),
        ),
        Paint()
          ..color = colors[particle.colorIndex].withValues(alpha: alpha),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
