
import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamepads/gamepads.dart';

import '../audio/audio_service.dart';
import '../data/character.dart';
import '../data/levels/levels.dart';
import '../data/models.dart';
import '../data/save_service.dart';
import '../data/secure_store.dart';
import '../theme/app_theme.dart';
import 'components/ambient_fx.dart';
import 'components/block.dart';
import 'components/coin.dart';
import 'components/depth_backdrop.dart';
import 'components/enemy.dart';
import 'components/fireball.dart';
import 'components/platform_block.dart';
import 'components/player.dart';
import 'components/power_up.dart';
import 'components/world_props.dart';
import 'systems/juice_system.dart';

enum PlayPhase { playing, paused, levelClear, advancing, gameOver, victory }

class PipeLeapGame extends FlameGame with HasCollisionDetection, KeyboardEvents, TapCallbacks {
  PipeLeapGame({
    required this.difficulty,
    this.character = PlayableCharacter.pip,
    this.startLevel = 1,
    this.initialSave,
    this.onExitToMenu,
    this.onNeedName,
  });

  /// Design resolution matching the original SDL playfield (letterboxed on device).
  static final Vector2 designResolution = Vector2(800, 600);

  final Difficulty difficulty;
  final PlayableCharacter character;
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
  int comboCount = 0;
  double comboTimer = 0;

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
  bool worldReady = false;
  bool _sessionEnded = false;

  /// Runtime anti-tamper: mirrors score/lives/coins so memory edits trip a check.
  int _economyGuard = 0;
  static const _guardSalt = 0x50495045; // 'PIPE'

  @override
  Color backgroundColor() => AppColors.skyTop;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    juice = JuiceSystem();
    camera.viewport = FixedResolutionViewport(resolution: designResolution);
    camera.viewfinder.anchor = Anchor.topLeft;
    _padSub = Gamepads.normalizedEvents.listen(_onGamepad);

    if (initialSave != null) {
      currentLevel = initialSave!.currentLevel.clamp(1, 10);
      score = initialSave!.score.clamp(0, SecureStore.maxScore);
      lives = initialSave!.lives.clamp(0, _maxLivesForDifficulty());
      coins = initialSave!.coinsCollected.clamp(0, 99);
      checkpointX = initialSave!.checkpointX;
      checkpointY = initialSave!.checkpointY;
      hasCheckpoint = initialSave!.hasCheckpoint;
      stats = initialSave!.stats;
    } else {
      currentLevel = startLevel;
      lives = _maxLivesForDifficulty();
    }
    _sealEconomy();

    await loadLevel(currentLevel);
    AudioService.instance.playBgm();
  }

  int _maxLivesForDifficulty() => switch (difficulty) {
        Difficulty.easy => 5,
        Difficulty.normal => 3,
        Difficulty.hard => 2,
      };

  void _sealEconomy() {
    _economyGuard = Object.hash(
      score,
      lives,
      coins,
      currentLevel,
      _guardSalt ^ (score * 131) ^ (lives * 17) ^ (coins * 13),
    );
  }

  bool _economyIntact() =>
      _economyGuard ==
      Object.hash(
        score,
        lives,
        coins,
        currentLevel,
        _guardSalt ^ (score * 131) ^ (lives * 17) ^ (coins * 13),
      );

  void _onEconomyTamper() {
    debugPrint('PipeLeap: economy tamper detected — clamping');
    score = score.clamp(0, SecureStore.maxScore);
    lives = lives.clamp(0, _maxLivesForDifficulty());
    coins = coins.clamp(0, 99);
    currentLevel = currentLevel.clamp(1, 10);
    _sealEconomy();
  }

  void awardScore(int points) {
    if (!_economyIntact()) _onEconomyTamper();
    final p = points.clamp(0, 5000);
    score = (score + p).clamp(0, SecureStore.maxScore);
    _sealEconomy();
  }

  void awardLife([int n = 1]) {
    if (!_economyIntact()) _onEconomyTamper();
    lives = (lives + n).clamp(0, SecureStore.maxLives);
    _sealEconomy();
  }

  void loseLife() {
    if (!_economyIntact()) _onEconomyTamper();
    lives = (lives - 1).clamp(0, SecureStore.maxLives);
    _sealEconomy();
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

  void _applyInputs() {
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    // Touches directionnelles pour le déplacement
    final keyLeft = keys.contains(LogicalKeyboardKey.arrowLeft);
    final keyRight = keys.contains(LogicalKeyboardKey.arrowRight);
    final keyJump = keys.contains(LogicalKeyboardKey.arrowUp) ||
        keys.contains(LogicalKeyboardKey.space);
    final keyFire =
        keys.contains(LogicalKeyboardKey.keyX) || keys.contains(LogicalKeyboardKey.keyJ);
    final keyPipe = keys.contains(LogicalKeyboardKey.arrowDown);

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
    worldReady = false;
    try {
      // Snapshot then remove — avoid racing with deferred Flame removals.
      final previous = world.children.toList();
      world.removeAll(previous);
      for (final child in previous) {
        await child.removed;
      }
      pipes.clear();
      currentLevel = n.clamp(1, 10);
      cameraX = 0;
      camera.viewfinder.position = Vector2.zero();
      final data = Levels.get(currentLevel);
      levelEndX = data.endX;
      levelTimer = 0;
      phase = PlayPhase.playing;
      levelClearTimer = 0;

      juice = JuiceSystem();
      world.add(DepthBackdrop());
      comboCount = 0;
      comboTimer = 0;

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
        final enemy = EnemyComponent(e)..speedMult = speedMultForDifficulty();
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
      player = PlayerComponent(position: spawn, character: character);
      world.add(player);
      world.add(AmbientFx(levelEndX: levelEndX));
      world.add(juice);
      lastPlayerX = player.position.x;

      world.add(_GoalFlag(Vector2(levelEndX, 200)));
      worldReady = true;
    } catch (e, st) {
      debugPrint('loadLevel($n) failed: $e\n$st');
      worldReady = false;
      phase = PlayPhase.gameOver;
      await _handleSessionEnd(victory: false);
    }
  }

  void spawnFireball(Vector2 pos, bool right) {
    world.add(FireballComponent(pos, right));
  }

  void alertNearby(Vector2 origin, double radius) {
    for (final c in world.children) {
      if (c is EnemyComponent && !c.dead) {
        if ((c.absoluteCenter - origin).length <= radius) {
          c.receiveAlert(origin);
        }
      }
    }
  }

  void onBossDefeated(Vector2 at) {
    for (final c in world.children) {
      if (c is EnemyComponent && !c.dead && c.kind != EnemyKind.boss) {
        c.forceFlee();
      }
    }
    juice.leaves(at, count: 14);
  }

  void spawnMinionNear(Vector2 at) {
    var spawned = 0;
    for (final offset in [Vector2(-40, 0), Vector2(40, 0)]) {
      if (spawned >= 2) break;
      final def = EnemyDef(at.x + offset.x, at.y, EnemyKind.grunt);
      final e = EnemyComponent(def)..speedMult = speedMultForDifficulty();
      e.state = EnemyState.chase;
      e.stateTimer = 2;
      world.add(e);
      spawned++;
    }
  }

  double speedMultForDifficulty() => switch (difficulty) {
        Difficulty.hard => 1.35,
        Difficulty.easy => 0.75,
        Difficulty.normal => 1.0,
      };

  void setCheckpoint(double x, double y) {
    checkpointX = x;
    checkpointY = y;
    hasCheckpoint = true;
  }

  void onCoinCollected() {
    if (!_economyIntact()) _onEconomyTamper();
    coins += 1;
    stats.totalCoinsCollected++;
    score = (score + 50).clamp(0, SecureStore.maxScore);
    if (coins >= 100) {
      coins = 0;
      lives = (lives + 1).clamp(0, SecureStore.maxLives);
    }
    _sealEconomy();
  }

  void onEnemyKilled(int points) {
    if (comboTimer > 0) {
      comboCount++;
    } else {
      comboCount = 1;
    }
    comboTimer = 1.6;
    final bonus = (comboCount - 1) * 25;
    awardScore(points.clamp(0, 500) + bonus);
    stats.enemiesKilled++;
    if (comboCount >= 2) {
      juice.scorePopup(
        player.absoluteCenter + Vector2(0, -40),
        'COMBO x$comboCount${bonus > 0 ? ' +$bonus' : ''}',
      );
      juice.ring(player.absoluteCenter, color: AppColors.yellow, count: 10 + comboCount);
    }
  }

  void onPowerUpCollected() {
    stats.powerUpsCollected++;
    awardScore(200);
  }

  void onPlayerDied() {
    loseLife();
    comboCount = 0;
    comboTimer = 0;
    juice.shake(intensity: 12, duration: 0.4);
    juice.flashDamage(0.4);
    if (lives <= 0) {
      phase = PlayPhase.gameOver;
      unawaited(_handleSessionEnd(victory: false));
    } else {
      player.respawn(Vector2(
        hasCheckpoint ? checkpointX : 60,
        hasCheckpoint ? checkpointY - 50 : 400,
      ));
      player.dead = false;
    }
  }

  Future<void> _handleSessionEnd({required bool victory}) async {
    if (_sessionEnded) return;
    _sessionEnded = true;
    await AudioService.instance.stopBgm();
    // Merge session into lifetime totals — never overwrite.
    await _statsSvc.mergeSession(stats);
    await _saves.clear();
    final name = await onNeedName?.call(score);
    if (name != null && name.isNotEmpty) {
      await _scores.tryAdd(HighScore(
        name: name,
        score: score,
        level: currentLevel,
        difficulty: difficulty,
      ));
    }
    if (victory) {
      phase = PlayPhase.victory;
    }
  }

  Future<void> saveGame() async {
    if (_sessionEnded || phase == PlayPhase.gameOver || phase == PlayPhase.victory) {
      return;
    }
    // Persist mid-run progress only. Lifetime stats update on session end.
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
  }

  void togglePause() {
    if (phase == PlayPhase.playing) {
      phase = PlayPhase.paused;
      pauseEngine();
      unawaited(AudioService.instance.pauseBgm());
    } else if (phase == PlayPhase.paused) {
      phase = PlayPhase.playing;
      resumeEngine();
      unawaited(AudioService.instance.resumeBgm());
    }
  }

  /// App lifecycle: freeze when backgrounded so audio/CPU stay quiet.
  void onAppPaused() {
    unawaited(AudioService.instance.pauseBgm());
    if (phase == PlayPhase.playing) {
      phase = PlayPhase.paused;
      pauseEngine();
    } else if (phase == PlayPhase.levelClear || phase == PlayPhase.advancing) {
      pauseEngine();
    }
  }

  void onAppResumed() {
    if (phase == PlayPhase.paused) {
      // Stay paused — player must resume explicitly (overlay already up).
      return;
    }
    if (phase == PlayPhase.levelClear || phase == PlayPhase.advancing) {
      resumeEngine();
      return;
    }
    if (phase == PlayPhase.playing) {
      resumeEngine();
      unawaited(AudioService.instance.resumeBgm());
    }
  }

  @override
  void update(double dt) {
    if (worldReady && !_economyIntact()) {
      _onEconomyTamper();
    }
    final scaled = dt * (juice.isFrozen ? 0.15 : 1.0);
    if (phase == PlayPhase.levelClear) {
      levelClearTimer += dt;
      if (levelClearTimer > 2.8) {
        // Guard: without this, every frame re-enters _advanceLevel and
        // spawns duplicate players while awaits are in flight.
        phase = PlayPhase.advancing;
        unawaited(_advanceLevel());
      }
      super.update(scaled * 0.35);
      return;
    }
    if (phase == PlayPhase.advancing) {
      super.update(0);
      return;
    }
    if (phase != PlayPhase.playing) {
      super.update(0);
      return;
    }

    _applyInputs();

    super.update(scaled);

    if (comboTimer > 0) {
      comboTimer -= dt;
      if (comboTimer <= 0) comboCount = 0;
    }

    levelTimer += dt;
    stats.totalPlayTime += dt;
    stats.distanceTraveled += (player.position.x - lastPlayerX).abs();
    lastPlayerX = player.position.x;

    // camera follow
    final target = (player.position.x - size.x * 0.35).clamp(0.0, levelEndX);
    cameraX += (target - cameraX) * 6 * dt;
    final shake = juice.cameraOffset();
    // Slight vertical settle for a 2.5D stage feel
    final camY = -36 + (player.position.y - 400) * 0.04;
    camera.viewfinder.position = Vector2(cameraX + shake.x, camY + shake.y);

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
    awardScore(1000);
    juice.burst(player.absoluteCenter, color: AppColors.yellow, count: 40);
    juice.shake(intensity: 5, duration: 0.4);
    await AudioService.instance.playLevelClear();
  }

  Future<void> _advanceLevel() async {
    try {
      hasCheckpoint = false;
      if (currentLevel >= 10) {
        phase = PlayPhase.victory;
        await _handleSessionEnd(victory: true);
        return;
      }
      await AudioService.instance.resumeBgmAfterClear();
      await loadLevel(currentLevel + 1);
    } catch (e, st) {
      debugPrint('_advanceLevel failed: $e\n$st');
      phase = PlayPhase.gameOver;
      await _handleSessionEnd(victory: false);
    }
  }
}

class _GoalFlag extends PositionComponent {
  _GoalFlag(Vector2 pos) : super(position: pos, size: Vector2(20, 120), priority: 5);

  @override
  void render(Canvas canvas) {
    // Pole with slight extrusion
    canvas.drawRect(const Rect.fromLTWH(10, 0, 5, 120), Paint()..color = const Color(0xFFE8E8E8));
    canvas.drawRect(const Rect.fromLTWH(14, 0, 2, 120), Paint()..color = Colors.white70);
    final path = Path()
      ..moveTo(15, 6)
      ..lineTo(52, 22)
      ..lineTo(15, 38)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.yellow);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFF3A0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }
}
