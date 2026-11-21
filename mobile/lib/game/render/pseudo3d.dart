import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

/// Shared 2.5D drawing helpers (extrusion, shadows, bevels, glow).
class Pseudo3d {
  static const depth = 10.0;

  static void dropShadow(
    Canvas canvas,
    Rect footprint, {
    double blur = 8,
    double alpha = 0.28,
  }) {
    canvas.drawOval(
      footprint.translate(0, 2),
      Paint()
        ..color = Colors.black.withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }

  static void softGlow(
    Canvas canvas,
    Offset center,
    double radius, {
    required Color color,
    double alpha = 0.35,
  }) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.55),
    );
  }

  static void rimLight(Canvas canvas, Rect front, {double intensity = 0.4}) {
    canvas.drawLine(
      Offset(front.left + 2, front.top + 3),
      Offset(front.left + 2, front.bottom - 3),
      Paint()
        ..color = Colors.white.withValues(alpha: intensity)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  static void wetHighlight(Canvas canvas, Rect front, double t) {
    final y = front.top + 4 + sin(t * 3) * 1.5;
    canvas.drawLine(
      Offset(front.left + 6, y),
      Offset(front.right - 6, y),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22 + 0.08 * sin(t * 5))
        ..strokeWidth = 2,
    );
  }

  /// Draws a fake extruded box: back face, side, top, front.
  static void extrudedBox(
    Canvas canvas,
    Rect front, {
    required Color face,
    Color? top,
    Color? side,
    double d = depth,
    double radius = 4,
    bool glow = false,
    Color? glowColor,
    double animT = 0,
  }) {
    final topC = top ?? Color.lerp(face, Colors.white, 0.28)!;
    final sideC = side ?? Color.lerp(face, Colors.black, 0.28)!;

    dropShadow(
      canvas,
      Rect.fromCenter(
        center: Offset(front.center.dx + d * 0.2, front.bottom + 3),
        width: front.width * 0.92,
        height: 10,
      ),
      blur: 6,
      alpha: 0.22,
    );

    if (glow) {
      softGlow(
        canvas,
        front.center,
        front.width * 0.75,
        color: glowColor ?? face,
        alpha: 0.22,
      );
    }

    final topPath = Path()
      ..moveTo(front.left, front.top)
      ..lineTo(front.left + d, front.top - d)
      ..lineTo(front.right + d, front.top - d)
      ..lineTo(front.right, front.top)
      ..close();
    canvas.drawPath(topPath, Paint()..color = topC);

    final sidePath = Path()
      ..moveTo(front.right, front.top)
      ..lineTo(front.right + d, front.top - d)
      ..lineTo(front.right + d, front.bottom - d)
      ..lineTo(front.right, front.bottom)
      ..close();
    canvas.drawPath(sidePath, Paint()..color = sideC);

    final rrect = RRect.fromRectAndRadius(front, Radius.circular(radius));
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(face, Colors.white, 0.18)!,
            face,
            Color.lerp(face, Colors.black, 0.12)!,
          ],
        ).createShader(front),
    );

    rimLight(canvas, front);
    wetHighlight(canvas, front, animT);

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  static void cylinderCoin(Canvas canvas, double radius, double squashX, {double t = 0}) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(2, radius * 0.85), width: radius * 1.6, height: radius * 0.45),
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    softGlow(
      canvas,
      Offset.zero,
      radius * 1.4,
      color: const Color(0xFFFBD000),
      alpha: 0.2 + 0.1 * sin(t * 4),
    );

    canvas.save();
    canvas.scale(squashX, 1);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(3, 1), width: radius * 2, height: radius * 2),
      Paint()..color = const Color(0xFFC99700),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * 2),
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFF3A0), Color(0xFFFBD000), Color(0xFFE0A800)],
          stops: [0.15, 0.55, 1],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * 2),
      Paint()
        ..color = const Color(0xFFFFF8C8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(0, -radius * 0.45),
      Offset(0, radius * 0.45),
      Paint()
        ..color = const Color(0xFFC99700)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  static void crackLines(Canvas canvas, Rect rect, int hits, {int maxHits = 3}) {
    if (hits <= 0) return;
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35 + hits * 0.12)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    for (var i = 0; i < hits; i++) {
      final a = -0.6 + i * 0.7;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + cos(a) * rect.width * 0.42, cy + sin(a) * rect.height * 0.42),
        paint,
      );
      if (i < maxHits - 1) {
        canvas.drawLine(
          Offset(cx + cos(a) * rect.width * 0.2, cy + sin(a) * rect.height * 0.2),
          Offset(
            cx + cos(a + 0.4) * rect.width * 0.35,
            cy + sin(a + 0.4) * rect.height * 0.35,
          ),
          paint,
        );
      }
    }
  }
}
