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
  static const jumpForce = -560.0;
  static const moveSpeed = 240.0;
  static const maxFall = 720.0;
  static const baseW = 78.0;
  static const baseH = 78.0;

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
  double _dustTimer = 0;
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
    // Use splash preload when available — avoids 30s decode stall
    if (GifLoader.marioFrames != null && GifLoader.marioFrames!.isNotEmpty) {
      _gifFrames = GifLoader.marioFrames!;
      return;
    }
    try {
      _gifFrames = await GifLoader.load('assets/images/Mario.gif', targetWidth: 96);
      GifLoader.marioFrames = _gifFrames;
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
      size = Vector2(baseW * 1.28, baseH * 1.38);
      squashY = 1.12;
      stretchX = 0.92;
      game.juice.burst(absoluteCenter, color: MarioColors.red, count: 20);
      game.juice.shake(intensity: 5, duration: 0.2);
    }
  }

  void collectFire() {
    hasFire = true;
    collectMushroom();
  }

  void collectFeather() {
    hasFly = true;
    flyTime = 8;
    game.juice.burst(absoluteCenter, color: Colors.white, count: 24);
  }

  void collectStar() {
    invincible = true;
    invincibleTime = 12;
    game.juice.burst(absoluteCenter, color: MarioColors.yellow, count: 36);
    game.juice.shake(intensity: 10, duration: 0.35);
  }

  void collectComet() {
    hasComet = true;
    cometTime = 10;
    game.juice.burst(absoluteCenter, color: MarioColors.blue, count: 30);
  }

  void shrink() {
    if (isBig) {
      isBig = false;
      hasFire = false;
      size = Vector2(baseW, baseH);
      invincible = true;
      invincibleTime = 2;
      squashY = 0.45;
      stretchX = 1.4;
      game.juice.shake(intensity: 14, duration: 0.4);
    } else {
      dead = true;
    }
  }

  bool get _isRunning => onGround && velocity.x.abs() > 50;

  @override
  void update(double dt) {
    if (dead) return;
    animT += dt;
    shootCooldown = max(0, shootCooldown - dt);

    if (_gifFrames.isNotEmpty) {
      _frameTimer += dt;
      final baseDelay = _gifFrames[_frameIndex].delaySeconds;
      final speedMul = _isRunning ? 0.35 : (velocity.x.abs() > 20 ? 0.55 : 1.0);
      final delay = max(0.04, baseDelay * speedMul);
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

    final speed = moveSpeed * (hasComet ? 1.85 : 1.0);
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
        // Mild squash only — keep GIF proportions readable
        stretchX = 0.88;
        squashY = 1.12;
        game.juice.burst(
          absoluteCenter + Vector2(0, size.y / 2),
          color: Colors.white70,
          count: 8,
        );
      } else if (hasFly) {
        velocity.y = min(velocity.y, -200);
      }
    } else {
      jumpConsumed = false;
    }

    if (wantShoot && hasFire && shootCooldown <= 0) {
      shootCooldown = 0.35;
      game.spawnFireball(
        absoluteCenter + Vector2(facingRight ? 28 : -28, 0),
        facingRight,
      );
      game.juice.burst(absoluteCenter, color: const Color(0xFFFF6A00), count: 8);
    }

    velocity.y += gravity * dt;
    if (velocity.y > maxFall) velocity.y = maxFall;

    onGround = false;
    position += velocity * dt;

    if (position.y > 700) {
      dead = true;
    }

    // Recover squash gently; never warp GIF while running
    squashY += (1 - squashY) * 16 * dt;
    stretchX += (1 - stretchX) * 16 * dt;

    if (_isRunning) {
      // Barely-visible dust
      _dustTimer += dt;
      if (_dustTimer > 0.45) {
        _dustTimer = 0;
        game.juice.burst(
          Vector2(absoluteCenter.x - (facingRight ? 12 : -12), position.y + size.y - 2),
          color: const Color(0x22A89070),
          count: 1,
        );
      }
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

    if (velocity.y >= 0 && prevBottom <= platTop + 16 && playerBottom >= platTop) {
      position.y = platTop - size.y;
      velocity.y = 0;
      if (!onGround) {
        squashY = 0.82;
        stretchX = 1.12;
        // Landing puff — almost invisible
        game.juice.burst(
          Vector2(absoluteCenter.x, platTop),
          color: const Color(0x18A8C878),
          count: 1,
        );
      }
      onGround = true;
      return;
    }

    if (velocity.y < 0 && playerTop <= platBottom && playerBottom > platBottom) {
      position.y = platBottom;
      velocity.y = 0;
      platform.hit();
      squashY = 1.1;
      stretchX = 0.92;
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
    final blink = invincible && (animT * 22).floor().isOdd;
    if (blink) return;

    canvas.save();
    final cx = size.x / 2;
    final cy = size.y / 2;
    canvas.translate(cx, cy);
    // Flip only — no run squash so the GIF stays sharp
    canvas.scale(facingRight ? 1.0 : -1.0, 1.0);
    // Tiny landing/jump squash (near 1.0 most of the time)
    canvas.scale(stretchX.clamp(0.85, 1.15), squashY.clamp(0.85, 1.15));
    canvas.translate(-cx, -cy);

    if (_gifFrames.isNotEmpty) {
      final frame = _gifFrames[_frameIndex].image;
      final dst = Rect.fromLTWH(0, 0, size.x, size.y);
      if (hasComet || invincible) {
        canvas.drawCircle(
          Offset(size.x / 2, size.y * 0.7),
          size.x * 0.45,
          Paint()
            ..color = (hasComet ? MarioColors.blue : MarioColors.yellow)
                .withValues(alpha: 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
      }
      paintImage(
        canvas: canvas,
        rect: dst,
        image: frame,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        isAntiAlias: false,
      );
      if (hasFire) {
        canvas.drawRect(dst, Paint()..color = const Color(0x33FF6A00));
      } else if (invincible) {
        canvas.drawRect(dst, Paint()..color = MarioColors.yellow.withValues(alpha: 0.2));
      }
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(4, 10, size.x - 8, size.y - 14),
          const Radius.circular(8),
        ),
        Paint()..color = MarioColors.red,
      );
    }

    if (hasFly) {
      final flap = 0.7 + 0.3 * sin(animT * 20);
      canvas.drawOval(
        Rect.fromLTWH(-10, 18, 18 * flap, 12),
        Paint()..color = Colors.white.withValues(alpha: 0.92),
      );
    }

    canvas.restore();
  }
}
