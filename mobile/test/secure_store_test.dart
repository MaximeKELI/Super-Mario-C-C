import 'package:flutter_test/flutter_test.dart';
import 'package:pipeleap/data/secure_store.dart';

void main() {
  test('sanitizeName strips injection / control chars', () {
    final cleaned = SecureStore.sanitizeName("Bob<script>alert(1)</script>");
    expect(cleaned.contains('<'), isFalse);
    expect(cleaned.contains('>'), isFalse);
    expect(cleaned.length, lessThanOrEqualTo(SecureStore.maxNameLen));
    expect(SecureStore.sanitizeName('A' * 50).length, SecureStore.maxNameLen);
    expect(SecureStore.sanitizeName('   '), 'Player');
    expect(SecureStore.sanitizeName("OK_Name-1"), 'OK_Name-1');
  });

  test('seal/open roundtrip and reject tampering', () {
    final sealed = SecureStore.seal({'score': 100, 'name': 'Pip'});
    final opened = SecureStore.open(sealed);
    expect(opened?['score'], 100);

    final tampered = Map<String, dynamic>.from(sealed);
    tampered['payload'] = {'score': 999999, 'name': 'Hax'};
    expect(SecureStore.open(tampered), isNull);

    final badSig = Map<String, dynamic>.from(sealed);
    badSig['sig'] = '0' * 64;
    expect(SecureStore.open(badSig), isNull);
  });

  test('legacy unsealed map still opens', () {
    final legacy = {'currentLevel': 2, 'score': 50};
    expect(SecureStore.open(legacy)?['currentLevel'], 2);
  });

  test('clamps reject absurd values', () {
    expect(SecureStore.clampScore(1e12), SecureStore.maxScore);
    expect(SecureStore.clampLevel(-3), 1);
    expect(SecureStore.clampLives(500), SecureStore.maxLives);
  });
}
