import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../theme/mario_theme.dart';
import '../mario_game.dart';

class JuiceSystem extends Component with HasGameReference<MarioGame> {
  double hitStop = 0;
  double shakeTime = 0;
  double shakeIntensity = 0;
  final List<_Particle> particles = [];
  final Random _rng = Random();

  bool get isFrozen => hitStop > 0;

  void triggerHitStop([double duration = 0.06]) {
    hitStop = max(hitStop, duration);
  }

  void shake({double intensity = 6, double duration = 0.25}) {
    shakeIntensity = intensity;
    shakeTime = duration;
  }

  void burst(Vector2 at, {Color color = MarioColors.yellow, int count = 14}) {
    for (var i = 0; i < count; i++) {
      final angle = _rng.nextDouble() * pi * 2;
      final speed = 80 + _rng.nextDouble() * 160;
      particles.add(_Particle(
        pos: at.clone(),
        vel: Vector2(cos(angle), sin(angle)) * speed,
        life: 0.4 + _rng.nextDouble() * 0.5,
        color: color,
        size: 3 + _rng.nextDouble() * 4,
      ));
    }
  }

  void scorePopup(Vector2 at, String text) {
    particles.add(_Particle(
      pos: at.clone(),
      vel: Vector2(0, -60),
      life: 0.9,
      color: MarioColors.cream,
      size: 0,
      label: text,
    ));
  }

  Vector2 cameraOffset() {
    if (shakeTime <= 0) return Vector2.zero();
    return Vector2(
      (_rng.nextDouble() - 0.5) * 2 * shakeIntensity,
      (_rng.nextDouble() - 0.5) * 2 * shakeIntensity,
    );
  }

  @override
  void update(double dt) {
    if (hitStop > 0) hitStop -= dt;
    if (shakeTime > 0) {
      shakeTime -= dt;
      shakeIntensity *= 0.92;
    }
    for (final p in particles) {
      p.life -= dt;
      p.pos += p.vel * dt;
      p.vel.y += 280 * dt;
    }
    particles.removeWhere((p) => p.life <= 0);
  }

  @override
  void render(Canvas canvas) {
    for (final p in particles) {
      final alpha = p.life.clamp(0.0, 1.0);
      if (p.label != null) {
        final tp = TextPainter(
          text: TextSpan(
            text: p.label,
            style: TextStyle(
              color: p.color.withValues(alpha: alpha),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(p.pos.x - tp.width / 2, p.pos.y));
      } else {
        canvas.drawCircle(
          Offset(p.pos.x, p.pos.y),
          p.size * alpha,
          Paint()..color = p.color.withValues(alpha: alpha),
        );
      }
    }
  }
}

class _Particle {
  Vector2 pos;
  Vector2 vel;
  double life;
  Color color;
  double size;
  String? label;

  _Particle({
    required this.pos,
    required this.vel,
    required this.life,
    required this.color,
    required this.size,
    this.label,
  });
}
