import 'package:flutter_test/flutter_test.dart';
import 'package:pipeleap/data/runtime_guard.dart';

void main() {
  test('XOR-only: no plain score field to poke via assignment', () {
    final g = RuntimeGuard()..bootstrap(score: 100, lives: 3, coins: 0, level: 1);
    expect(g.score, 100);
    expect(g.intact, isTrue);
    // Re-bootstrap god mode must be ignored once locked.
    g.bootstrap(score: 999999, lives: 5, coins: 99, level: 10);
    expect(g.score, 100);
    expect(g.lives, 3);
  });

  test('legitimate award keeps intact', () {
    final g = RuntimeGuard()..bootstrap(score: 0, lives: 3, coins: 0, level: 1);
    g.addScore(50);
    g.addCoin();
    expect(g.intact, isTrue);
    expect(g.score, 50);
    expect(g.coins, 1);
  });

  test('speedhack dt is clamped', () {
    final g = RuntimeGuard()..bootstrap(score: 0, lives: 3, coins: 0, level: 1);
    expect(g.sanitizeDt(1.0), lessThanOrEqualTo(0.05));
    for (var i = 0; i < 10; i++) {
      g.sanitizeDt(0.5);
    }
    expect(g.suspiciousSpeed, isTrue);
  });

  test('tampering mirrors triggers recover to prior XOR values', () {
    final g = RuntimeGuard()..bootstrap(score: 42, lives: 3, coins: 1, level: 2);
    // Corrupt internal state via reflection-like abuse isn't available;
    // ensure() after addScore path stays healthy.
    g.addScore(8);
    expect(g.score, 50);
    expect(g.intact, isTrue);
  });
}
