import 'package:flutter_test/flutter_test.dart';

import 'package:super_mario_mobile/data/levels/levels.dart';
import 'package:super_mario_mobile/data/models.dart';

void main() {
  test('all 10 levels load with platforms', () {
    for (var i = 1; i <= 10; i++) {
      final level = Levels.get(i);
      expect(level.number, i);
      expect(level.platforms, isNotEmpty);
      expect(level.endX, greaterThan(1000));
    }
  });

  test('save data roundtrip fields', () {
    final data = SaveData(
      currentLevel: 3,
      score: 1200,
      lives: 4,
      difficulty: Difficulty.hard,
      stats: GameStats(enemiesKilled: 5),
    );
    final json = data.toJson();
    final back = SaveData.fromJson(json);
    expect(back.currentLevel, 3);
    expect(back.score, 1200);
    expect(back.difficulty, Difficulty.hard);
    expect(back.stats.enemiesKilled, 5);
  });
}
