import 'package:barista_bot_cafe/core/security/secret_store.dart';
import 'package:barista_bot_cafe/core/security/session_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SessionManager issues and rotates tokens', () async {
    final sm = SessionManager.instance;
    sm.setStore(InMemorySecureStore());

    await sm.issueNewTokens(ttl: const Duration(milliseconds: 100));
    final t1 = await sm.getAuthToken();
    expect(t1, isNotNull);
    expect(await sm.isAccessTokenExpired(), isFalse);

    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(await sm.isAccessTokenExpired(), isTrue);
    await sm.rotateTokensIfNeeded();
    final t2 = await sm.getAuthToken();
    expect(t2, isNotNull);
    expect(t2 == t1, isFalse);
  });
}

