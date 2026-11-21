import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipeleap/data/models.dart';
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

  test('sanitizeName strips injection / control chars', () {
    final cleaned = SecureStore.sanitizeName("Bob<script>alert(1)</script>");
    expect(cleaned.contains('<'), isFalse);
    expect(cleaned.contains('>'), isFalse);
    expect(cleaned.length, lessThanOrEqualTo(SecureStore.maxNameLen));
    expect(SecureStore.sanitizeName('A' * 50).length, SecureStore.maxNameLen);
    expect(SecureStore.sanitizeName('   '), 'Player');
    expect(SecureStore.sanitizeName("OK_Name-1"), 'OK_Name-1');
  });

  test('seal/open roundtrip with device key', () async {
    final sealed = await SecureStore.seal({'score': 100, 'name': 'Pip'});
    final opened = await SecureStore.open(sealed);
    expect(opened?['score'], 100);
  });

  test('ATTACK: payload edit with stale sig is rejected', () async {
    final sealed = await SecureStore.seal({'score': 100, 'name': 'Pip'});
    final tampered = Map<String, dynamic>.from(sealed);
    tampered['payload'] = {'score': 999999, 'name': 'Hax'};
    expect(await SecureStore.open(tampered), isNull);
  });

  test('ATTACK: unsealed cleartext save is rejected (former critical)', () async {
    final legacy = {
      'currentLevel': 10,
      'score': 999999,
      'lives': 99,
      'coinsCollected': 99,
      'checkpointX': 100,
      'checkpointY': 100,
      'hasCheckpoint': false,
      'difficulty': 2,
      'stats': <String, dynamic>{},
    };
    expect(await SecureStore.open(legacy), isNull);

    SharedPreferences.setMockInitialValues({
      'pipeleap_save': jsonEncode(legacy),
    });
    SecureStore.debugResetKeyCache();
    SecureStore.debugSetDeviceKey(
      Uint8List.fromList(List.generate(32, (i) => i + 1)),
    );
    expect(await SaveService().load(), isNull);
  });

  test('ATTACK: raw high-score JSON array is rejected', () async {
    final rawList = [
      {'name': 'HAXOR', 'score': 999999, 'level': 10, 'difficulty': 2},
    ];
    expect(await SecureStore.open(rawList), isNull);

    SharedPreferences.setMockInitialValues({
      'pipeleap_high_scores': jsonEncode(rawList),
    });
    SecureStore.debugResetKeyCache();
    SecureStore.debugSetDeviceKey(
      Uint8List.fromList(List.generate(32, (i) => i + 1)),
    );
    expect(await HighScoreService().load(), isEmpty);
  });

  test('ATTACK: static pepper / foreign key forge is rejected', () async {
    final payload = {
      'currentLevel': 10,
      'score': 999999,
      'lives': 5,
      'coinsCollected': 0,
      'checkpointX': 100.0,
      'checkpointY': 100.0,
      'hasCheckpoint': false,
      'difficulty': 2,
      'stats': GameStats().toJson(),
    };
    // Old v1 pepper from previous source (must no longer work).
    const oldPepper = 'PipeLeap.v1.integrity.2026!#';
    final body = SecureStore.canonicalJson(payload);
    final sig = Hmac(sha256, utf8.encode(oldPepper))
        .convert(utf8.encode(body))
        .toString();
    final forged = {'v': 1, 'payload': payload, 'sig': sig};
    expect(await SecureStore.open(forged), isNull);

    // Wrong device key.
    final otherKey = Uint8List.fromList(List.generate(32, (i) => 255 - i));
    final foreignSig =
        Hmac(sha256, otherKey).convert(utf8.encode(body)).toString();
    expect(
      await SecureStore.open({'v': 2, 'payload': payload, 'sig': foreignSig}),
      isNull,
    );
  });

  test('ATTACK: mario_save cleartext ignored and wiped', () async {
    SharedPreferences.setMockInitialValues({
      'mario_save': jsonEncode({
        'currentLevel': 10,
        'score': 999999,
        'lives': 99,
        'stats': <String, dynamic>{},
      }),
    });
    SecureStore.debugResetKeyCache();
    SecureStore.debugSetDeviceKey(
      Uint8List.fromList(List.generate(32, (i) => i + 1)),
    );
    final svc = SaveService();
    expect(await svc.load(), isNull);
    expect(await svc.hasSave(), isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('mario_save'), isFalse);
  });

  test('legitimate save roundtrip survives', () async {
    final data = SaveData(
      currentLevel: 3,
      score: 1200,
      lives: 4,
      difficulty: Difficulty.hard,
      stats: GameStats(
        enemiesKilled: 5,
        totalPlayTime: 60,
        totalCoinsCollected: 10,
        levelsCompleted: 2,
      ),
    );
    final svc = SaveService();
    await svc.save(data);
    final back = await svc.load();
    expect(back?.currentLevel, 3);
    expect(back?.score, 1200);
    expect(back?.lives, 4);
    expect(back?.generation, greaterThan(0));
  });

  test('ATTACK: rollback to older sealed generation is rejected', () async {
    final svc = SaveService();
    await svc.save(SaveData(
      currentLevel: 1,
      score: 10,
      lives: 3,
      stats: GameStats(totalPlayTime: 20, enemiesKilled: 1, totalCoinsCollected: 2),
    ));
    final first = await svc.load();
    expect(first, isNotNull);
    final sealedOlder = await SecureStore.seal(first!.toJson());

    await svc.save(SaveData(
      currentLevel: 5,
      score: 5000,
      lives: 3,
      stats: GameStats(totalPlayTime: 200, enemiesKilled: 20, totalCoinsCollected: 30),
    ));
    expect((await svc.load())?.currentLevel, 5);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pipeleap_save', jsonEncode(sealedOlder));
    expect(await svc.load(), isNull);
  });

  test('lives clamp rejects absurd save fields', () {
    final data = SaveData.fromJson({
      'currentLevel': 99,
      'score': 1e12,
      'lives': 99,
      'coinsCollected': 500,
      'stats': {'enemiesKilled': -5},
    });
    expect(data.currentLevel, 10);
    expect(data.score, SecureStore.maxScore);
    expect(data.lives, SecureStore.maxLives);
    expect(data.coinsCollected, 99);
    expect(data.stats.enemiesKilled, 0);
  });

  test('high score tryAdd rejects absurd god scores', () async {
    final hs = HighScoreService();
    expect(
      await hs.tryAdd(const HighScore(
        name: '<script>',
        score: 999999999,
        level: 99,
        difficulty: Difficulty.easy,
      )),
      isFalse,
    );
    expect(
      await hs.tryAdd(
        const HighScore(
          name: 'Pip',
          score: 5000,
          level: 3,
          difficulty: Difficulty.normal,
        ),
        sessionPlayTime: 120,
      ),
      isTrue,
    );
    final board = await hs.load();
    expect(board, isNotEmpty);
    expect(board.first.name.contains('<'), isFalse);
  });
}
