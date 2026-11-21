import 'dart:math';

import 'package:flutter/foundation.dart';

import 'secure_store.dart';

/// In-memory anti-cheat for score/lives/coins + speedhack damping.
///
/// Dual XOR mirrors make single-field GameGuardian edits obvious.
class RuntimeGuard {
  int score = 0;
  int lives = 0;
  int coins = 0;
  int level = 1;

  int _mask = 1;
  int _xScore = 0;
  int _xLives = 0;
  int _xCoins = 0;
  int _xLevel = 0;
  int _guard = 0;

  int _dtSpikes = 0;
  static const _maxDt = 0.05; // clamp simulation step
  static const _spikeDt = 0.22;

  final Random _rng = Random.secure();

  void bootstrap({
    required int score,
    required int lives,
    required int coins,
    required int level,
  }) {
    this.score = score.clamp(0, SecureStore.maxScore);
    this.lives = lives.clamp(0, SecureStore.maxLives);
    this.coins = coins.clamp(0, 99);
    this.level = level.clamp(1, SecureStore.maxLevel);
    seal();
  }

  void seal() {
    _mask = (_rng.nextInt(0x3fffffff) | 1);
    _xScore = score ^ _mask;
    _xLives = lives ^ (_mask << 1);
    _xCoins = coins ^ (_mask >> 1);
    _xLevel = level ^ (_mask ^ 0xA5A5);
    _guard = Object.hash(
      score,
      lives,
      coins,
      level,
      _xScore,
      _xLives,
      _xCoins,
      _xLevel,
      _mask,
    );
  }

  bool get intact {
    if (score != (_xScore ^ _mask)) return false;
    if (lives != (_xLives ^ (_mask << 1))) return false;
    if (coins != (_xCoins ^ (_mask >> 1))) return false;
    if (level != (_xLevel ^ (_mask ^ 0xA5A5))) return false;
    return _guard ==
        Object.hash(
          score,
          lives,
          coins,
          level,
          _xScore,
          _xLives,
          _xCoins,
          _xLevel,
          _mask,
        );
  }

  /// On tamper: restore from XOR mirrors when possible, else clamp.
  void recover() {
    if (!kReleaseMode) {
      debugPrint('RuntimeGuard: tamper — recovering');
    }
    final s = _xScore ^ _mask;
    final l = _xLives ^ (_mask << 1);
    final c = _xCoins ^ (_mask >> 1);
    final lv = _xLevel ^ (_mask ^ 0xA5A5);
    score = s.clamp(0, SecureStore.maxScore);
    lives = l.clamp(0, SecureStore.maxLives);
    coins = c.clamp(0, 99);
    level = lv.clamp(1, SecureStore.maxLevel);
    seal();
  }

  void ensure() {
    if (!intact) recover();
  }

  void setScore(int v) {
    ensure();
    score = v.clamp(0, SecureStore.maxScore);
    seal();
  }

  void addScore(int delta) {
    ensure();
    score = (score + delta.clamp(0, 5000)).clamp(0, SecureStore.maxScore);
    seal();
  }

  void setLives(int v) {
    ensure();
    lives = v.clamp(0, SecureStore.maxLives);
    seal();
  }

  void addLife([int n = 1]) {
    ensure();
    lives = (lives + n).clamp(0, SecureStore.maxLives);
    seal();
  }

  void loseLife() {
    ensure();
    lives = (lives - 1).clamp(0, SecureStore.maxLives);
    seal();
  }

  void setCoins(int v) {
    ensure();
    coins = v.clamp(0, 99);
    seal();
  }

  void addCoin() {
    ensure();
    coins += 1;
    if (coins >= 100) {
      coins = 0;
      lives = (lives + 1).clamp(0, SecureStore.maxLives);
    }
    seal();
  }

  void setLevel(int v) {
    ensure();
    level = v.clamp(1, SecureStore.maxLevel);
    seal();
  }

  /// Returns a safe dt; counts speedhack-like spikes.
  double sanitizeDt(double dt) {
    if (dt.isNaN || dt.isNegative || dt.isInfinite) return 0;
    if (dt > _spikeDt) {
      _dtSpikes++;
      return _maxDt;
    }
    if (dt > _maxDt) return _maxDt;
    return dt;
  }

  bool get suspiciousSpeed => _dtSpikes >= 8;
}
