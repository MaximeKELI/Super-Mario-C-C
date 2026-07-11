import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../theme/mario_theme.dart';
import '../mario_game.dart';
import 'player.dart';

class PowerUpComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<MarioGame> {
  final PowerUpKind kind;
  double bob = 0;
  double baseY;

  PowerUpComponent(PowerUpDef def)
      : kind = def.kind,
        baseY = def.y,
        super(position: Vector2(def.x, def.y), size: Vector2(28, 28));

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    bob += dt * 3;
    position.y = baseY + sin(bob) * 5;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is! PlayerComponent) return;
    switch (kind) {
      case PowerUpKind.mushroom:
        other.collectMushroom();
      case PowerUpKind.fireFlower:
        other.collectFire();
      case PowerUpKind.feather:
        other.collectFeather();
      case PowerUpKind.star:
        other.collectStar();
      case PowerUpKind.oneUp:
        game.lives++;
      case PowerUpKind.comet:
        other.collectComet();
    }
    game.juice.burst(absoluteCenter, color: MarioColors.red, count: 20);
    game.juice.scorePopup(absoluteCenter, 'POWER!');
    game.onPowerUpCollected();
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final color = switch (kind) {
      PowerUpKind.mushroom => MarioColors.red,
      PowerUpKind.fireFlower => const Color(0xFFFF6A00),
      PowerUpKind.feather => Colors.white,
      PowerUpKind.star => MarioColors.yellow,
      PowerUpKind.oneUp => MarioColors.green,
      PowerUpKind.comet => MarioColors.blue,
    };
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, Paint()..color = color);
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}
