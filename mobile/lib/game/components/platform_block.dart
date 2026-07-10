import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../theme/mario_theme.dart';
import '../mario_game.dart';

class PlatformBlock extends PositionComponent
    with CollisionCallbacks, HasGameReference<MarioGame> {
  final PlatformKind kind;
  final double startX;
  final double startY;
  double moveDir = 1;
  double traveled = 0;
  static const moveRange = 80.0;
  static const moveSpeed = 60.0;
  int hitCount = 0;
  bool destroyed = false;
  double squash = 1;

  PlatformBlock(PlatformDef def)
      : kind = def.kind,
        startX = def.x,
        startY = def.y,
        super(
          position: Vector2(def.x, def.y),
          size: Vector2(def.w, def.h),
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    if (destroyed) {
      removeFromParent();
      return;
    }
    squash += (1 - squash) * 12 * dt;
    if (kind == PlatformKind.movingH) {
      position.x += moveDir * moveSpeed * dt;
      traveled += moveSpeed * dt;
      if (traveled >= moveRange) {
        traveled = 0;
        moveDir *= -1;
      }
    } else if (kind == PlatformKind.movingV) {
      position.y += moveDir * moveSpeed * dt;
      traveled += moveSpeed * dt;
      if (traveled >= moveRange) {
        traveled = 0;
        moveDir *= -1;
      }
    }
  }

  void hit() {
    if (kind != PlatformKind.destructible) return;
    hitCount++;
    squash = 0.7;
    if (hitCount >= 3) {
      destroyed = true;
      game.juice.burst(absoluteCenter, color: MarioColors.brown, count: 10);
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, size.y * (1 - squash) / 2, size.x, size.y * squash);
    final color = switch (kind) {
      PlatformKind.destructible => const Color(0xFF8B5A2B),
      PlatformKind.movingH || PlatformKind.movingV => MarioColors.blue,
      _ => MarioColors.green,
    };
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // grass top
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, rect.top, size.x, 8 * squash),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF6DD66D),
    );
  }
}
