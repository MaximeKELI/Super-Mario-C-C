import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipeleap/data/anti_cheat.dart';
import 'package:pipeleap/data/models.dart';
import 'package:pipeleap/data/runtime_guard.dart';
import 'package:pipeleap/data/save_service.dart';
import 'package:pipeleap/data/secure_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SecureStore.debugResetKeyCache();
    SecureStore.debugSetDeviceKey(
      Uint8List.fromList(List.generate(32, (i) => i + 1)),
    );
  });

  group('BLOCKED', () {
    test('R1 cleartext save', () async {
      expect(await SecureStore.open({'score': 999999}), isNull);
    });

    test('R2 raw score list', () async {
      SharedPreferences.setMockInitialValues({
        'pipeleap_high_scores': jsonEncode([
          {'name': 'HAX', 'score': 999999, 'level': 10, 'difficulty': 2},
        ]),
      });
      SecureStore.debugResetKeyCache();
      SecureStore.debugSetDeviceKey(
        Uint8List.fromList(List.generate(32, (i) => i + 1)),
      );
      expect(await HighScoreService().load(), isEmpty);
    });

    test('R3 stale signature', () async {
      final sealed = await SecureStore.seal({'score': 1});
      sealed['payload'] = {'score': 999999};
      expect(await SecureStore.open(sealed), isNull);
    });

    test('R4 foreign key', () async {
      final payload = SaveData(stats: GameStats()).toJson();
      final body = utf8.encode(SecureStore.canonicalJson(payload));
      final foreign = Uint8List.fromList(List.generate(32, (i) => 200 - i));
      final sig = Hmac(sha256, foreign).convert(body).toString();
      expect(
        await SecureStore.open({'v': 3, 'payload': payload, 'sig': sig}),
        isNull,
      );
    });

    test('R5 rollback without keystore gen rewind', () async {
      final svc = SaveService();
      await svc.save(SaveData(
        currentLevel: 1,
        score: 100,
        lives: 3,
        stats: GameStats(totalPlayTime: 30, enemiesKilled: 2, totalCoinsCollected: 5),
      ));
      final v1 = await svc.load();
      final blob1 = await SecureStore.seal(v1!.toJson());
      await svc.save(SaveData(
        currentLevel: 8,
        score: 8000,
        lives: 3,
        stats: GameStats(totalPlayTime: 200, enemiesKilled: 20, totalCoinsCollected: 40),
      ));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pipeleap_save', jsonEncode(blob1));
      // Old attack: also rewind prefs gen — Keystore watermark still blocks.
      await prefs.setInt('pipeleap_save_gen', v1.generation);
      expect(await svc.load(), isNull);
    });

    test('R6 re-bootstrap god mode ignored', () {
      final g = RuntimeGuard()..bootstrap(score: 10, lives: 3, coins: 0, level: 1);
      g.bootstrap(score: 999999, lives: 5, coins: 99, level: 10);
      expect(g.score, 10);
    });

    test('R7 implausible god save rejected even if sealed', () async {
      final sealed = await SecureStore.seal({
        'currentLevel': 10,
        'score': 999999,
        'lives': 5,
        'coinsCollected': 0,
        'checkpointX': 100.0,
        'checkpointY': 100.0,
        'hasCheckpoint': false,
        'difficulty': 2,
        'stats': GameStats().toJson(), // no playtime / kills
        'generation': 1,
      });
      await SecureStore.writeGeneration(1);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pipeleap_save', jsonEncode(sealed));
      expect(await SaveService().load(), isNull);
    });

    test('R8 anti-cheat rejects max score too early', () {
      expect(
        AntiCheat.plausibleSave(SaveData(
          currentLevel: 2,
          score: 999999,
          lives: 5,
          stats: GameStats(totalPlayTime: 9999, enemiesKilled: 100),
        )),
        isFalse,
      );
    });
  });

  group('RESIDUAL (honest ceiling offline)', () {
    test('X1 stolen key + carefully plausible forged save still loads', () async {
      // Root+keystore dump can still craft a believable mid-run save.
      final payload = {
        'currentLevel': 4,
        'score': 12000,
        'lives': 3,
        'coinsCollected': 20,
        'checkpointX': 100.0,
        'checkpointY': 100.0,
        'hasCheckpoint': false,
        'difficulty': 1,
        'stats': GameStats(
          totalPlayTime: 180,
          enemiesKilled: 15,
          totalCoinsCollected: 40,
          levelsCompleted: 3,
        ).toJson(),
        'generation': 1,
      };
      await SecureStore.writeGeneration(1);
      final sealed = await SecureStore.seal(payload);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pipeleap_save', jsonEncode(sealed));
      final data = await SaveService().load();
      expect(data?.score, 12000,
          reason: 'Offline ceiling: key theft + plausible stats still wins');
    });
  });
}
