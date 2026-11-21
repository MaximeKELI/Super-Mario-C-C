import 'models.dart';
import 'secure_store.dart';

/// Offline plausibility — blocks "god" saves that no human run can produce.
class AntiCheat {
  AntiCheat._();

  /// Soft ceiling: ~level clears + dense combat, not raw max int.
  static int maxScoreForLevel(int level) {
    final lv = level.clamp(1, SecureStore.maxLevel);
    return lv * 12000 + 15000;
  }

  static bool plausibleSave(SaveData d) {
    if (d.score < 0 || d.score > SecureStore.maxScore) return false;
    if (d.lives < 0 || d.lives > SecureStore.maxLives) return false;
    if (d.currentLevel < 1 || d.currentLevel > SecureStore.maxLevel) return false;
    if (d.score > maxScoreForLevel(d.currentLevel)) return false;

    // Max score only reachable by finishing the campaign.
    if (d.score >= SecureStore.maxScore && d.currentLevel < SecureStore.maxLevel) {
      return false;
    }

    final t = d.stats.totalPlayTime;
    if (d.score >= 80000 && t < 90) return false;
    if (d.score >= 200000 && t < 240) return false;
    if (d.score >= 500000 && t < 600) return false;

    // Score without any play / kills is suspicious at mid+ values.
    if (d.score >= 30000 &&
        d.stats.enemiesKilled == 0 &&
        d.stats.totalCoinsCollected == 0 &&
        d.stats.levelsCompleted == 0) {
      return false;
    }

    return true;
  }

  static bool plausibleHighScore(HighScore h, {double? sessionPlayTime}) {
    if (!h.isPlausible) return false;
    if (h.score > maxScoreForLevel(h.level)) return false;
    if (h.score >= SecureStore.maxScore && h.level < SecureStore.maxLevel) {
      return false;
    }
    if (sessionPlayTime != null) {
      if (h.score >= 80000 && sessionPlayTime < 90) return false;
      if (h.score >= 200000 && sessionPlayTime < 240) return false;
    }
    return true;
  }
}
