import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../theme/mario_theme.dart';
import '../mario_game.dart';
import 'player.dart';

class SpikeComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<MarioGame> {
  SpikeComponent(SpikeDef def)
      : super(position: Vector2(def.x, def.y), size: Vector2(def.w, def.h));

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent && !other.dead && !other.invincible) {
      other.shrink();
      game.juice.shake(intensity: 10, duration: 0.35);
      if (other.dead) game.onPlayerDied();
    }
  }

  @override
  void render(Canvas canvas) {
    final path = Path();
    const spikes = 5;
    final step = size.x / spikes;
    path.moveTo(0, size.y);
    for (var i = 0; i < spikes; i++) {
      path.lineTo(i * step + step / 2, 0);
      path.lineTo((i + 1) * step, size.y);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF555555));
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}

class CloudComponent extends PositionComponent {
  final double speed;
  CloudComponent(CloudDef def)
      : speed = 12 + def.w * 0.05,
        super(position: Vector2(def.x, def.y), size: Vector2(def.w, def.h), priority: -5);

  @override
  void update(double dt) {
    position.x -= speed * dt * 0.15;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawOval(Rect.fromLTWH(0, size.y * 0.3, size.x, size.y * 0.6), paint);
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.35), size.y * 0.4, paint);
    canvas.drawCircle(Offset(size.x * 0.6, size.y * 0.25), size.y * 0.45, paint);
  }
}

class CheckpointComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<MarioGame> {
  bool activated = false;
  double wave = 0;

  CheckpointComponent(CheckpointDef def)
      : super(position: Vector2(def.x, def.y), size: Vector2(20, 60));

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) => wave += dt * 4;

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent && !activated) {
      activated = true;
      game.setCheckpoint(position.x, position.y);
      game.juice.burst(absoluteCenter, color: MarioColors.green, count: 16);
      game.juice.scorePopup(absoluteCenter, 'SAVE!');
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(8, 0, 4, 60), Paint()..color = MarioColors.brown);
    final flagColor = activated ? MarioColors.green : MarioColors.red;
    final path = Path()
      ..moveTo(12, 4 + sin(wave) * 2)
      ..lineTo(36, 16)
      ..lineTo(12, 28)
      ..close();
    canvas.drawPath(path, Paint()..color = flagColor);
  }
}

class PipeComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<MarioGame> {
  final double destX, destY;
  double cooldown = 0;

  PipeComponent(PipeDef def)
      : destX = def.destX,
        destY = def.destY,
        super(position: Vector2(def.x, def.y), size: Vector2(def.w, def.h));

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) => cooldown = (cooldown - dt).clamp(0, 2);

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is PlayerComponent && cooldown <= 0 && other.wantJump == false) {
      // enter when standing on top and pressing down-ish (left+right idle near center)
      final onTop = other.position.y + other.size.y <= position.y + 8;
      if (onTop && other.onGround && other.wantRight == false && other.wantLeft == false) {
        // require holding jump briefly while on pipe - use shoot as enter for mobile
      }
    }
  }

  void tryEnter(PlayerComponent player) {
    if (cooldown > 0) return;
    final overlapping = player.toRect().overlaps(toRect().inflate(8));
    if (!overlapping) return;
    cooldown = 1.2;
    player.position = Vector2(destX, destY);
    game.juice.burst(player.absoluteCenter, color: MarioColors.pipe, count: 12);
    game.juice.shake(intensity: 3, duration: 0.2);
  }

  @override
  void render(Canvas canvas) {
    final body = RRect.fromRectAndRadius(size.toRect(), const Radius.circular(4));
    canvas.drawRRect(body, Paint()..color = MarioColors.pipe);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-4, 0, size.x + 8, 16),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF2E8B2E),
    );
  }
}
