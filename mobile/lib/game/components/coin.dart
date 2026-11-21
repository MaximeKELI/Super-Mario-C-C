import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../pipeleap_game.dart';
import '../render/pseudo3d.dart';
import 'player.dart';

class CoinComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<PipeLeapGame> {
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
    t += dt * 7;
    position.y = baseY + sin(t) * 12;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      game.juice.burst(absoluteCenter, color: AppColors.yellow, count: 24);
      game.juice.ring(absoluteCenter, color: AppColors.yellow, count: 14);
      game.juice.sparks(absoluteCenter, count: 8);
      game.juice.scorePopup(absoluteCenter, '+50');
      game.juice.triggerHitStop(0.04);
      game.juice.shake(intensity: 4, duration: 0.12);
      game.onCoinCollected();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final scaleX = 0.28 + 0.72 * ((sin(t * 3) + 1) / 2);
    final bounce = 1.0 + 0.12 * sin(t * 2);
    final breathe = 1.0 + 0.06 * sin(t * 2.5);
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(breathe, bounce);
    Pseudo3d.cylinderCoin(canvas, size.x / 2, scaleX, t: t);
    canvas.restore();
  }
}
