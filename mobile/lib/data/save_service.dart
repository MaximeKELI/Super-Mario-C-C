import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'secure_store.dart';

class SaveService {
  static const _key = 'pipeleap_save';
  static const _legacyKeys = ['mario_save'];

  Future<void> save(SaveData data) async {
    final prefs = await SharedPreferences.getInstance();
    final sealed = await SecureStore.seal(data.toJson());
    await prefs.setString(_key, jsonEncode(sealed));
    for (final k in _legacyKeys) {
      await prefs.remove(k);
    }
  }

  Future<SaveData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    // Do not read legacy cleartext keys — they were a forge vector.
    for (final k in _legacyKeys) {
      if (prefs.containsKey(k)) await prefs.remove(k);
    }
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    if (raw.length > SecureStore.maxPayloadBytes) {
      await clear();
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      final payload = await SecureStore.open(decoded);
      if (payload == null) {
        await clear();
        return null;
      }
      return SaveData.fromJson(payload);
    } catch (e, st) {
      debugPrint('SaveService.load failed: $e\n$st');
      await clear();
      return null;
    }
  }

  Future<bool> hasSave() async {
    final data = await load();
    return data != null;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    for (final k in _legacyKeys) {
      await prefs.remove(k);
    }
  }
}

class HighScoreService {
  static const _key = 'pipeleap_high_scores';
  static const _legacyKey = 'mario_high_scores';
  static const maxScores = 10;

  Future<List<HighScore>> load() async {
    final prefs = await SharedPreferences.getInstance();
    // Purge forgeable legacy list format.
    if (prefs.containsKey(_legacyKey)) {
      await prefs.remove(_legacyKey);
    }
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    if (raw.length > SecureStore.maxPayloadBytes) {
      await prefs.remove(_key);
      return [];
    }
    try {
      final decoded = jsonDecode(raw);
      // Raw JSON arrays were forgeable — never accept.
      if (decoded is List) {
        await prefs.remove(_key);
        return [];
      }
      final payload = await SecureStore.open(decoded);
      if (payload == null) {
        await prefs.remove(_key);
        return [];
      }
      final scoresRaw = payload['scores'];
      if (scoresRaw is! List) return [];
      final scores = scoresRaw
          .whereType<Map>()
          .map((e) => HighScore.fromJson(Map<String, dynamic>.from(e)))
          .where((s) => s.isPlausible)
          .toList()
        ..sort((a, b) => b.score.compareTo(a.score));
      return scores.take(maxScores).toList();
    } catch (e, st) {
      debugPrint('HighScoreService.load failed: $e\n$st');
      return [];
    }
  }

  Future<void> saveAll(List<HighScore> scores) async {
    final prefs = await SharedPreferences.getInstance();
    final plausible = scores.where((s) => s.isPlausible).take(maxScores).toList();
    final sealed = await SecureStore.seal({
      'scores': plausible.map((s) => s.toJson()).toList(),
    });
    await prefs.setString(_key, jsonEncode(sealed));
    await prefs.remove(_legacyKey);
  }

  Future<bool> tryAdd(HighScore score) async {
    final sanitized = HighScore(
      name: SecureStore.sanitizeName(score.name),
      score: SecureStore.clampScore(score.score),
      level: SecureStore.clampLevel(score.level),
      difficulty: score.difficulty,
    );
    if (!sanitized.isPlausible) return false;

    final scores = await load();
    scores.sort((a, b) => b.score.compareTo(a.score));
    if (scores.length >= maxScores && sanitized.score < scores.last.score) {
      return false;
    }
    scores.add(sanitized);
    scores.sort((a, b) => b.score.compareTo(a.score));
    final trimmed = scores.take(maxScores).toList();
    await saveAll(trimmed);
    return trimmed.any((s) =>
        s.name == sanitized.name &&
        s.score == sanitized.score &&
        s.level == sanitized.level);
  }
}

class StatsService {
  static const _key = 'pipeleap_stats';
  static const _legacyKey = 'mario_stats';

  Future<GameStats> load() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_legacyKey)) {
      await prefs.remove(_legacyKey);
    }
    final raw = prefs.getString(_key);
    if (raw == null) return GameStats();
    if (raw.length > SecureStore.maxPayloadBytes) {
      await prefs.remove(_key);
      return GameStats();
    }
    try {
      final decoded = jsonDecode(raw);
      final payload = await SecureStore.open(decoded);
      if (payload == null) {
        await prefs.remove(_key);
        return GameStats();
      }
      return GameStats.fromJson(payload);
    } catch (e, st) {
      debugPrint('StatsService.load failed: $e\n$st');
      return GameStats();
    }
  }

  Future<void> save(GameStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    final sealed = await SecureStore.seal(stats.toJson());
    await prefs.setString(_key, jsonEncode(sealed));
    await prefs.remove(_legacyKey);
  }

  Future<void> mergeSession(GameStats session) async {
    final lifetime = await load();
    await save(lifetime.mergedWith(session));
  }
}
