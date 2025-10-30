import 'dart:math';
import 'secret_store.dart';

class SessionManager {
  SessionManager._internal();
  static final SessionManager instance = SessionManager._internal();

  SecureStore _store = InMemorySecureStore();

  void setStore(SecureStore store) {
    _store = store;
  }

  /// Emite nuevos tokens (access + refresh) con expiración en [ttl].
  Future<void> issueNewTokens({Duration ttl = const Duration(minutes: 15)}) async {
    final access = _randomToken();
    final refresh = _randomToken();
    final expiryMillis = DateTime.now().add(ttl).millisecondsSinceEpoch;
    await _store.write(key: SecureKeys.authToken, value: access);
    await _store.write(key: SecureKeys.refreshToken, value: refresh);
    await _store.write(key: SecureKeys.tokenExpiryMillis, value: expiryMillis.toString());
  }

  Future<String?> getAuthToken() async {
    return _store.read(key: SecureKeys.authToken);
  }

  Future<String?> getRefreshToken() async {
    return _store.read(key: SecureKeys.refreshToken);
  }

  Future<bool> isAccessTokenExpired() async {
    final millisStr = await _store.read(key: SecureKeys.tokenExpiryMillis);
    if (millisStr == null) return true;
    final millis = int.tryParse(millisStr) ?? 0;
    return DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(millis));
  }

  /// Simula rotación de tokens al expirar; en producción debe llamar al backend.
  Future<void> rotateTokensIfNeeded() async {
    final expired = await isAccessTokenExpired();
    if (!expired) return;
    // Simular rotación: generar nuevo par usando refresh token existente.
    final rt = await getRefreshToken();
    if (rt == null) {
      await clear();
      return;
    }
    await issueNewTokens();
  }

  Future<void> clear() async {
    await _store.delete(key: SecureKeys.authToken);
    await _store.delete(key: SecureKeys.refreshToken);
    await _store.delete(key: SecureKeys.tokenExpiryMillis);
  }

  String _randomToken() {
    const alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final r = Random.secure();
    return List.generate(32, (_) => alphabet[r.nextInt(alphabet.length)]).join();
  }

  /// Establece tokens desde backend con expiración conocida (epoch ms).
  Future<void> setTokens({required String accessToken, required String refreshToken, required int expiryMillis}) async {
    await _store.write(key: SecureKeys.authToken, value: accessToken);
    await _store.write(key: SecureKeys.refreshToken, value: refreshToken);
    await _store.write(key: SecureKeys.tokenExpiryMillis, value: expiryMillis.toString());
  }
}
