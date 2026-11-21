import 'dart:math';

import 'package:flutter/foundation.dart';

import 'secure_store.dart';

/// In-memory anti-cheat: canonical state lives ONLY in XOR mirrors.
///
/// There is no plain `score` field to poke. Re-bootstrap is ignored once locked.
class RuntimeGuard {
  int _mask = 1;
  int _xScore = 0;
  int _xLives = 0;
  int _xCoins = 0;
  int _xLevel = 0;
  int _guard = 0;
  bool _locked = false;

  int _dtSpikes = 0;
  static const _maxDt = 0.05;
  static const _spikeDt = 0.22;

  final Random _rng = Random.secure();

  int get score {
    ensure();
    return _decodeScore();
  }

  int get lives {
    ensure();
    return _decodeLives();
  }

  int get coins {
    ensure();
    return _decodeCoins();
  }

  int get level {
    ensure();
    return _decodeLevel();
  }

  int _decodeScore() => (_xScore ^ _mask).clamp(0, SecureStore.maxScore);
  int _decodeLives() => (_xLives ^ (_mask << 1)).clamp(0, SecureStore.maxLives);
  int _decodeCoins() => (_xCoins ^ (_mask >> 1)).clamp(0, 99);
  int _decodeLevel() => (_xLevel ^ (_mask ^ 0xA5A5)).clamp(1, SecureStore.maxLevel);

  void bootstrap({
    required int score,
    required int lives,
    required int coins,
    required int level,
  }) {
    // Prevent Frida-style re-bootstrap into god mode after session start.
    if (_locked && intact) return;
    _writeAll(
      score: score.clamp(0, SecureStore.maxScore),
      lives: lives.clamp(0, SecureStore.maxLives),
      coins: coins.clamp(0, 99),
      level: level.clamp(1, SecureStore.maxLevel),
    );
    _locked = true;
  }

  void _writeAll({
    required int score,
    required int lives,
    required int coins,
    required int level,
  }) {
    _mask = (_rng.nextInt(0x3fffffff) | 1);
    _xScore = score ^ _mask;
    _xLives = lives ^ (_mask << 1);
    _xCoins = coins ^ (_mask >> 1);
    _xLevel = level ^ (_mask ^ 0xA5A5);
    _guard = _computeGuard(score, lives, coins, level);
  }

  int _computeGuard(int score, int lives, int coins, int level) => Object.hash(
        score,
        lives,
        coins,
        level,
        _xScore,
        _xLives,
        _xCoins,
        _xLevel,
        _mask ^ 0x50495045,
      );

  bool get intact {
    final s = _xScore ^ _mask;
    final l = _xLives ^ (_mask << 1);
    final c = _xCoins ^ (_mask >> 1);
    final lv = _xLevel ^ (_mask ^ 0xA5A5);
    if (s != s.clamp(0, SecureStore.maxScore)) return false;
    if (l != l.clamp(0, SecureStore.maxLives)) return false;
    if (c != c.clamp(0, 99)) return false;
    if (lv != lv.clamp(1, SecureStore.maxLevel)) return false;
    return _guard == _computeGuard(s, l, c, lv);
  }

  void recover() {
    if (!kReleaseMode) debugPrint('RuntimeGuard: tamper — recovering');
    // Restore from mirrors only (never accept external god values).
    final s = _decodeScore();
    final l = _decodeLives();
    final c = _decodeCoins();
    final lv = _decodeLevel();
    _writeAll(score: s, lives: l, coins: c, level: lv);
  }

  void ensure() {
    if (!intact) recover();
  }

  void addScore(int delta) {
    ensure();
    final next = (_decodeScore() + delta.clamp(0, 5000)).clamp(0, SecureStore.maxScore);
    _writeAll(
      score: next,
      lives: _decodeLives(),
      coins: _decodeCoins(),
      level: _decodeLevel(),
    );
  }

  void addLife([int n = 1]) {
    ensure();
    _writeAll(
      score: _decodeScore(),
      lives: (_decodeLives() + n).clamp(0, SecureStore.maxLives),
      coins: _decodeCoins(),
      level: _decodeLevel(),
    );
  }

  void loseLife() {
    ensure();
    _writeAll(
      score: _decodeScore(),
      lives: (_decodeLives() - 1).clamp(0, SecureStore.maxLives),
      coins: _decodeCoins(),
      level: _decodeLevel(),
    );
  }

  void addCoin() {
    ensure();
    var c = _decodeCoins() + 1;
    var l = _decodeLives();
    if (c >= 100) {
      c = 0;
      l = (l + 1).clamp(0, SecureStore.maxLives);
    }
    _writeAll(score: _decodeScore(), lives: l, coins: c, level: _decodeLevel());
  }

  void setLevel(int v) {
    ensure();
    _writeAll(
      score: _decodeScore(),
      lives: _decodeLives(),
      coins: _decodeCoins(),
      level: v.clamp(1, SecureStore.maxLevel),
    );
  }

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
