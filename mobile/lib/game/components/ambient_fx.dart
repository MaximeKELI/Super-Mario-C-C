import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../pipeleap_game.dart';

/// Foreground grass, bushes that rustle near the player, pollen, ground sparkles.
class AmbientFx extends PositionComponent with HasGameReference<PipeLeapGame> {
  AmbientFx({required this.levelEndX})
      : super(
          position: Vector2.zero(),
          size: Vector2(levelEndX + 400, 900),
          priority: 25,
        );

  final double levelEndX;
  double _t = 0;
  final Random _rng = Random(7);
  late final List<_Bush> _bushes;
  late final List<_Pollen> _pollen;
  late final List<_Sparkle> _sparkles;
  late final List<_GrassBlade> _grass;

  @override
  Future<void> onLoad() async {
    _bushes = List.generate(18, (i) {
      final x = 80.0 + i * ((levelEndX + 200) / 18) + _rng.nextDouble() * 40;
      return _Bush(x, 520 + _rng.nextDouble() * 30, 28 + _rng.nextDouble() * 18);
    });
    _pollen = List.generate(28, (_) {
      return _Pollen(
        _rng.nextDouble() * (levelEndX + 400),
        80 + _rng.nextDouble() * 420,
        8 + _rng.nextDouble() * 18,
        0.4 + _rng.nextDouble() * 0.8,
      );
    });
    _sparkles = List.generate(20, (_) {
      return _Sparkle(
        _rng.nextDouble() * (levelEndX + 200),
        540 + _rng.nextDouble() * 40,
        _rng.nextDouble() * pi * 2,
      );
    });
    _grass = List.generate(60, (i) {
      final x = i * ((levelEndX + 300) / 60) + _rng.nextDouble() * 12;
      return _GrassBlade(x, 10 + _rng.nextDouble() * 14, _rng.nextDouble() * pi);
    });
  }

  @override
  void update(double dt) {
    _t += dt;
    final player = game.player;
    for (final b in _bushes) {
      final near = (player.absoluteCenter.x - b.x).abs() < 70 &&
          (player.position.y + player.size.y - b.y).abs() < 60;
      b.rustle += ((near ? 1.0 : 0.0) - b.rustle) * 8 * dt;
    }
    for (final p in _pollen) {
      p.x += p.drift * dt * 12 + sin(_t * p.speed + p.x * 0.01) * 6 * dt;
      p.y += cos(_t * p.speed * 0.7) * 10 * dt;
      if (p.x < game.cameraX - 80) p.x = game.cameraX + 900;
      if (p.x > game.cameraX + 1000) p.x = game.cameraX - 40;
    }
  }

  @override
  void render(Canvas canvas) {
    final cam = game.cameraX;
    // Cull-ish: only draw near camera window
    final left = cam - 40;
    final right = cam + 920;

    // Ground sparkles
    for (final s in _sparkles) {
      if (s.x < left || s.x > right) continue;
      final a = (0.15 + 0.35 * ((sin(_t * 3 + s.phase) + 1) / 2));
      canvas.drawCircle(
        Offset(s.x, s.y),
        1.8 + sin(_t * 4 + s.phase),
        Paint()..color = Colors.white.withValues(alpha: a),
      );
    }

    // Mid bushes (behind player visually via soft alpha)
    for (final b in _bushes) {
      if (b.x < left - 40 || b.x > right + 40) continue;
      _drawBush(canvas, b);
    }

    // Pollen / dust motes
    for (final p in _pollen) {
      if (p.x < left || p.x > right) continue;
      canvas.drawCircle(
        Offset(p.x, p.y + sin(_t * p.speed) * 6),
        2.2,
        Paint()..color = const Color(0xFFFFF8C8).withValues(alpha: 0.45),
      );
    }

    // Foreground grass (drawn on top due to priority)
    final wind = sin(_t * 2.2) * 0.35;
    for (final g in _grass) {
      if (g.x < left || g.x > right) continue;
      final lean = wind + sin(_t * 3 + g.phase) * 0.15;
      final path = Path()
        ..moveTo(g.x, 575)
        ..quadraticBezierTo(g.x + lean * 10, 575 - g.h * 0.55, g.x + lean * 16, 575 - g.h);
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF2E8B2E).withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawBush(Canvas canvas, _Bush b) {
    final shake = sin(_t * 18) * b.rustle * 4;
    final base = Offset(b.x + shake, b.y);
    canvas.drawOval(
      Rect.fromCenter(center: base.translate(0, 6), width: b.r * 2.2, height: 10),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    final green = Paint()..color = const Color(0xFF3FA34A);
    final dark = Paint()..color = const Color(0xFF2D7A35);
    canvas.drawCircle(base.translate(-b.r * 0.35, 0), b.r * 0.7, dark);
    canvas.drawCircle(base, b.r, green);
    canvas.drawCircle(base.translate(b.r * 0.4, -2), b.r * 0.65, green);
    if (b.rustle > 0.2) {
      canvas.drawCircle(
        base.translate(0, -b.r),
        3,
        Paint()..color = const Color(0xFF9FE07A).withValues(alpha: b.rustle * 0.6),
      );
    }
  }
}

class _Bush {
  _Bush(this.x, this.y, this.r);
  double x, y, r;
  double rustle = 0;
}

class _Pollen {
  _Pollen(this.x, this.y, this.drift, this.speed);
  double x, y, drift, speed;
}

class _Sparkle {
  _Sparkle(this.x, this.y, this.phase);
  double x, y, phase;
}

class _GrassBlade {
  _GrassBlade(this.x, this.h, this.phase);
  double x, h, phase;
}
