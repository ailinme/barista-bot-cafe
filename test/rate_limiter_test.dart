import 'package:barista_bot_cafe/core/security/rate_limiter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RateLimiter locks after max attempts within window', () async {
    final rl = RateLimiter(maxAttempts: 3, window: const Duration(seconds: 2), lockout: const Duration(milliseconds: 500));
    expect(rl.isLocked, isFalse);
    rl.registerAttempt(success: false);
    rl.registerAttempt(success: false);
    expect(rl.isLocked, isFalse);
    rl.registerAttempt(success: false);
    expect(rl.isLocked, isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(rl.isLocked, isFalse);
  });
}

