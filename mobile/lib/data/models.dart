enum Difficulty { easy, normal, hard }

enum PlatformKind { static_, movingH, movingV, destructible }

enum EnemyKind { goomba, koopa, flying, boss }

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
  const EnemyDef(this.x, this.y, [this.kind = EnemyKind.goomba]);
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

  factory HighScore.fromJson(Map<String, dynamic> j) => HighScore(
        name: j['name'] as String? ?? 'Player',
        score: j['score'] as int? ?? 0,
        level: j['level'] as int? ?? 1,
        difficulty: Difficulty.values[(j['difficulty'] as int? ?? 1).clamp(0, 2)],
      );
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
        totalPlayTime: (j['totalPlayTime'] as num?)?.toDouble() ?? 0,
        enemiesKilled: j['enemiesKilled'] as int? ?? 0,
        powerUpsCollected: j['powerUpsCollected'] as int? ?? 0,
        distanceTraveled: (j['distanceTraveled'] as num?)?.toDouble() ?? 0,
        totalCoinsCollected: j['totalCoinsCollected'] as int? ?? 0,
        levelsCompleted: j['levelsCompleted'] as int? ?? 0,
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
      };

  factory SaveData.fromJson(Map<String, dynamic> j) => SaveData(
        currentLevel: j['currentLevel'] as int? ?? 1,
        score: j['score'] as int? ?? 0,
        lives: j['lives'] as int? ?? 3,
        coinsCollected: j['coinsCollected'] as int? ?? 0,
        checkpointX: (j['checkpointX'] as num?)?.toDouble() ?? 100,
        checkpointY: (j['checkpointY'] as num?)?.toDouble() ?? 100,
        hasCheckpoint: j['hasCheckpoint'] as bool? ?? false,
        difficulty: Difficulty.values[(j['difficulty'] as int? ?? 1).clamp(0, 2)],
        stats: GameStats.fromJson(Map<String, dynamic>.from(j['stats'] as Map? ?? {})),
      );
}
