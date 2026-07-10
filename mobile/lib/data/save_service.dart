import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class SaveService {
  static const _key = 'mario_save';

  Future<void> save(SaveData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data.toJson()));
  }

  Future<SaveData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    return SaveData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<bool> hasSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class HighScoreService {
  static const _key = 'mario_high_scores';
  static const maxScores = 10;

  Future<List<HighScore>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => HighScore.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> saveAll(List<HighScore> scores) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(scores.map((s) => s.toJson()).toList()),
    );
  }

  Future<bool> tryAdd(HighScore score) async {
    final scores = await load();
    scores.add(score);
    scores.sort((a, b) => b.score.compareTo(a.score));
    final trimmed = scores.take(maxScores).toList();
    await saveAll(trimmed);
    return trimmed.any((s) =>
        s.name == score.name && s.score == score.score && s.level == score.level);
  }
}

class StatsService {
  static const _key = 'mario_stats';

  Future<GameStats> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return GameStats();
    return GameStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(GameStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(stats.toJson()));
  }
}
