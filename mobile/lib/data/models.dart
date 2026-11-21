import 'secure_store.dart';

enum Difficulty { easy, normal, hard }

enum PlatformKind { static_, movingH, movingV, destructible }

enum EnemyKind { grunt, sheller, flying, boss }

enum BlockKind { question, brick, hard }

enum PowerUpKind { mushroom, fireFlower, feather, star, oneUp, comet }

class PlatformDef {
  final double x, y, w, h;
  final PlatformKind kind;
  const PlatformDef(this.x, this.y, this.w, this.h, [this.kind = PlatformKind.static_]);
}

class EnemyDef {
  final double x, y;
  final EnemyKind kind;
  const EnemyDef(this.x, this.y, [this.kind = EnemyKind.grunt]);
}

class CoinDef {
  final double x, y;
  const CoinDef(this.x, this.y);
}

class BlockDef {
  final double x, y;
  final BlockKind kind;
  const BlockDef(this.x, this.y, this.kind);
}

class PowerUpDef {
  final double x, y;
  final PowerUpKind kind;
  const PowerUpDef(this.x, this.y, this.kind);
}

class SpikeDef {
  final double x, y, w, h;
  const SpikeDef(this.x, this.y, this.w, this.h);
}

class CloudDef {
  final double x, y, w, h;
  const CloudDef(this.x, this.y, this.w, this.h);
}

class CheckpointDef {
  final double x, y;
  const CheckpointDef(this.x, this.y);
}

class PipeDef {
  final double x, y, w, h, destX, destY;
  const PipeDef(this.x, this.y, this.w, this.h, this.destX, this.destY);
}

class LevelData {
  final int number;
  final String name;
  final List<PlatformDef> platforms;
  final List<EnemyDef> enemies;
  final List<CoinDef> coins;
  final List<BlockDef> blocks;
  final List<PowerUpDef> powerUps;
  final List<SpikeDef> spikes;
  final List<CloudDef> clouds;
  final List<CheckpointDef> checkpoints;
  final List<PipeDef> pipes;
  final double endX;

  const LevelData({
    required this.number,
    required this.name,
    required this.platforms,
    this.enemies = const [],
    this.coins = const [],
    this.blocks = const [],
    this.powerUps = const [],
    this.spikes = const [],
    this.clouds = const [],
    this.checkpoints = const [],
    this.pipes = const [],
    required this.endX,
  });
}

class HighScore {
  final String name;
  final int score;
  final int level;
  final Difficulty difficulty;

  const HighScore({
    required this.name,
    required this.score,
    required this.level,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'score': score,
        'level': level,
        'difficulty': difficulty.index,
      };

  factory HighScore.fromJson(Map<String, dynamic> j) {
    final diffIdx = (j['difficulty'] as num?)?.round() ?? 1;
    return HighScore(
      name: SecureStore.sanitizeName(j['name'] as String?),
      score: SecureStore.clampScore(j['score'] as num?),
      level: SecureStore.clampLevel(j['level'] as num?),
      difficulty: Difficulty.values[diffIdx.clamp(0, Difficulty.values.length - 1)],
    );
  }

  /// Reject absurd / clearly tampered entries.
  bool get isPlausible =>
      score >= 0 &&
      score <= SecureStore.maxScore &&
      level >= 1 &&
      level <= SecureStore.maxLevel &&
      name.isNotEmpty &&
      name.length <= SecureStore.maxNameLen;
}

class GameStats {
  double totalPlayTime;
  int enemiesKilled;
  int powerUpsCollected;
  double distanceTraveled;
  int totalCoinsCollected;
  int levelsCompleted;

  GameStats({
    this.totalPlayTime = 0,
    this.enemiesKilled = 0,
    this.powerUpsCollected = 0,
    this.distanceTraveled = 0,
    this.totalCoinsCollected = 0,
    this.levelsCompleted = 0,
  });

  Map<String, dynamic> toJson() => {
        'totalPlayTime': totalPlayTime,
        'enemiesKilled': enemiesKilled,
        'powerUpsCollected': powerUpsCollected,
        'distanceTraveled': distanceTraveled,
        'totalCoinsCollected': totalCoinsCollected,
        'levelsCompleted': levelsCompleted,
      };

  factory GameStats.fromJson(Map<String, dynamic> j) => GameStats(
        totalPlayTime: SecureStore.clampPlayTime(j['totalPlayTime'] as num?),
        enemiesKilled: SecureStore.clampStatInt(j['enemiesKilled'] as num?),
        powerUpsCollected: SecureStore.clampStatInt(j['powerUpsCollected'] as num?),
        distanceTraveled: SecureStore.clampPlayTime(j['distanceTraveled'] as num?),
        totalCoinsCollected: SecureStore.clampStatInt(j['totalCoinsCollected'] as num?),
        levelsCompleted: SecureStore.clampStatInt(j['levelsCompleted'] as num?)
            .clamp(0, SecureStore.maxLevel * 100),
      );

  /// Adds [session] onto this lifetime snapshot (does not mutate either).
  GameStats mergedWith(GameStats session) => GameStats(
        totalPlayTime: SecureStore.clampPlayTime(totalPlayTime + session.totalPlayTime),
        enemiesKilled: SecureStore.clampStatInt(enemiesKilled + session.enemiesKilled),
        powerUpsCollected:
            SecureStore.clampStatInt(powerUpsCollected + session.powerUpsCollected),
        distanceTraveled:
            SecureStore.clampPlayTime(distanceTraveled + session.distanceTraveled),
        totalCoinsCollected:
            SecureStore.clampStatInt(totalCoinsCollected + session.totalCoinsCollected),
        levelsCompleted: SecureStore.clampStatInt(levelsCompleted + session.levelsCompleted),
      );
}

class SaveData {
  final int currentLevel;
  final int score;
  final int lives;
  final int coinsCollected;
  final double checkpointX;
  final double checkpointY;
  final bool hasCheckpoint;
  final Difficulty difficulty;
  final GameStats stats;
  /// Monotonic generation — blocks rollback to older sealed saves.
  final int generation;

  const SaveData({
    this.currentLevel = 1,
    this.score = 0,
    this.lives = 3,
    this.coinsCollected = 0,
    this.checkpointX = 100,
    this.checkpointY = 100,
    this.hasCheckpoint = false,
    this.difficulty = Difficulty.normal,
    required this.stats,
    this.generation = 0,
  });

  Map<String, dynamic> toJson() => {
        'currentLevel': currentLevel,
        'score': score,
        'lives': lives,
        'coinsCollected': coinsCollected,
        'checkpointX': checkpointX,
        'checkpointY': checkpointY,
        'hasCheckpoint': hasCheckpoint,
        'difficulty': difficulty.index,
        'stats': stats.toJson(),
        'generation': generation,
      };

  factory SaveData.fromJson(Map<String, dynamic> j) {
    final diffIdx = (j['difficulty'] as num?)?.round() ?? 1;
    return SaveData(
      currentLevel: SecureStore.clampLevel(j['currentLevel'] as num?),
      score: SecureStore.clampScore(j['score'] as num?),
      lives: SecureStore.clampLives(j['lives'] as num?),
      coinsCollected: SecureStore.clampCoins(j['coinsCollected'] as num?),
      checkpointX: SecureStore.clampCoord(j['checkpointX'] as num?),
      checkpointY: SecureStore.clampCoord(j['checkpointY'] as num?),
      hasCheckpoint: j['hasCheckpoint'] as bool? ?? false,
      difficulty: Difficulty.values[diffIdx.clamp(0, Difficulty.values.length - 1)],
      stats: GameStats.fromJson(
        Map<String, dynamic>.from(j['stats'] as Map? ?? {}),
      ),
      generation: (j['generation'] as num?)?.round().clamp(0, 1 << 30) ?? 0,
    );
  }
}
