import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../pipeleap_game.dart';

/// Multi-layer parallax sky + hills + sun/fog for a rich 2.5D diorama.
class DepthBackdrop extends PositionComponent with HasGameReference<PipeLeapGame> {
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
            Color(0xFF1E78C8),
            Color(0xFF5EC8F8),
            Color(0xFFB8ECFF),
            Color(0xFF9FE07A),
          ],
          stops: [0, 0.32, 0.66, 1],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Sun with soft bloom (parallax slow)
    final sunX = 620 - cam * 0.04 + sin(_t * 0.15) * 8;
    final sunY = 90 + cos(_t * 0.12) * 4;
    canvas.drawCircle(
      Offset(sunX, sunY),
      55,
      Paint()
        ..color = const Color(0xFFFFF3A0).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );
    canvas.drawCircle(
      Offset(sunX, sunY),
      28,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFFFF0), Color(0xFFFFE066), Color(0x00FFC107)],
        ).createShader(Rect.fromCircle(center: Offset(sunX, sunY), radius: 28)),
    );

    // Distant mountain silhouettes
    _drawHills(
      canvas,
      cam * 0.08,
      baseY: h * 0.48,
      amp: 90,
      color: const Color(0xFF3A6EA5).withValues(alpha: 0.4),
      seed: 0,
    );

    // Far mountains
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

    // Atmospheric fog band
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.58, w, h * 0.18),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.14),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.58, w, h * 0.18)),
    );

    // Floating depth clouds
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    for (var i = 0; i < 12; i++) {
      final x = ((i * 420.0) - cam * (0.08 + (i % 3) * 0.04) + _t * (4 + i % 3)) % 2200;
      final y = 40.0 + (i * 37 % 120) + sin(_t * 0.6 + i) * 6;
      _cloud(canvas, Offset(x - 100, y), 0.7 + (i % 3) * 0.25, cloudPaint);
    }

    // Wind streaks (subtle)
    final windPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.5;
    for (var i = 0; i < 8; i++) {
      final wx = (i * 280.0 - (_t * 40) + cam * 0.2) % 1600;
      final wy = 160.0 + i * 28;
      canvas.drawLine(Offset(wx, wy), Offset(wx + 50, wy - 4), windPaint);
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
            Color.lerp(AppColors.green, AppColors.brown, 0.35)!,
            const Color(0xFF8B5A2B),
          ],
        ).createShader(Rect.fromLTWH(0, groundTop, w, h - groundTop)),
    );

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
