import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../theme/mario_theme.dart';
import '../gif_loader.dart';
import '../mario_game.dart';
import 'platform_block.dart';

class PlayerComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<MarioGame> {
  static const gravity = 1400.0;
  static const jumpForce = -520.0;
  static const moveSpeed = 220.0;
  static const maxFall = 700.0;
  static const baseW = 48.0;
  static const baseH = 48.0;

  Vector2 velocity = Vector2.zero();
  bool onGround = false;
  bool facingRight = true;
  bool dead = false;
  bool isBig = false;
  bool hasFire = false;
  bool hasFly = false;
  bool invincible = false;
  bool hasComet = false;
  double flyTime = 0;
  double invincibleTime = 0;
  double cometTime = 0;
  double shootCooldown = 0;
  double squashY = 1;
  double stretchX = 1;
  double animT = 0;
  bool wantLeft = false;
  bool wantRight = false;
  bool wantJump = false;
  bool wantShoot = false;
  bool jumpConsumed = false;

  List<GifFrameData> _gifFrames = const [];
  int _frameIndex = 0;
  double _frameTimer = 0;

  PlayerComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2(baseW, baseH),
          anchor: Anchor.topLeft,
          priority: 10,
        );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    try {
      _gifFrames = await GifLoader.load('assets/images/Mario.gif');
    } catch (_) {
      _gifFrames = const [];
    }
  }

  void respawn(Vector2 pos) {
    position.setFrom(pos);
    velocity.setZero();
    dead = false;
    onGround = false;
  }

  void collectMushroom() {
    if (!isBig) {
      isBig = true;
      size = Vector2(baseW * 1.2, baseH * 1.35);
      squashY = 1.3;
    }
  }

  void collectFire() {
    hasFire = true;
    collectMushroom();
  }

  void collectFeather() {
    hasFly = true;
    flyTime = 8;
  }

  void collectStar() {
    invincible = true;
    invincibleTime = 12;
  }

  void collectComet() {
    hasComet = true;
    cometTime = 10;
  }

  void shrink() {
    if (isBig) {
      isBig = false;
      hasFire = false;
      size = Vector2(baseW, baseH);
      invincible = true;
      invincibleTime = 2;
      squashY = 0.6;
    } else {
      dead = true;
    }
  }

  @override
  void update(double dt) {
    if (dead) return;
    animT += dt;
    shootCooldown = max(0, shootCooldown - dt);

    if (_gifFrames.isNotEmpty) {
      _frameTimer += dt;
      final delay = _gifFrames[_frameIndex].delaySeconds;
      if (_frameTimer >= delay) {
        _frameTimer = 0;
        _frameIndex = (_frameIndex + 1) % _gifFrames.length;
      }
    }

    if (flyTime > 0) {
      flyTime -= dt;
      if (flyTime <= 0) hasFly = false;
    }
    if (invincibleTime > 0) {
      invincibleTime -= dt;
      if (invincibleTime <= 0) invincible = false;
    }
    if (cometTime > 0) {
      cometTime -= dt;
      if (cometTime <= 0) hasComet = false;
    }

    final speed = moveSpeed * (hasComet ? 1.7 : 1.0);
    if (wantLeft) {
      velocity.x = -speed;
      facingRight = false;
    } else if (wantRight) {
      velocity.x = speed;
      facingRight = true;
    } else {
      velocity.x *= 0.82;
      if (velocity.x.abs() < 8) velocity.x = 0;
    }

    if (wantJump) {
      if (onGround && !jumpConsumed) {
        velocity.y = jumpForce;
        onGround = false;
        jumpConsumed = true;
        stretchX = 0.75;
        squashY = 1.35;
        game.juice.burst(
          absoluteCenter + Vector2(0, size.y / 2),
          color: Colors.white70,
          count: 6,
        );
      } else if (hasFly) {
        velocity.y = min(velocity.y, -180);
      }
    } else {
      jumpConsumed = false;
    }

    if (wantShoot && hasFire && shootCooldown <= 0) {
      shootCooldown = 0.35;
      game.spawnFireball(
        absoluteCenter + Vector2(facingRight ? 20 : -20, 0),
        facingRight,
      );
    }

    velocity.y += gravity * dt;
    if (velocity.y > maxFall) velocity.y = maxFall;

    onGround = false;
    position += velocity * dt;

    if (position.y > 700) {
      dead = true;
    }

    squashY += (1 - squashY) * 14 * dt;
    stretchX += (1 - stretchX) * 14 * dt;
    if (onGround && velocity.x.abs() > 40) {
      stretchX = 1 + sin(animT * 18) * 0.04;
      squashY = 1 - sin(animT * 18) * 0.04;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is PlatformBlock && !other.destroyed) {
      _resolvePlatform(other);
    }
  }

  void _resolvePlatform(PlatformBlock platform) {
    final prevBottom = position.y + size.y - velocity.y * 0.02;
    final platTop = platform.position.y;
    final platBottom = platform.position.y + platform.size.y;
    final platLeft = platform.position.x;
    final platRight = platform.position.x + platform.size.x;

    final playerLeft = position.x;
    final playerRight = position.x + size.x;
    final playerBottom = position.y + size.y;
    final playerTop = position.y;

    if (playerRight <= platLeft || playerLeft >= platRight) return;

    if (velocity.y >= 0 && prevBottom <= platTop + 12 && playerBottom >= platTop) {
      position.y = platTop - size.y;
      velocity.y = 0;
      if (!onGround) {
        squashY = 0.65;
        stretchX = 1.25;
        game.juice.burst(
          Vector2(absoluteCenter.x, platTop),
          color: MarioColors.green,
          count: 5,
        );
      }
      onGround = true;
      return;
    }

    if (velocity.y < 0 && playerTop <= platBottom && playerBottom > platBottom) {
      position.y = platBottom;
      velocity.y = 0;
      platform.hit();
      squashY = 1.2;
      return;
    }

    if (playerRight > platLeft && playerLeft < platLeft && absoluteCenter.y > platTop) {
      position.x = platLeft - size.x;
      velocity.x = 0;
    } else if (playerLeft < platRight && playerRight > platRight && absoluteCenter.y > platTop) {
      position.x = platRight;
      velocity.x = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    final blink = invincible && (animT * 20).floor().isOdd;
    if (blink) return;

    canvas.save();
    final cx = size.x / 2;
    final cy = size.y / 2;
    canvas.translate(cx, cy);
    canvas.scale(facingRight ? stretchX : -stretchX, squashY);
    canvas.translate(-cx, -cy);

    if (_gifFrames.isNotEmpty) {
      final frame = _gifFrames[_frameIndex].image;
      final dst = Rect.fromLTWH(0, 0, size.x, size.y);
      paintImage(
        canvas: canvas,
        rect: dst,
        image: frame,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
      );
      if (hasFire) {
        canvas.drawRect(dst, Paint()..color = const Color(0x33FF6A00));
      } else if (invincible) {
        canvas.drawRect(dst, Paint()..color = MarioColors.yellow.withValues(alpha: 0.22));
      }
    } else {
      _renderFallback(canvas);
    }

    if (hasFly) {
      canvas.drawOval(
        const Rect.fromLTWH(-6, 14, 14, 10),
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
    }
    if (hasComet) {
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x * 0.7,
        Paint()
          ..color = MarioColors.blue.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    canvas.restore();
  }

  void _renderFallback(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 10, size.x - 8, size.y - 14),
        const Radius.circular(8),
      ),
      Paint()..color = MarioColors.red,
    );
    canvas.drawCircle(Offset(size.x * 0.55, 18), 7, Paint()..color = const Color(0xFFFFDBAC));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(6, size.y * 0.45, size.x - 12, size.y * 0.4),
        const Radius.circular(4),
      ),
      Paint()..color = MarioColors.blue,
    );
  }
}
