
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../theme/mario_theme.dart';
import '../mario_game.dart';
import 'player.dart';
import 'power_up.dart';

class BlockComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<MarioGame> {
  final BlockKind kind;
  bool used = false;
  double bump = 0;
  double bumpVel = 0;

  BlockComponent(BlockDef def)
      : kind = def.kind,
        super(position: Vector2(def.x, def.y), size: Vector2(40, 40));

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  void hitFromBelow(PlayerComponent player) {
    if (used && kind == BlockKind.question) return;
    bumpVel = -120;
    game.juice.triggerHitStop(0.04);
    if (kind == BlockKind.question && !used) {
      used = true;
      final pu = PowerUpComponent(
        PowerUpDef(position.x, position.y - 36, PowerUpKind.mushroom),
      );
      game.world.add(pu);
      game.juice.burst(absoluteCenter, color: MarioColors.yellow, count: 10);
      game.score += 50;
    } else if (kind == BlockKind.brick && player.isBig) {
      game.juice.burst(absoluteCenter, color: MarioColors.brown, count: 12);
      game.score += 25;
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    bumpVel += 800 * dt;
    bump += bumpVel * dt;
    if (bump > 0) {
      bump = 0;
      bumpVel = 0;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is PlayerComponent) {
      final hittingFromBelow =
          other.velocity.y < 0 && other.position.y >= position.y + size.y - 16;
      if (hittingFromBelow) {
        other.velocity.y = 0;
        other.position.y = position.y + size.y;
        hitFromBelow(other);
      } else if (other.velocity.y >= 0 &&
          other.position.y + other.size.y <= position.y + 16) {
        other.position.y = position.y - other.size.y;
        other.velocity.y = 0;
        other.onGround = true;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(0, bump);
    final color = switch (kind) {
      BlockKind.question => used ? MarioColors.brown : MarioColors.yellow,
      BlockKind.brick => MarioColors.brick,
      BlockKind.hard => const Color(0xFF888888),
    };
    Pseudo3d.extrudedBox(
      canvas,
      size.toRect(),
      face: color,
      top: Color.lerp(color, Colors.white, 0.3)!,
      side: Color.lerp(color, Colors.black, 0.3)!,
      d: 8,
      radius: 4,
    );
    if (kind == BlockKind.question && !used) {
      final tp = TextPainter(
        text: const TextSpan(
          text: '?',
          style: TextStyle(
            color: MarioColors.red,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1))],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.x / 2 - tp.width / 2, size.y / 2 - tp.height / 2));
    }
    canvas.restore();
  }
}
