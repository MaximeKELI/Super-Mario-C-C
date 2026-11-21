import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../theme/app_theme.dart';
import '../pipeleap_game.dart';
import '../render/pseudo3d.dart';
import 'platform_block.dart';
import 'player.dart';

enum EnemyState { idle, patrol, alert, chase, flee, attack, swoop }

class EnemyComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<PipeLeapGame> {
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
  double alertTimer = 0;
  double stateTimer = 0;
  double wingFlap = 0;
  double chargeCooldown = 0;
  bool charging = false;
  bool knocked = false;
  double knockT = 0;
  EnemyState state = EnemyState.patrol;

  // Boss phases
  int bossPhase = 0;
  double bossTimer = 0;
  bool roared = false;

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

  double get senseRadius => switch (kind) {
        EnemyKind.grunt => 140,
        EnemyKind.sheller => 200,
        EnemyKind.flying => 220,
        EnemyKind.boss => 260,
      };

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    if (kind == EnemyKind.flying) {
      velocity = Vector2(-40 * speedMult, 0);
      state = EnemyState.patrol;
    } else {
      velocity.x *= speedMult;
    }
  }

  void receiveAlert(Vector2 origin) {
    if (dead) return;
    alertTimer = 2.5;
    if (state == EnemyState.flee) return;
    if (kind == EnemyKind.grunt) {
      state = EnemyState.chase;
      stateTimer = 1.8;
    } else if (kind == EnemyKind.sheller) {
      state = EnemyState.alert;
      stateTimer = 0.4;
    } else if (kind == EnemyKind.flying) {
      state = EnemyState.swoop;
      stateTimer = 1.2;
    }
  }

  void forceFlee() {
    if (dead || kind == EnemyKind.boss) return;
    state = EnemyState.flee;
    stateTimer = 2.2;
    alertTimer = 0;
  }

  /// Returns true only when this hit actually defeats the enemy.
  bool damage({bool fromStomp = false}) {
    if (dead) return false;
    health--;
    flash = 0.25;
    final stop = fromStomp
        ? 0.07
        : (kind == EnemyKind.boss ? 0.12 : 0.08);
    game.juice.triggerHitStop(stop);
    game.juice.shake(
      intensity: kind == EnemyKind.boss ? 14 : (fromStomp ? 8 : 6),
      duration: 0.28,
    );
    game.juice.ring(absoluteCenter, color: AppColors.red, count: 12);
    if (kind == EnemyKind.boss) {
      game.alertNearby(absoluteCenter, 320);
      roared = true;
      bossTimer = 0;
    }
    if (health <= 0) {
      dead = true;
      deathT = 0.7;
      game.juice.burst(absoluteCenter, color: AppColors.brown, count: 28);
      game.juice.shockwave(absoluteCenter);
      game.juice.scorePopup(
        absoluteCenter,
        kind == EnemyKind.boss ? '+500' : '+100',
      );
      if (kind == EnemyKind.boss) {
        game.onBossDefeated(absoluteCenter);
      }
      return true;
    }
    return false;
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
    wingFlap += dt * 14;
    chargeCooldown = max(0, chargeCooldown - dt);
    stateTimer = max(0, stateTimer - dt);
    alertTimer = max(0, alertTimer - dt);
    if (knocked) {
      knockT -= dt;
      position += velocity * dt;
      if (knockT <= 0) {
        knocked = false;
        velocity.x = -50 * speedMult * (velocity.x >= 0 ? 1 : -1);
      }
      return;
    }

    final player = game.player;
    final toPlayer = player.absoluteCenter - absoluteCenter;
    final dist = toPlayer.length;
    final playerAlive = !player.dead;

    if (kind == EnemyKind.boss) {
      _updateBoss(dt, player, toPlayer, dist, playerAlive);
      return;
    }
    if (kind == EnemyKind.flying) {
      _updateFlying(dt, player, toPlayer, dist, playerAlive);
      return;
    }

    // Ground enemies: grunt / sheller
    if (playerAlive &&
        dist < senseRadius &&
        state == EnemyState.patrol &&
        chargeCooldown <= 0) {
      state = EnemyState.alert;
      stateTimer = 0.35;
      game.alertNearby(absoluteCenter, senseRadius * 0.7);
    }

    if (state == EnemyState.alert) {
      velocity.x *= 0.9;
      if (stateTimer <= 0) {
        state = kind == EnemyKind.sheller ? EnemyState.attack : EnemyState.chase;
        stateTimer = kind == EnemyKind.sheller ? 1.1 : 1.6;
        if (kind == EnemyKind.sheller) charging = true;
      }
    } else if (state == EnemyState.chase) {
      if (!playerAlive || dist > senseRadius * 1.4 || stateTimer <= 0) {
        state = EnemyState.patrol;
        startX = position.x;
        velocity.x = -50 * speedMult;
      } else {
        velocity.x = toPlayer.x.sign * 70 * speedMult;
        position.x += velocity.x * dt;
        position.y += 400 * dt;
      }
    } else if (state == EnemyState.attack) {
      if (!charging || stateTimer <= 0) {
        charging = false;
        state = EnemyState.patrol;
        startX = position.x;
        velocity.x = -55 * speedMult;
        chargeCooldown = 1.4;
      } else {
        velocity.x = toPlayer.x.sign * 160 * speedMult;
        position.x += velocity.x * dt;
        position.y += 400 * dt;
      }
    } else if (state == EnemyState.flee) {
      velocity.x = toPlayer.x.sign * -90 * speedMult;
      position.x += velocity.x * dt;
      position.y += 400 * dt;
      if (stateTimer <= 0) {
        state = EnemyState.patrol;
        startX = position.x;
      }
    } else {
      position.x += velocity.x * dt;
      position.y += 400 * dt;
      if ((position.x - startX).abs() > 90) {
        velocity.x *= -1;
        startX = position.x;
      }
    }
  }

  void _updateFlying(
    double dt,
    PlayerComponent player,
    Vector2 toPlayer,
    double dist,
    bool playerAlive,
  ) {
    if (playerAlive && dist < senseRadius && state == EnemyState.patrol) {
      state = EnemyState.swoop;
      stateTimer = 1.15;
    }
    if (state == EnemyState.swoop && playerAlive) {
      final target = player.absoluteCenter;
      final dir = (target - absoluteCenter);
      if (dir.length > 4) {
        position += dir.normalized() * 140 * speedMult * dt;
      }
      if (stateTimer <= 0 || dist < 28) {
        state = EnemyState.patrol;
        originalY = position.y;
        velocity.x = -40 * speedMult * (toPlayer.x > 0 ? 1 : -1);
        stateTimer = 1.5;
      }
    } else {
      position.x += velocity.x * dt;
      position.y = originalY + sin(flyingT * 3) * 40;
      if (stateTimer <= 0 && Random().nextDouble() < 0.002) {
        velocity.x *= -1;
      }
    }
  }

  void _updateBoss(
    double dt,
    PlayerComponent player,
    Vector2 toPlayer,
    double dist,
    bool playerAlive,
  ) {
    bossTimer += dt;
    position.y += 400 * dt;

    // Phase by health: 3=taunt/patrol, 2=slam chase, 1=enraged + spawn
    bossPhase = 4 - health;
    if (!playerAlive) {
      velocity.x = -40 * speedMult;
      position.x += velocity.x * dt;
      return;
    }

    if (bossTimer < 0.8 && !roared) {
      // Taunt
      velocity.x *= 0.85;
      if (bossTimer > 0.5) {
        roared = true;
        game.alertNearby(absoluteCenter, 340);
        game.juice.shake(intensity: 10, duration: 0.35);
        game.juice.shockwave(absoluteCenter);
      }
      return;
    }

    if (health == 1 && bossTimer > 2.5) {
      bossTimer = 0;
      game.spawnMinionNear(absoluteCenter);
      game.juice.burst(absoluteCenter, color: AppColors.red, count: 12);
    }

    // Slam / chase
    final speed = health <= 1 ? 110.0 : 75.0;
    velocity.x = toPlayer.x.sign * speed * speedMult;
    position.x += velocity.x * dt;

    if (bossTimer > 1.8 && dist < 90) {
      // Slam pulse
      bossTimer = 0.9;
      game.juice.shockwave(absoluteCenter);
      game.juice.shake(intensity: 12, duration: 0.3);
      game.alertNearby(absoluteCenter, 280);
      squashPulse();
    }
  }

  double _squash = 1;
  void squashPulse() {
    _squash = 0.7;
  }

  void knockFromShell(Vector2 from) {
    if (kind == EnemyKind.boss || dead) return;
    knocked = true;
    knockT = 0.55;
    velocity = Vector2((absoluteCenter.x - from.x).sign * 220, -80);
    game.juice.sparks(absoluteCenter, count: 6);
    flash = 0.2;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (dead) return;
    if (other is PlatformBlock && !other.destroyed && kind != EnemyKind.flying) {
      final bottom = position.y + size.y;
      if (bottom >= other.position.y && position.y < other.position.y) {
        position.y = other.position.y - size.y;
        _squash += (1 - _squash) * 0.5;
      }
    }
    if (other is EnemyComponent && other != this && !other.dead) {
      _onEnemyBump(other);
    }
    if (other is PlayerComponent && !other.dead) {
      final stomping = other.velocity.y > 0 &&
          other.position.y + other.size.y - 12 <= position.y + 10;
      if (stomping) {
        final killed = damage(fromStomp: true);
        other.velocity.y = -320;
        other.squashY = 0.7;
        if (killed) {
          game.onEnemyKilled(kind == EnemyKind.boss ? 500 : 100);
        }
      } else if (!other.invincible) {
        other.shrink();
        game.juice.shake(intensity: 8, duration: 0.3);
        game.juice.flashDamage();
        if (other.dead) game.onPlayerDied();
      }
    }
  }

  void _onEnemyBump(EnemyComponent other) {
    // Shell bowling a walker
    if (kind == EnemyKind.sheller &&
        (charging || state == EnemyState.attack) &&
        other.kind == EnemyKind.grunt) {
      other.knockFromShell(absoluteCenter);
      game.juice.burst(other.absoluteCenter, color: AppColors.brown, count: 8);
      return;
    }
    if (other.kind == EnemyKind.sheller &&
        (other.charging || other.state == EnemyState.attack) &&
        kind == EnemyKind.grunt) {
      knockFromShell(other.absoluteCenter);
      return;
    }
    // Soft bump / flip
    if (kind != EnemyKind.flying && other.kind != EnemyKind.flying) {
      final mid = (absoluteCenter.x + other.absoluteCenter.x) / 2;
      if (absoluteCenter.x < mid) {
        position.x -= 2;
        velocity.x = -velocity.x.abs();
      } else {
        position.x += 2;
        velocity.x = velocity.x.abs();
      }
      startX = position.x;
    }
  }

  @override
  void render(Canvas canvas) {
    _squash += (1 - _squash) * 0.15;
    final color = switch (kind) {
      EnemyKind.grunt => AppColors.brown,
      EnemyKind.sheller => AppColors.green,
      EnemyKind.flying => const Color(0xFF7B5EA7),
      EnemyKind.boss => AppColors.red,
    };

    Pseudo3d.dropShadow(
      canvas,
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y + 2),
        width: size.x * 0.85 * _squash,
        height: 9,
      ),
      blur: 5,
      alpha: 0.3,
    );

    // Alert exclamation
    if (state == EnemyState.alert || alertTimer > 1.5) {
      final tp = TextPainter(
        text: const TextSpan(
          text: '!',
          style: TextStyle(
            color: AppColors.yellow,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.x / 2 - tp.width / 2, -18));
    }

    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(1 / _squash, _squash);
    canvas.translate(-size.x / 2, -size.y / 2);

    // Wings for flying
    if (kind == EnemyKind.flying) {
      final flap = 0.65 + 0.35 * sin(wingFlap);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(-4, size.y * 0.35), width: 16 * flap, height: 10),
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(size.x + 4, size.y * 0.35), width: 16 * flap, height: 10),
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }

    // Shell ridge for sheller
    if (kind == EnemyKind.sheller) {
      Pseudo3d.softGlow(
        canvas,
        Offset(size.x / 2, size.y / 2),
        size.x * 0.6,
        color: AppColors.green,
        alpha: charging ? 0.35 : 0.12,
      );
    }

    Pseudo3d.extrudedBox(
      canvas,
      Rect.fromLTWH(2, 2, size.x - 4, size.y - 4),
      face: flash > 0 ? Colors.white : color,
      top: Color.lerp(color, Colors.white, 0.25)!,
      side: Color.lerp(color, Colors.black, 0.3)!,
      d: kind == EnemyKind.boss ? 10 : 7,
      radius: kind == EnemyKind.sheller ? 14 : 10,
      glow: kind == EnemyKind.boss,
      glowColor: AppColors.red,
      animT: flyingT,
    );

    // Eyes that track the player
    final look = (game.player.absoluteCenter.x - absoluteCenter.x).clamp(-6, 6) * 0.15;
    final eyeY = size.y * 0.35;
    final eyePaint = Paint()..color = Colors.white;
    final pupil = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(size.x * 0.35 + look, eyeY), 4.5, eyePaint);
    canvas.drawCircle(Offset(size.x * 0.65 + look, eyeY), 4.5, eyePaint);
    canvas.drawCircle(Offset(size.x * 0.35 + look * 1.4, eyeY), 2.2, pupil);
    canvas.drawCircle(Offset(size.x * 0.65 + look * 1.4, eyeY), 2.2, pupil);

    // Antenna for walker
    if (kind == EnemyKind.grunt) {
      canvas.drawLine(
        Offset(size.x * 0.3, 4),
        Offset(size.x * 0.22, -6),
        Paint()
          ..color = const Color(0xFF5D4037)
          ..strokeWidth = 2,
      );
      canvas.drawLine(
        Offset(size.x * 0.7, 4),
        Offset(size.x * 0.78, -6),
        Paint()
          ..color = const Color(0xFF5D4037)
          ..strokeWidth = 2,
      );
      canvas.drawCircle(Offset(size.x * 0.22, -6), 2.5, Paint()..color = AppColors.yellow);
      canvas.drawCircle(Offset(size.x * 0.78, -6), 2.5, Paint()..color = AppColors.yellow);
    }

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
    canvas.restore();
  }
}
