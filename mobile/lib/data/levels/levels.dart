import '../models.dart';

/// Port of C++ LoadLevel1..10 from Game.cpp
class Levels {
  static LevelData get(int n) {
    switch (n.clamp(1, 10)) {
      case 1:
        return level1;
      case 2:
        return level2;
      case 3:
        return level3;
      case 4:
        return level4;
      case 5:
        return level5;
      case 6:
        return level6;
      case 7:
        return level7;
      case 8:
        return level8;
      case 9:
        return level9;
      case 10:
        return level10;
      default:
        return level1;
    }
  }

  static const level1 = LevelData(
    number: 1,
    name: 'Introduction',
    endX: 1700,
    platforms: [
      PlatformDef(0, 550, 200, 50),
      PlatformDef(200, 500, 150, 50),
      PlatformDef(400, 450, 150, 50),
      PlatformDef(600, 400, 150, 50),
      PlatformDef(800, 350, 150, 50),
      PlatformDef(1000, 300, 150, 50),
      PlatformDef(1200, 250, 150, 50),
      PlatformDef(1400, 200, 200, 50),
      PlatformDef(1600, 550, 200, 50),
    ],
    blocks: [
      BlockDef(250, 450, BlockKind.question),
      BlockDef(450, 400, BlockKind.question),
      BlockDef(850, 300, BlockKind.question),
    ],
    coins: [CoinDef(300, 400), CoinDef(500, 350), CoinDef(900, 250)],
    enemies: [
      EnemyDef(300, 470),
      EnemyDef(500, 420),
      EnemyDef(700, 370),
    ],
    checkpoints: [CheckpointDef(800, 300)],
    clouds: [CloudDef(200, 50, 80, 40), CloudDef(800, 60, 90, 45)],
  );

  static const level2 = LevelData(
    number: 2,
    name: 'Koopa Arrives',
    endX: 2100,
    platforms: [
      PlatformDef(0, 550, 150, 50),
      PlatformDef(200, 480, 120, 50),
      PlatformDef(380, 520, 100, 50),
      PlatformDef(530, 450, 120, 50),
      PlatformDef(700, 500, 100, 50),
      PlatformDef(850, 400, 150, 50),
      PlatformDef(1050, 350, 120, 50),
      PlatformDef(1220, 450, 100, 50),
      PlatformDef(1370, 300, 150, 50),
      PlatformDef(1550, 400, 150, 50),
      PlatformDef(1730, 250, 120, 50),
      PlatformDef(1900, 550, 300, 50),
    ],
    blocks: [
      BlockDef(230, 430, BlockKind.question),
      BlockDef(560, 400, BlockKind.brick),
      BlockDef(890, 350, BlockKind.question),
      BlockDef(1090, 300, BlockKind.brick),
      BlockDef(1410, 250, BlockKind.question),
    ],
    coins: [
      CoinDef(250, 430),
      CoinDef(570, 400),
      CoinDef(600, 350),
      CoinDef(1100, 300),
    ],
    enemies: [
      EnemyDef(350, 430, EnemyKind.koopa),
      EnemyDef(550, 400),
      EnemyDef(750, 450, EnemyKind.koopa),
      EnemyDef(1080, 300),
      EnemyDef(1600, 350, EnemyKind.koopa),
    ],
    checkpoints: [CheckpointDef(1000, 300)],
    spikes: [SpikeDef(380, 530, 100, 20)],
    clouds: [CloudDef(300, 50, 80, 40), CloudDef(900, 70, 90, 45)],
  );

  static const level3 = LevelData(
    number: 3,
    name: 'Moving Platforms',
    endX: 2300,
    platforms: [
      PlatformDef(0, 550, 150, 50),
      PlatformDef(200, 480, 120, 50),
      PlatformDef(380, 520, 100, 50, PlatformKind.movingH),
      PlatformDef(530, 450, 120, 50),
      PlatformDef(700, 400, 100, 50, PlatformKind.movingV),
      PlatformDef(850, 450, 150, 50),
      PlatformDef(1050, 350, 120, 50),
      PlatformDef(1220, 400, 100, 50, PlatformKind.movingH),
      PlatformDef(1370, 300, 150, 50),
      PlatformDef(1550, 250, 120, 50),
      PlatformDef(1730, 350, 100, 50, PlatformKind.movingV),
      PlatformDef(1900, 300, 150, 50),
      PlatformDef(2100, 550, 300, 50),
    ],
    blocks: [
      BlockDef(560, 400, BlockKind.question),
      BlockDef(890, 400, BlockKind.brick),
      BlockDef(1410, 250, BlockKind.question),
    ],
    coins: [
      CoinDef(600, 400),
      CoinDef(680, 350),
      CoinDef(900, 400),
      CoinDef(1100, 300),
    ],
    enemies: [
      EnemyDef(350, 430),
      EnemyDef(750, 350, EnemyKind.flying),
      EnemyDef(1080, 300),
      EnemyDef(1600, 200, EnemyKind.flying),
    ],
    checkpoints: [CheckpointDef(1200, 350)],
    powerUps: [PowerUpDef(600, 400, PowerUpKind.mushroom)],
    clouds: [CloudDef(400, 50, 80, 40), CloudDef(1200, 60, 90, 45)],
  );

  static const level4 = LevelData(
    number: 4,
    name: 'Rising Challenge',
    endX: 2200,
    platforms: [
      PlatformDef(0, 550, 150, 50),
      PlatformDef(200, 500, 100, 50),
      PlatformDef(350, 450, 120, 50),
      PlatformDef(520, 520, 80, 50),
      PlatformDef(650, 400, 100, 50),
      PlatformDef(800, 480, 120, 50),
      PlatformDef(970, 350, 100, 50),
      PlatformDef(1120, 450, 120, 50),
      PlatformDef(1290, 300, 100, 50),
      PlatformDef(1440, 400, 120, 50),
      PlatformDef(1610, 250, 150, 50),
      PlatformDef(1810, 350, 100, 50),
      PlatformDef(1960, 550, 300, 50),
    ],
    blocks: [
      BlockDef(370, 400, BlockKind.question),
      BlockDef(660, 350, BlockKind.brick),
      BlockDef(990, 300, BlockKind.question),
      BlockDef(1140, 400, BlockKind.hard),
      BlockDef(1310, 250, BlockKind.question),
    ],
    coins: [
      CoinDef(380, 400),
      CoinDef(670, 350),
      CoinDef(690, 300),
      CoinDef(1000, 300),
      CoinDef(1320, 250),
    ],
    enemies: [
      EnemyDef(360, 400, EnemyKind.koopa),
      EnemyDef(520, 470),
      EnemyDef(760, 430, EnemyKind.koopa),
      EnemyDef(1000, 300, EnemyKind.flying),
      EnemyDef(1450, 350),
      EnemyDef(1650, 200, EnemyKind.koopa),
    ],
    checkpoints: [CheckpointDef(1100, 400)],
    spikes: [SpikeDef(520, 530, 80, 20), SpikeDef(1120, 460, 80, 20)],
    clouds: [CloudDef(500, 50, 80, 40), CloudDef(1300, 70, 90, 45)],
  );

  static const level5 = LevelData(
    number: 5,
    name: 'Mid Boss',
    endX: 2300,
    platforms: [
      PlatformDef(0, 550, 150, 50),
      PlatformDef(200, 480, 120, 50),
      PlatformDef(380, 420, 100, 50),
      PlatformDef(530, 480, 120, 50),
      PlatformDef(700, 380, 150, 50),
      PlatformDef(900, 450, 120, 50),
      PlatformDef(1070, 320, 150, 50),
      PlatformDef(1270, 400, 120, 50),
      PlatformDef(1440, 280, 150, 50),
      PlatformDef(1640, 380, 150, 50),
      PlatformDef(1840, 240, 200, 50),
      PlatformDef(2100, 550, 300, 50),
    ],
    blocks: [
      BlockDef(410, 370, BlockKind.question),
      BlockDef(730, 330, BlockKind.brick),
      BlockDef(1100, 270, BlockKind.question),
      BlockDef(1480, 230, BlockKind.hard),
    ],
    coins: [
      CoinDef(420, 370),
      CoinDef(740, 330),
      CoinDef(760, 280),
      CoinDef(1110, 270),
    ],
    enemies: [
      EnemyDef(400, 370),
      EnemyDef(550, 430, EnemyKind.koopa),
      EnemyDef(760, 330, EnemyKind.flying),
      EnemyDef(1080, 270),
      EnemyDef(1280, 350, EnemyKind.koopa),
      EnemyDef(1920, 190, EnemyKind.boss),
    ],
    checkpoints: [CheckpointDef(1400, 230)],
    powerUps: [PowerUpDef(750, 330, PowerUpKind.feather)],
    clouds: [CloudDef(600, 50, 80, 40), CloudDef(1500, 60, 90, 45)],
  );

  static const level6 = LevelData(
    number: 6,
    name: 'Pipe Warp',
    endX: 2450,
    platforms: [
      PlatformDef(0, 550, 150, 50),
      PlatformDef(200, 500, 120, 50),
      PlatformDef(380, 450, 100, 50),
      PlatformDef(530, 500, 120, 50),
      PlatformDef(700, 400, 150, 50),
      PlatformDef(900, 480, 120, 50),
      PlatformDef(1070, 350, 150, 50),
      PlatformDef(1270, 420, 120, 50),
      PlatformDef(1440, 300, 150, 50),
      PlatformDef(1640, 380, 150, 50),
      PlatformDef(1840, 260, 150, 50),
      PlatformDef(2040, 340, 150, 50),
      PlatformDef(2240, 550, 300, 50),
    ],
    blocks: [
      BlockDef(410, 400, BlockKind.question),
      BlockDef(730, 350, BlockKind.brick),
      BlockDef(1100, 300, BlockKind.question),
      BlockDef(1480, 250, BlockKind.question),
    ],
    coins: [
      CoinDef(420, 400),
      CoinDef(600, 350),
      CoinDef(740, 350),
      CoinDef(1110, 300),
    ],
    enemies: [
      EnemyDef(400, 400),
      EnemyDef(560, 450, EnemyKind.koopa),
      EnemyDef(760, 350, EnemyKind.flying),
      EnemyDef(1080, 300),
      EnemyDef(1280, 370, EnemyKind.koopa),
    ],
    pipes: [
      PipeDef(750, 350, 40, 100, 1500, 250),
      PipeDef(1600, 330, 40, 100, 1900, 210),
    ],
    checkpoints: [CheckpointDef(1400, 250)],
    clouds: [CloudDef(700, 50, 80, 40), CloudDef(1700, 60, 90, 45)],
  );

  static const level7 = LevelData(
    number: 7,
    name: 'Crumbling Ground',
    endX: 2450,
    platforms: [
      PlatformDef(0, 550, 150, 50),
      PlatformDef(200, 480, 120, 50),
      PlatformDef(380, 420, 100, 50, PlatformKind.destructible),
      PlatformDef(530, 480, 120, 50),
      PlatformDef(700, 380, 150, 50, PlatformKind.destructible),
      PlatformDef(900, 450, 120, 50),
      PlatformDef(1070, 320, 150, 50),
      PlatformDef(1270, 400, 120, 50, PlatformKind.destructible),
      PlatformDef(1440, 280, 150, 50),
      PlatformDef(1640, 360, 150, 50),
      PlatformDef(1840, 240, 150, 50),
      PlatformDef(2040, 320, 150, 50),
      PlatformDef(2240, 550, 300, 50),
    ],
    blocks: [
      BlockDef(410, 370, BlockKind.question),
      BlockDef(730, 330, BlockKind.brick),
      BlockDef(1100, 270, BlockKind.question),
      BlockDef(1480, 230, BlockKind.hard),
    ],
    coins: [
      CoinDef(420, 370),
      CoinDef(740, 330),
      CoinDef(1110, 270),
      CoinDef(1490, 230),
    ],
    enemies: [
      EnemyDef(400, 370),
      EnemyDef(560, 430, EnemyKind.koopa),
      EnemyDef(1080, 270, EnemyKind.flying),
      EnemyDef(1280, 350),
      EnemyDef(1680, 310, EnemyKind.koopa),
    ],
    checkpoints: [CheckpointDef(1400, 230)],
    spikes: [SpikeDef(530, 490, 120, 20), SpikeDef(1270, 410, 120, 20)],
    clouds: [CloudDef(800, 50, 80, 40), CloudDef(1800, 60, 90, 45)],
  );

  static const level8 = LevelData(
    number: 8,
    name: 'Hard Mix',
    endX: 2450,
    platforms: [
      PlatformDef(0, 550, 150, 50),
      PlatformDef(200, 500, 100, 50),
      PlatformDef(350, 450, 120, 50, PlatformKind.movingH),
      PlatformDef(520, 520, 80, 50),
      PlatformDef(650, 400, 100, 50, PlatformKind.movingV),
      PlatformDef(800, 480, 120, 50),
      PlatformDef(970, 350, 100, 50, PlatformKind.destructible),
      PlatformDef(1120, 450, 120, 50),
      PlatformDef(1290, 300, 100, 50, PlatformKind.movingH),
      PlatformDef(1440, 400, 120, 50),
      PlatformDef(1610, 250, 150, 50),
      PlatformDef(1810, 350, 100, 50),
      PlatformDef(2010, 280, 150, 50),
      PlatformDef(2210, 550, 300, 50),
    ],
    blocks: [
      BlockDef(370, 400, BlockKind.question),
      BlockDef(660, 350, BlockKind.brick),
      BlockDef(990, 300, BlockKind.question),
      BlockDef(1310, 250, BlockKind.hard),
    ],
    coins: [
      CoinDef(380, 400),
      CoinDef(670, 350),
      CoinDef(1000, 300),
      CoinDef(1320, 250),
    ],
    enemies: [
      EnemyDef(360, 400, EnemyKind.koopa),
      EnemyDef(560, 450),
      EnemyDef(780, 430, EnemyKind.flying),
      EnemyDef(1000, 300, EnemyKind.koopa),
      EnemyDef(1160, 400),
      EnemyDef(1650, 200, EnemyKind.flying),
    ],
    checkpoints: [CheckpointDef(1300, 250)],
    spikes: [SpikeDef(520, 530, 80, 20), SpikeDef(1120, 460, 80, 20)],
    clouds: [CloudDef(900, 50, 80, 40), CloudDef(1900, 70, 90, 45)],
  );

  static const level9 = LevelData(
    number: 9,
    name: 'Almost There',
    endX: 2650,
    platforms: [
      PlatformDef(0, 550, 150, 50),
      PlatformDef(200, 480, 120, 50),
      PlatformDef(380, 420, 100, 50),
      PlatformDef(530, 480, 120, 50),
      PlatformDef(700, 380, 150, 50, PlatformKind.movingH),
      PlatformDef(900, 450, 120, 50),
      PlatformDef(1070, 320, 150, 50),
      PlatformDef(1270, 400, 120, 50, PlatformKind.destructible),
      PlatformDef(1440, 280, 150, 50),
      PlatformDef(1640, 360, 150, 50, PlatformKind.movingV),
      PlatformDef(1840, 240, 150, 50),
      PlatformDef(2040, 320, 150, 50),
      PlatformDef(2240, 200, 150, 50),
      PlatformDef(2440, 550, 300, 50),
    ],
    blocks: [
      BlockDef(410, 370, BlockKind.question),
      BlockDef(730, 330, BlockKind.brick),
      BlockDef(1100, 270, BlockKind.question),
      BlockDef(1480, 230, BlockKind.question),
      BlockDef(2280, 150, BlockKind.hard),
    ],
    coins: [
      CoinDef(420, 370),
      CoinDef(600, 330),
      CoinDef(740, 330),
      CoinDef(1110, 270),
      CoinDef(1490, 230),
    ],
    enemies: [
      EnemyDef(400, 370),
      EnemyDef(560, 430, EnemyKind.koopa),
      EnemyDef(780, 330, EnemyKind.flying),
      EnemyDef(1080, 270),
      EnemyDef(1280, 350, EnemyKind.koopa),
      EnemyDef(1680, 310, EnemyKind.flying),
      EnemyDef(2320, 150, EnemyKind.boss),
    ],
    checkpoints: [CheckpointDef(1400, 230), CheckpointDef(2200, 150)],
    spikes: [SpikeDef(530, 490, 120, 20), SpikeDef(1270, 410, 120, 20)],
    powerUps: [PowerUpDef(1120, 270, PowerUpKind.star)],
    clouds: [CloudDef(1000, 50, 80, 40), CloudDef(2000, 60, 90, 45)],
  );

  static const level10 = LevelData(
    number: 10,
    name: 'Final Boss',
    endX: 3900,
    platforms: [
      PlatformDef(0, 550, 150, 50),
      PlatformDef(200, 500, 120, 50),
      PlatformDef(380, 450, 100, 50),
      PlatformDef(530, 480, 120, 50),
      PlatformDef(700, 400, 150, 50, PlatformKind.movingH),
      PlatformDef(900, 450, 120, 50),
      PlatformDef(1070, 350, 150, 50),
      PlatformDef(1270, 400, 120, 50),
      PlatformDef(1440, 300, 150, 50, PlatformKind.movingV),
      PlatformDef(1640, 380, 150, 50),
      PlatformDef(1840, 260, 150, 50),
      PlatformDef(2040, 340, 150, 50),
      PlatformDef(2240, 220, 200, 50),
      PlatformDef(2490, 300, 150, 50),
      PlatformDef(2690, 380, 150, 50),
      PlatformDef(2890, 260, 250, 50),
      PlatformDef(3200, 550, 800, 50),
    ],
    blocks: [
      BlockDef(410, 400, BlockKind.question),
      BlockDef(730, 350, BlockKind.brick),
      BlockDef(1100, 300, BlockKind.question),
      BlockDef(1480, 250, BlockKind.question),
      BlockDef(2280, 170, BlockKind.hard),
    ],
    coins: [
      CoinDef(420, 400),
      CoinDef(600, 350),
      CoinDef(740, 350),
      CoinDef(1110, 300),
      CoinDef(1490, 250),
      CoinDef(2290, 170),
    ],
    enemies: [
      EnemyDef(400, 400),
      EnemyDef(560, 430, EnemyKind.koopa),
      EnemyDef(780, 350, EnemyKind.flying),
      EnemyDef(1080, 300),
      EnemyDef(1280, 350, EnemyKind.koopa),
      EnemyDef(1680, 330, EnemyKind.flying),
      EnemyDef(3040, 210, EnemyKind.boss),
    ],
    checkpoints: [CheckpointDef(1400, 250), CheckpointDef(2800, 210)],
    spikes: [
      SpikeDef(530, 490, 120, 20),
      SpikeDef(1270, 410, 120, 20),
      SpikeDef(2040, 350, 150, 20),
    ],
    powerUps: [PowerUpDef(1120, 300, PowerUpKind.star)],
    pipes: [PipeDef(1550, 330, 40, 100, 2300, 170)],
    clouds: [CloudDef(1100, 50, 80, 40), CloudDef(2500, 60, 90, 45)],
  );
}
