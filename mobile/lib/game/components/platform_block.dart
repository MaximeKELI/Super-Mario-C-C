import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../theme/app_theme.dart';
import '../pipeleap_game.dart';
import '../render/pseudo3d.dart';

class PlatformBlock extends PositionComponent
    with CollisionCallbacks, HasGameReference<PipeLeapGame> {
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
  double sink = 0;
  double _animT = 0;

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

  void landImpact({double strength = 1}) {
    squash = (0.78 - 0.06 * strength).clamp(0.55, 0.9);
    sink = (4 + strength * 3).clamp(2, 10);
    if (strength > 0.5) {
      game.juice.dust(
        Vector2(absoluteCenter.x, position.y),
        count: (4 + strength * 4).round(),
      );
    }
  }

  @override
  void update(double dt) {
    if (destroyed) {
      removeFromParent();
      return;
    }
    _animT += dt;
    squash += (1 - squash) * 12 * dt;
    sink += (0 - sink) * 10 * dt;
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
    squash = 0.65;
    game.juice.sparks(absoluteCenter, count: 6);
    game.juice.shake(intensity: 3 + hitCount * 2, duration: 0.15);
    if (hitCount >= 3) {
      destroyed = true;
      game.juice.burst(absoluteCenter, color: AppColors.brown, count: 18);
      game.juice.shockwave(absoluteCenter);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(0, sink);
    final rect = Rect.fromLTWH(0, size.y * (1 - squash) / 2, size.x, size.y * squash);
    final face = switch (kind) {
      PlatformKind.destructible => const Color(0xFF8B5A2B),
      PlatformKind.movingH || PlatformKind.movingV => AppColors.blue,
      _ => const Color(0xFFC84C0C),
    };
    final top = switch (kind) {
      PlatformKind.movingH || PlatformKind.movingV => const Color(0xFF5EC8F8),
      PlatformKind.destructible => const Color(0xFFA67C52),
      _ => const Color(0xFF6DD66D),
    };

    Pseudo3d.extrudedBox(
      canvas,
      rect,
      face: face,
      top: top,
      side: Color.lerp(face, Colors.black, 0.32)!,
      d: 9,
      radius: 5,
      glow: kind == PlatformKind.movingH || kind == PlatformKind.movingV,
      glowColor: AppColors.blue,
      animT: _animT,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, rect.top + 1, size.x - 4, 7 * squash),
        const Radius.circular(3),
      ),
      Paint()..color = top,
    );

    if (kind == PlatformKind.destructible) {
      Pseudo3d.crackLines(canvas, rect, hitCount);
    }
    canvas.restore();
  }
}
