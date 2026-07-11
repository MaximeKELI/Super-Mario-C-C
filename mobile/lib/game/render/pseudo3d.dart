import 'dart:ui';

import 'package:flutter/material.dart';

/// Shared 2.5D drawing helpers (extrusion, shadows, bevels).
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

  /// Draws a fake extruded box: back face, side, top, front.
  static void extrudedBox(
    Canvas canvas,
    Rect front, {
    required Color face,
    Color? top,
    Color? side,
    double d = depth,
    double radius = 4,
  }) {
    final topC = top ?? Color.lerp(face, Colors.white, 0.28)!;
    final sideC = side ?? Color.lerp(face, Colors.black, 0.28)!;

    // Ground contact shadow
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

    // Top face (quad skewed up-right)
    final topPath = Path()
      ..moveTo(front.left, front.top)
      ..lineTo(front.left + d, front.top - d)
      ..lineTo(front.right + d, front.top - d)
      ..lineTo(front.right, front.top)
      ..close();
    canvas.drawPath(topPath, Paint()..color = topC);

    // Right side face
    final sidePath = Path()
      ..moveTo(front.right, front.top)
      ..lineTo(front.right + d, front.top - d)
      ..lineTo(front.right + d, front.bottom - d)
      ..lineTo(front.right, front.bottom)
      ..close();
    canvas.drawPath(sidePath, Paint()..color = sideC);

    // Front face
    final rrect = RRect.fromRectAndRadius(front, Radius.circular(radius));
    canvas.drawRRect(rrect, Paint()..color = face);

    // Bevel highlight on front top edge
    canvas.drawLine(
      Offset(front.left + 3, front.top + 2),
      Offset(front.right - 3, front.top + 2),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 2,
    );

    // Soft outline
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  static void cylinderCoin(Canvas canvas, double radius, double squashX) {
    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(2, radius * 0.85), width: radius * 1.6, height: radius * 0.45),
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.save();
    canvas.scale(squashX, 1);

    // Edge (thickness)
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(3, 1), width: radius * 2, height: radius * 2),
      Paint()..color = const Color(0xFFC99700),
    );
    // Face
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
}
