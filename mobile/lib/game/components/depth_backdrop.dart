import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../theme/mario_theme.dart';
import '../mario_game.dart';

/// Multi-layer parallax sky + hills for a 2.5D depth feel.
class DepthBackdrop extends PositionComponent with HasGameReference<MarioGame> {
  DepthBackdrop()
      : super(
          position: Vector2.zero(),
          size: Vector2(8000, 900),
          priority: -40,
        );

  double _t = 0;

  @override
  void update(double dt) {
    _t += dt;
  }

  @override
  void render(Canvas canvas) {
    final cam = game.cameraX;
    final w = size.x;
    final h = size.y;

    // Sky gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2E9DE0),
            Color(0xFF6EC8F5),
            Color(0xFFB8ECFF),
            Color(0xFF9FE07A),
          ],
          stops: [0, 0.35, 0.68, 1],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Far mountains (slow parallax)
    _drawHills(
      canvas,
      cam * 0.15,
      baseY: h * 0.52,
      amp: 70,
      color: const Color(0xFF5BA3D9).withValues(alpha: 0.55),
      seed: 1,
    );

    // Mid hills
    _drawHills(
      canvas,
      cam * 0.35,
      baseY: h * 0.62,
      amp: 55,
      color: const Color(0xFF4CAF50).withValues(alpha: 0.45),
      seed: 2,
    );

    // Near grass ridge
    _drawHills(
      canvas,
      cam * 0.55,
      baseY: h * 0.72,
      amp: 40,
      color: const Color(0xFF43B047).withValues(alpha: 0.75),
      seed: 3,
    );

    // Floating depth clouds (very slow)
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    for (var i = 0; i < 10; i++) {
      final x = ((i * 420.0) - cam * (0.08 + (i % 3) * 0.04) + _t * (4 + i % 3)) % 2200;
      final y = 40.0 + (i * 37 % 120) + sin(_t * 0.6 + i) * 6;
      _cloud(canvas, Offset(x - 100, y), 0.7 + (i % 3) * 0.25, cloudPaint);
    }

    // Ground plane strip with perspective lines
    final groundTop = h * 0.78;
    canvas.drawRect(
      Rect.fromLTWH(0, groundTop, w, h - groundTop),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF6DD66D),
            Color.lerp(MarioColors.green, MarioColors.brown, 0.35)!,
            const Color(0xFF8B5A2B),
          ],
        ).createShader(Rect.fromLTWH(0, groundTop, w, h - groundTop)),
    );

    // Perspective dashes on ground
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 2;
    for (var i = 0; i < 40; i++) {
      final gx = i * 160.0 - (cam * 0.9) % 160;
      canvas.drawLine(
        Offset(gx, groundTop + 8),
        Offset(gx + 40, h),
        dashPaint,
      );
    }
  }

  void _drawHills(
    Canvas canvas,
    double offset, {
    required double baseY,
    required double amp,
    required Color color,
    required int seed,
  }) {
    final path = Path()..moveTo(-50, size.y);
    path.lineTo(-50, baseY);
    for (var x = 0.0; x <= size.x + 100; x += 80) {
      final wx = x + offset;
      final y = baseY -
          amp *
              (0.55 +
                  0.45 *
                      sin(wx * 0.008 + seed) *
                      cos(wx * 0.003 + seed * 1.7));
      path.lineTo(x, y);
    }
    path.lineTo(size.x + 50, size.y);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _cloud(Canvas canvas, Offset o, double s, Paint paint) {
    canvas.drawOval(Rect.fromCenter(center: o, width: 90 * s, height: 34 * s), paint);
    canvas.drawCircle(o.translate(-22 * s, -2), 20 * s, paint);
    canvas.drawCircle(o.translate(20 * s, -8), 24 * s, paint);
  }
}
