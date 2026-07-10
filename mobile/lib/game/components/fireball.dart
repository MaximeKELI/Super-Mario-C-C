import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../theme/mario_theme.dart';
import '../mario_game.dart';
import 'enemy.dart';
import 'platform_block.dart';

class FireballComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<MarioGame> {
  Vector2 velocity;
  double life = 2.5;

  FireballComponent(Vector2 pos, bool right)
      : velocity = Vector2(right ? 320 : -320, 40),
        super(position: pos, size: Vector2(14, 14), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    life -= dt;
    if (life <= 0) {
      removeFromParent();
      return;
    }
    velocity.y += 600 * dt;
    position += velocity * dt;
    if (position.y > 700) removeFromParent();
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    if (other is EnemyComponent && !other.dead) {
      other.damage();
      game.onEnemyKilled(other.kind == EnemyKind.boss ? 500 : 100);
      game.juice.burst(absoluteCenter, color: MarioColors.red, count: 12);
      removeFromParent();
    } else if (other is PlatformBlock) {
      if (velocity.y > 0) {
        velocity.y = -220;
        position.y = other.position.y - size.y;
      } else {
        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      Paint()..color = const Color(0xFFFF6A00),
    );
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 3,
      Paint()..color = MarioColors.yellow,
    );
  }
}
