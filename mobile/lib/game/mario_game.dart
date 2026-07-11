
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamepads/gamepads.dart';

import '../audio/audio_service.dart';
import '../data/levels/levels.dart';
import '../data/models.dart';
import '../data/save_service.dart';
import '../theme/mario_theme.dart';
import 'components/block.dart';
import 'components/coin.dart';
import 'components/enemy.dart';
import 'components/fireball.dart';
import 'components/platform_block.dart';
import 'components/player.dart';
import 'components/power_up.dart';
import 'components/world_props.dart';
import 'systems/juice_system.dart';

enum PlayPhase { playing, paused, levelClear, gameOver }

class MarioGame extends FlameGame with HasCollisionDetection, KeyboardEvents, TapCallbacks {
  MarioGame({
    required this.difficulty,
    this.startLevel = 1,
    this.initialSave,
    this.onExitToMenu,
    this.onNeedName,
  });

  final Difficulty difficulty;
  final int startLevel;
  final SaveData? initialSave;
  final VoidCallback? onExitToMenu;
  final Future<String?> Function(int score)? onNeedName;

  late PlayerComponent player;
  late JuiceSystem juice;
  final List<PipeComponent> pipes = [];

  int score = 0;
  int lives = 3;
  int coins = 0;
  int currentLevel = 1;
  double levelEndX = 1800;
  double cameraX = 0;
  double checkpointX = 80;
  double checkpointY = 400;
  bool hasCheckpoint = false;
  PlayPhase phase = PlayPhase.playing;
  double levelClearTimer = 0;
  double levelTimer = 0;
  GameStats stats = GameStats();
  double lastPlayerX = 0;

  // Touch overlay
  bool ctrlLeft = false;
  bool ctrlRight = false;
  bool ctrlJump = false;
  bool ctrlFire = false;
  bool ctrlPipe = false;

  // Gamepad state
  bool padLeft = false;
  bool padRight = false;
  bool padJump = false;
  bool padFire = false;
  bool padPipe = false;
  StreamSubscription<NormalizedGamepadEvent>? _padSub;

  final SaveService _saves = SaveService();
  final HighScoreService _scores = HighScoreService();
  final StatsService _statsSvc = StatsService();

  @override
  Color backgroundColor() => MarioColors.skyTop;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    juice = JuiceSystem();
    camera.viewfinder.anchor = Anchor.topLeft;
    _padSub = Gamepads.normalizedEvents.listen(_onGamepad);

    if (initialSave != null) {
      currentLevel = initialSave!.currentLevel;
      score = initialSave!.score;
      lives = initialSave!.lives;
      coins = initialSave!.coinsCollected;
      checkpointX = initialSave!.checkpointX;
      checkpointY = initialSave!.checkpointY;
      hasCheckpoint = initialSave!.hasCheckpoint;
      stats = initialSave!.stats;
    } else {
      currentLevel = startLevel;
      lives = switch (difficulty) {
        Difficulty.easy => 5,
        Difficulty.normal => 3,
        Difficulty.hard => 2,
      };
    }

    await loadLevel(currentLevel);
    AudioService.instance.playBgm();
  }

  @override
  void onRemove() {
    _padSub?.cancel();
    super.onRemove();
  }

  void _onGamepad(NormalizedGamepadEvent event) {
    if (event.button != null) {
      final pressed = event.value != 0;
      switch (event.button!) {
        case GamepadButton.dpadLeft:
          padLeft = pressed;
        case GamepadButton.dpadRight:
          padRight = pressed;
        case GamepadButton.dpadDown:
          padPipe = pressed;
        case GamepadButton.a:
        case GamepadButton.b:
          padJump = pressed;
        case GamepadButton.x:
        case GamepadButton.y:
        case GamepadButton.rightBumper:
          padFire = pressed;
        case GamepadButton.start:
          if (pressed) togglePause();
        default:
          break;
      }
    }
    if (event.axis != null) {
      if (event.axis == GamepadAxis.leftStickX) {
        padLeft = event.value < -0.35;
        padRight = event.value > 0.35;
      }
      if (event.axis == GamepadAxis.leftStickY) {
        padPipe = event.value > 0.55;
      }
    }
  }

  bool _keyDown(Set<LogicalKeyboardKey> keys, List<LogicalKeyboardKey> anyOf) {
    for (final k in anyOf) {
      if (keys.contains(k)) return true;
    }
    return false;
  }

  void _applyInputs() {
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    final keyLeft = _keyDown(keys, const [
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.keyA,
    ]);
    final keyRight = _keyDown(keys, const [
      LogicalKeyboardKey.arrowRight,
      LogicalKeyboardKey.keyD,
    ]);
    final keyJump = _keyDown(keys, const [
      LogicalKeyboardKey.space,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.keyW,
    ]);
    final keyFire = _keyDown(keys, const [
      LogicalKeyboardKey.keyX,
      LogicalKeyboardKey.keyJ,
      LogicalKeyboardKey.shiftLeft,
      LogicalKeyboardKey.shiftRight,
    ]);
    final keyPipe = _keyDown(keys, const [
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.keyS,
    ]);

    player.wantLeft = ctrlLeft || keyLeft || padLeft;
    player.wantRight = ctrlRight || keyRight || padRight;
    player.wantJump = ctrlJump || keyJump || padJump;
    player.wantShoot = ctrlFire || keyFire || padFire;
    if (ctrlPipe || keyPipe || padPipe) {
      for (final p in pipes) {
        p.tryEnter(player);
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape ||
          event.logicalKey == LogicalKeyboardKey.keyP) {
        togglePause();
      }
    }
    return KeyEventResult.handled;
  }

  Future<void> loadLevel(int n) async {
    world.removeAll(world.children.toList());
    pipes.clear();
    currentLevel = n;
    final data = Levels.get(n);
    levelEndX = data.endX;
    levelTimer = 0;
    phase = PlayPhase.playing;
    levelClearTimer = 0;

    juice = JuiceSystem();
    world.add(_SkyBackdrop());

    for (final c in data.clouds) {
      world.add(CloudComponent(c));
    }
    for (final p in data.platforms) {
      world.add(PlatformBlock(p));
    }
    for (final b in data.blocks) {
      world.add(BlockComponent(b));
    }
    for (final c in data.coins) {
      world.add(CoinComponent(c.x, c.y));
    }
    for (final e in data.enemies) {
      final enemy = EnemyComponent(e);
      enemy.speedMult = switch (difficulty) {
        Difficulty.hard => 1.35,
        Difficulty.easy => 0.75,
        Difficulty.normal => 1.0,
      };
      world.add(enemy);
    }
    for (final s in data.spikes) {
      world.add(SpikeComponent(s));
    }
    for (final pu in data.powerUps) {
      world.add(PowerUpComponent(pu));
    }
    for (final cp in data.checkpoints) {
      world.add(CheckpointComponent(cp));
    }
    for (final pipe in data.pipes) {
      final p = PipeComponent(pipe);
      pipes.add(p);
      world.add(p);
    }

    final spawn = hasCheckpoint
        ? Vector2(checkpointX, checkpointY - 50)
        : Vector2(60, 400);
    player = PlayerComponent(position: spawn);
    world.add(player);
    world.add(juice);
    lastPlayerX = player.position.x;

    world.add(_GoalFlag(Vector2(levelEndX, 200)));
  }

  void spawnFireball(Vector2 pos, bool right) {
    world.add(FireballComponent(pos, right));
  }

  void setCheckpoint(double x, double y) {
    checkpointX = x;
    checkpointY = y;
    hasCheckpoint = true;
  }

  void onCoinCollected() {
    coins++;
    score += 50;
    stats.totalCoinsCollected++;
    if (coins >= 100) {
      coins = 0;
      lives++;
    }
  }

  void onEnemyKilled(int points) {
    score += points;
    stats.enemiesKilled++;
  }

  void onPowerUpCollected() {
    stats.powerUpsCollected++;
    score += 200;
  }

  void onPlayerDied() {
    lives--;
    juice.shake(intensity: 12, duration: 0.4);
    if (lives <= 0) {
      phase = PlayPhase.gameOver;
      _handleGameOver();
    } else {
      player.respawn(Vector2(
        hasCheckpoint ? checkpointX : 60,
        hasCheckpoint ? checkpointY - 50 : 400,
      ));
      player.dead = false;
    }
  }

  Future<void> _handleGameOver() async {
    await _statsSvc.save(stats);
    final name = await onNeedName?.call(score);
    if (name != null && name.isNotEmpty) {
      await _scores.tryAdd(HighScore(
        name: name,
        score: score,
        level: currentLevel,
        difficulty: difficulty,
      ));
    }
  }

  Future<void> saveGame() async {
    await _saves.save(SaveData(
      currentLevel: currentLevel,
      score: score,
      lives: lives,
      coinsCollected: coins,
      checkpointX: checkpointX,
      checkpointY: checkpointY,
      hasCheckpoint: hasCheckpoint,
      difficulty: difficulty,
      stats: stats,
    ));
    await _statsSvc.save(stats);
  }

  void togglePause() {
    if (phase == PlayPhase.playing) {
      phase = PlayPhase.paused;
      pauseEngine();
    } else if (phase == PlayPhase.paused) {
      phase = PlayPhase.playing;
      resumeEngine();
    }
  }

  @override
  void update(double dt) {
    final scaled = dt * (juice.isFrozen ? 0.15 : 1.0);
    if (phase == PlayPhase.levelClear) {
      levelClearTimer += dt;
      if (levelClearTimer > 2.8) {
        _advanceLevel();
      }
      super.update(scaled * 0.35);
      return;
    }
    if (phase != PlayPhase.playing) {
      super.update(0);
      return;
    }

    _applyInputs();

    super.update(scaled);

    levelTimer += dt;
    stats.totalPlayTime += dt;
    stats.distanceTraveled += (player.position.x - lastPlayerX).abs();
    lastPlayerX = player.position.x;

    // camera follow
    final target = (player.position.x - size.x * 0.35).clamp(0.0, levelEndX);
    cameraX += (target - cameraX) * 6 * dt;
    final shake = juice.cameraOffset();
    camera.viewfinder.position = Vector2(cameraX + shake.x, shake.y - 40);

    if (player.dead && phase == PlayPhase.playing) {
      onPlayerDied();
    }

    if (player.position.x >= levelEndX - 40 && phase == PlayPhase.playing) {
      _onLevelClear();
    }
  }

  Future<void> _onLevelClear() async {
    phase = PlayPhase.levelClear;
    levelClearTimer = 0;
    stats.levelsCompleted++;
    score += 1000;
    juice.burst(player.absoluteCenter, color: MarioColors.yellow, count: 40);
    juice.shake(intensity: 5, duration: 0.4);
    await AudioService.instance.playLevelClear();
  }

  Future<void> _advanceLevel() async {
    hasCheckpoint = false;
    if (currentLevel >= 10) {
      phase = PlayPhase.gameOver;
      await _handleGameOver();
      return;
    }
    await AudioService.instance.resumeBgmAfterClear();
    await loadLevel(currentLevel + 1);
  }
}

class _SkyBackdrop extends PositionComponent {
  _SkyBackdrop() : super(position: Vector2.zero(), size: Vector2(5000, 800), priority: -20);

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [MarioColors.skyTop, MarioColors.skyBottom, Color(0xFF8FDE7A)],
          stops: [0, 0.72, 1],
        ).createShader(rect),
    );
  }
}

class _GoalFlag extends PositionComponent {
  _GoalFlag(Vector2 pos) : super(position: pos, size: Vector2(20, 120), priority: 5);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(8, 0, 4, 120), Paint()..color = Colors.white);
    final path = Path()
      ..moveTo(12, 8)
      ..lineTo(48, 24)
      ..lineTo(12, 40)
      ..close();
    canvas.drawPath(path, Paint()..color = MarioColors.yellow);
  }
}
