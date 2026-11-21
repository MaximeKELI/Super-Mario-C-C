import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'secure_store.dart';

class SaveService {
  static const _key = 'pipeleap_save';

  Future<void> save(SaveData data) async {
    final prefs = await SharedPreferences.getInstance();
    final sealed = SecureStore.seal(data.toJson());
    await prefs.setString(_key, jsonEncode(sealed));
  }

  Future<SaveData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key) ?? prefs.getString('mario_save');
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      final payload = SecureStore.open(decoded);
      if (payload == null) {
        // Tampered or corrupt — wipe so Continue can't softlock.
        await clear();
        return null;
      }
      final data = SaveData.fromJson(payload);
      // Re-seal legacy unsealed saves on next write path via caller.
      return data;
    } catch (e, st) {
      debugPrint('SaveService.load failed: $e\n$st');
      await clear();
      return null;
    }
  }

  Future<bool> hasSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key) || prefs.containsKey('mario_save');
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove('mario_save');
  }
}

class HighScoreService {
  static const _key = 'pipeleap_high_scores';
  static const _legacyKey = 'mario_high_scores';
  static const maxScores = 10;

  Future<List<HighScore>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key) ?? prefs.getString(_legacyKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      List<dynamic> list;
      if (decoded is List) {
        // Legacy unsealed array.
        list = decoded;
      } else {
        final payload = SecureStore.open(decoded);
        if (payload == null) {
          await prefs.remove(_key);
          await prefs.remove(_legacyKey);
          return [];
        }
        final scoresRaw = payload['scores'];
        if (scoresRaw is! List) return [];
        list = scoresRaw;
      }
      final scores = list
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
    final sealed = SecureStore.seal({
      'scores': scores.map((s) => s.toJson()).toList(),
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
    final raw = prefs.getString(_key) ?? prefs.getString(_legacyKey);
    if (raw == null) return GameStats();
    try {
      final decoded = jsonDecode(raw);
      final payload = SecureStore.open(decoded);
      if (payload == null) {
        await prefs.remove(_key);
        await prefs.remove(_legacyKey);
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
    final sealed = SecureStore.seal(stats.toJson());
    await prefs.setString(_key, jsonEncode(sealed));
    await prefs.remove(_legacyKey);
  }

  /// Permanently add a finished session onto lifetime totals (never overwrite).
  Future<void> mergeSession(GameStats session) async {
    final lifetime = await load();
    await save(lifetime.mergedWith(session));
  }
}
