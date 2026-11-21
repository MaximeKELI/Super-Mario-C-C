import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../pipeleap_game.dart';

enum ParticleKind { chunk, dust, spark, leaf, ring, shockwave }

class JuiceSystem extends Component with HasGameReference<PipeLeapGame> {
  static const maxParticles = 120;

  double hitStop = 0;
  double shakeTime = 0;
  double shakeIntensity = 0;
  double damageFlash = 0;
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

  void flashDamage([double duration = 0.22]) {
    damageFlash = max(damageFlash, duration);
  }

  void _add(JuiceParticle p) {
    if (particles.length >= maxParticles) {
      particles.removeAt(0);
    }
    particles.add(p);
  }

  void burst(Vector2 at, {Color color = AppColors.yellow, int count = 22}) {
    final n = min(count, maxParticles - particles.length + count);
    for (var i = 0; i < n; i++) {
      final angle = _rng.nextDouble() * pi * 2;
      final speed = 120 + _rng.nextDouble() * 280;
      _add(JuiceParticle(
        pos: at.clone(),
        vel: Vector2(cos(angle), sin(angle)) * speed,
        life: 0.55 + _rng.nextDouble() * 0.65,
        color: color,
        size: 4 + _rng.nextDouble() * 7,
        spin: (_rng.nextDouble() - 0.5) * 14,
        kind: ParticleKind.chunk,
      ));
    }
  }

  void dust(Vector2 at, {int count = 6}) {
    for (var i = 0; i < count; i++) {
      _add(JuiceParticle(
        pos: at.clone() + Vector2((_rng.nextDouble() - 0.5) * 16, 0),
        vel: Vector2((_rng.nextDouble() - 0.5) * 60, -20 - _rng.nextDouble() * 40),
        life: 0.35 + _rng.nextDouble() * 0.35,
        color: const Color(0xFFC4A882),
        size: 3 + _rng.nextDouble() * 4,
        spin: 0,
        kind: ParticleKind.dust,
        gravity: 40,
      ));
    }
  }

  void sparks(Vector2 at, {int count = 10, Color color = const Color(0xFFFFE066)}) {
    for (var i = 0; i < count; i++) {
      final angle = -pi / 2 + (_rng.nextDouble() - 0.5) * pi;
      _add(JuiceParticle(
        pos: at.clone(),
        vel: Vector2(cos(angle), sin(angle)) * (160 + _rng.nextDouble() * 180),
        life: 0.25 + _rng.nextDouble() * 0.3,
        color: color,
        size: 2 + _rng.nextDouble() * 3,
        spin: 0,
        kind: ParticleKind.spark,
        gravity: 200,
      ));
    }
  }

  void leaves(Vector2 at, {int count = 8}) {
    for (var i = 0; i < count; i++) {
      final angle = _rng.nextDouble() * pi * 2;
      _add(JuiceParticle(
        pos: at.clone(),
        vel: Vector2(cos(angle), sin(angle) - 0.4) * (40 + _rng.nextDouble() * 70),
        life: 0.7 + _rng.nextDouble() * 0.5,
        color: i.isEven ? const Color(0xFF6DD66D) : const Color(0xFF43B047),
        size: 4 + _rng.nextDouble() * 3,
        spin: (_rng.nextDouble() - 0.5) * 10,
        kind: ParticleKind.leaf,
        gravity: 60,
      ));
    }
  }

  void ring(Vector2 at, {Color color = AppColors.yellow, int count = 20}) {
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * pi * 2;
      _add(JuiceParticle(
        pos: at.clone(),
        vel: Vector2(cos(angle), sin(angle)) * 220,
        life: 0.7,
        color: color,
        size: 5,
        spin: 0,
        kind: ParticleKind.ring,
        gravity: 0,
      ));
    }
  }

  void shockwave(Vector2 at) {
    _add(JuiceParticle(
      pos: at.clone(),
      vel: Vector2.zero(),
      life: 0.45,
      color: Colors.white,
      size: 8,
      spin: 0,
      kind: ParticleKind.shockwave,
      gravity: 0,
    ));
  }

  void scorePopup(Vector2 at, String text) {
    _add(JuiceParticle(
      pos: at.clone(),
      vel: Vector2(0, -110),
      life: 1.15,
      color: AppColors.cream,
      size: 0,
      label: text,
      spin: 0,
      kind: ParticleKind.chunk,
      gravity: 0,
    ));
  }

  Vector2 cameraOffset() {
    if (shakeTime <= 0) return Vector2.zero();
    final decay = shakeTime.clamp(0.0, 1.0);
    return Vector2(
      (_rng.nextDouble() - 0.5) * 2 * shakeIntensity * (0.5 + decay),
      (_rng.nextDouble() - 0.5) * 2 * shakeIntensity * (0.5 + decay),
    );
  }

  @override
  void update(double dt) {
    if (hitStop > 0) hitStop -= dt;
    if (damageFlash > 0) damageFlash -= dt;
    if (shakeTime > 0) {
      shakeTime -= dt;
      shakeIntensity *= 0.88;
    }
    for (final p in particles) {
      p.life -= dt;
      p.pos += p.vel * dt;
      p.vel.y += p.gravity * dt;
      p.vel *= p.kind == ParticleKind.dust ? 0.92 : 0.985;
      p.angle += p.spin * dt;
      if (p.kind == ParticleKind.shockwave) {
        p.size += 420 * dt;
      }
    }
    particles.removeWhere((p) => p.life <= 0);
  }

  @override
  void render(Canvas canvas) {
    for (final p in particles) {
      final alpha = p.life.clamp(0.0, 1.0);
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
                Shadow(color: AppColors.yellow, blurRadius: 10),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
        continue;
      }

      canvas.save();
      canvas.translate(p.pos.x, p.pos.y);
      canvas.rotate(p.angle);

      switch (p.kind) {
        case ParticleKind.shockwave:
          canvas.drawCircle(
            Offset.zero,
            p.size,
            Paint()
              ..color = p.color.withValues(alpha: alpha * 0.35)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
        case ParticleKind.dust:
          canvas.drawOval(
            Rect.fromCenter(center: Offset.zero, width: p.size * 2.2 * alpha, height: p.size * alpha),
            Paint()..color = p.color.withValues(alpha: alpha * 0.55),
          );
        case ParticleKind.spark:
          canvas.drawLine(
            Offset(-p.size, 0),
            Offset(p.size * 2, 0),
            Paint()
              ..color = p.color.withValues(alpha: alpha)
              ..strokeWidth = 2
              ..strokeCap = StrokeCap.round,
          );
        case ParticleKind.leaf:
          canvas.drawOval(
            Rect.fromCenter(center: Offset.zero, width: p.size * 2, height: p.size),
            Paint()..color = p.color.withValues(alpha: alpha),
          );
        case ParticleKind.ring:
        case ParticleKind.chunk:
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
      }
      canvas.restore();
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
  ParticleKind kind;
  double gravity;

  JuiceParticle({
    required this.pos,
    required this.vel,
    required this.life,
    required this.color,
    required this.size,
    this.label,
    this.spin = 0,
    this.kind = ParticleKind.chunk,
    this.gravity = 360,
  }) : angle = 0;
}
