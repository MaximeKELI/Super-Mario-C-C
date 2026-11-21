import 'package:flutter_test/flutter_test.dart';
import 'package:pipeleap/data/runtime_guard.dart';

void main() {
  test('XOR mirror detects score memory edit', () {
    final g = RuntimeGuard()..bootstrap(score: 100, lives: 3, coins: 0, level: 1);
    expect(g.intact, isTrue);
    g.score = 999999; // simulate GameGuardian poke without mirrors
    expect(g.intact, isFalse);
    g.recover();
    expect(g.score, 100);
    expect(g.intact, isTrue);
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
}
