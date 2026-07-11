import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../theme/mario_theme.dart';
import '../mario_game.dart';

class JuiceSystem extends Component with HasGameReference<MarioGame> {
  double hitStop = 0;
  double shakeTime = 0;
  double shakeIntensity = 0;
  final List<JuiceParticle> particles = [];
  final Random _rng = Random();

  bool get isFrozen => hitStop > 0;

  void triggerHitStop([double duration = 0.09]) {
    hitStop = max(hitStop, duration);
  }

  void shake({double intensity = 10, double duration = 0.32}) {
    shakeIntensity = max(shakeIntensity, intensity);
    shakeTime = max(shakeTime, duration);
  }

  void burst(Vector2 at, {Color color = MarioColors.yellow, int count = 22}) {
    for (var i = 0; i < count; i++) {
      final angle = _rng.nextDouble() * pi * 2;
      final speed = 120 + _rng.nextDouble() * 280;
      particles.add(JuiceParticle(
        pos: at.clone(),
        vel: Vector2(cos(angle), sin(angle)) * speed,
        life: 0.55 + _rng.nextDouble() * 0.65,
        color: color,
        size: 4 + _rng.nextDouble() * 7,
        spin: (_rng.nextDouble() - 0.5) * 14,
      ));
    }
  }

  void ring(Vector2 at, {Color color = MarioColors.yellow, int count = 20}) {
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * pi * 2;
      particles.add(JuiceParticle(
        pos: at.clone(),
        vel: Vector2(cos(angle), sin(angle)) * 220,
        life: 0.7,
        color: color,
        size: 5,
        spin: 0,
      ));
    }
  }

  void scorePopup(Vector2 at, String text) {
    particles.add(JuiceParticle(
      pos: at.clone(),
      vel: Vector2(0, -110),
      life: 1.15,
      color: MarioColors.cream,
      size: 0,
      label: text,
      spin: 0,
    ));
  }

  Vector2 cameraOffset() {
    if (shakeTime <= 0) return Vector2.zero();
    final decay = (shakeTime).clamp(0.0, 1.0);
    return Vector2(
      (_rng.nextDouble() - 0.5) * 2 * shakeIntensity * (0.5 + decay),
      (_rng.nextDouble() - 0.5) * 2 * shakeIntensity * (0.5 + decay),
    );
  }

  @override
  void update(double dt) {
    if (hitStop > 0) hitStop -= dt;
    if (shakeTime > 0) {
      shakeTime -= dt;
      shakeIntensity *= 0.88;
    }
    for (final p in particles) {
      p.life -= dt;
      p.pos += p.vel * dt;
      p.vel.y += 360 * dt;
      p.vel *= 0.985;
      p.angle += p.spin * dt;
    }
    particles.removeWhere((p) => p.life <= 0);
  }

  @override
  void render(Canvas canvas) {
    for (final p in particles) {
      final alpha = (p.life.clamp(0.0, 1.0));
      if (p.label != null) {
        final scale = 1.0 + (1.0 - alpha) * 0.6;
        canvas.save();
        canvas.translate(p.pos.x, p.pos.y);
        canvas.scale(scale);
        final tp = TextPainter(
          text: TextSpan(
            text: p.label,
            style: TextStyle(
              color: p.color.withValues(alpha: alpha),
              fontSize: 26,
              fontWeight: FontWeight.w900,
              shadows: const [
                Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(2, 2)),
                Shadow(color: MarioColors.yellow, blurRadius: 10),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
      } else {
        canvas.save();
        canvas.translate(p.pos.x, p.pos.y);
        canvas.rotate(p.angle);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size * 2 * alpha, height: p.size * alpha),
            const Radius.circular(2),
          ),
          Paint()..color = p.color.withValues(alpha: alpha),
        );
        canvas.drawCircle(
          Offset.zero,
          p.size * 0.55 * alpha,
          Paint()..color = Colors.white.withValues(alpha: alpha * 0.55),
        );
        canvas.restore();
      }
    }
  }
}

class JuiceParticle {
  Vector2 pos;
  Vector2 vel;
  double life;
  Color color;
  double size;
  String? label;
  double spin;
  double angle;

  JuiceParticle({
    required this.pos,
    required this.vel,
    required this.life,
    required this.color,
    required this.size,
    this.label,
    this.spin = 0,
  }) : angle = 0;
}
