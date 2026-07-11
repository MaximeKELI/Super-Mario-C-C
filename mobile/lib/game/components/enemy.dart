import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../theme/mario_theme.dart';
import '../mario_game.dart';
import '../render/pseudo3d.dart';
import 'platform_block.dart';
import 'player.dart';

class EnemyComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<MarioGame> {
  final EnemyKind kind;
  Vector2 velocity = Vector2(-50, 0);
  double speedMult = 1;
  int health;
  bool dead = false;
  double startX;
  double originalY;
  double flyingT = 0;
  double deathT = 0;
  double flash = 0;

  EnemyComponent(EnemyDef def)
      : kind = def.kind,
        startX = def.x,
        originalY = def.y,
        health = def.kind == EnemyKind.boss ? 3 : 1,
        super(
          position: Vector2(def.x, def.y),
          size: def.kind == EnemyKind.boss ? Vector2(56, 56) : Vector2(36, 36),
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    if (kind == EnemyKind.flying) {
      velocity = Vector2(-40 * speedMult, 0);
    } else {
      velocity.x *= speedMult;
    }
  }

  void damage() {
    health--;
    flash = 0.25;
    game.juice.triggerHitStop(0.08);
    game.juice.shake(intensity: kind == EnemyKind.boss ? 14 : 7, duration: 0.28);
    game.juice.ring(absoluteCenter, color: MarioColors.red, count: 12);
    if (health <= 0) {
      dead = true;
      deathT = 0.7;
      game.juice.burst(absoluteCenter, color: MarioColors.brown, count: 28);
      game.juice.scorePopup(absoluteCenter, kind == EnemyKind.boss ? '+500' : '+100');
    }
  }

  @override
  void update(double dt) {
    if (dead) {
      deathT -= dt;
      angle += dt * 8;
      position.y += 120 * dt;
      if (deathT <= 0) removeFromParent();
      return;
    }
    flash = max(0, flash - dt);
    flyingT += dt;

    if (kind == EnemyKind.flying) {
      position.x += velocity.x * dt;
      position.y = originalY + sin(flyingT * 3) * 40;
    } else {
      position.x += velocity.x * dt;
      position.y += 400 * dt; // gravity soft
      if ((position.x - startX).abs() > 90) {
        velocity.x *= -1;
        startX = position.x;
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (dead) return;
    if (other is PlatformBlock && !other.destroyed && kind != EnemyKind.flying) {
      final bottom = position.y + size.y;
      if (bottom >= other.position.y && position.y < other.position.y) {
        position.y = other.position.y - size.y;
      }
    }
    if (other is PlayerComponent && !other.dead) {
      final stomping = other.velocity.y > 0 &&
          other.position.y + other.size.y - 12 <= position.y + 10;
      if (stomping) {
        damage();
        other.velocity.y = -320;
        other.squashY = 0.7;
        game.onEnemyKilled(kind == EnemyKind.boss ? 500 : 100);
      } else if (!other.invincible) {
        other.shrink();
        game.juice.shake(intensity: 8, duration: 0.3);
        if (other.dead) game.onPlayerDied();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final color = switch (kind) {
      EnemyKind.goomba => MarioColors.brown,
      EnemyKind.koopa => MarioColors.green,
      EnemyKind.flying => const Color(0xFF7B5EA7),
      EnemyKind.boss => MarioColors.red,
    };

    // Contact shadow
    Pseudo3d.dropShadow(
      canvas,
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y + 2),
        width: size.x * 0.85,
        height: 9,
      ),
      blur: 5,
      alpha: 0.3,
    );

    Pseudo3d.extrudedBox(
      canvas,
      Rect.fromLTWH(2, 2, size.x - 4, size.y - 4),
      face: flash > 0 ? Colors.white : color,
      top: Color.lerp(color, Colors.white, 0.25)!,
      side: Color.lerp(color, Colors.black, 0.3)!,
      d: 7,
      radius: 10,
    );

    canvas.drawCircle(Offset(size.x * 0.35, size.y * 0.35), 4, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(size.x * 0.65, size.y * 0.35), 4, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(size.x * 0.35, size.y * 0.35), 2, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(size.x * 0.65, size.y * 0.35), 2, Paint()..color = Colors.black);
    if (kind == EnemyKind.boss) {
      final tp = TextPainter(
        text: TextSpan(
          text: '$health',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.x / 2 - tp.width / 2, size.y / 2));
    }
  }
}
