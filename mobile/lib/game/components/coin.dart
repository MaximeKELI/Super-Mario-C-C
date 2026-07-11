import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../theme/mario_theme.dart';
import '../mario_game.dart';
import 'player.dart';

class CoinComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<MarioGame> {
  double t = Random().nextDouble() * pi * 2;
  double baseY;

  CoinComponent(double x, double y)
      : baseY = y,
        super(position: Vector2(x, y), size: Vector2(22, 22), anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    t += dt * 4;
    position.y = baseY + sin(t) * 6;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      game.juice.burst(absoluteCenter, color: MarioColors.yellow, count: 18);
      game.juice.scorePopup(absoluteCenter, '+50');
      game.onCoinCollected();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final scaleX = 0.55 + 0.45 * ((sin(t * 2) + 1) / 2);
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(scaleX, 1);
    canvas.drawCircle(
      Offset.zero,
      size.x / 2,
      Paint()..color = MarioColors.yellow,
    );
    canvas.drawCircle(
      Offset.zero,
      size.x / 2,
      Paint()
        ..color = const Color(0xFFFFF3A0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      const Offset(0, -6),
      const Offset(0, 6),
      Paint()
        ..color = const Color(0xFFE0A800)
        ..strokeWidth = 2,
    );
    canvas.restore();
  }
}
