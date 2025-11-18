// Almacenamiento seguro para móvil (Keychain/Keystore) y memoria para pruebas.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstracción simple para almacenar pares clave-valor.
/// Implementaciones: `SecureStorageStore` (plataformas móviles/escritorio) y `InMemorySecureStore` (tests).
abstract class SecureStore {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
}

class InMemorySecureStore implements SecureStore {
  final Map<String, String> _mem = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _mem[key] = value;
  }

  @override
  Future<String?> read({required String key}) async => _mem[key];

  @override
  Future<void> delete({required String key}) async {
    _mem.remove(key);
  }
}

class SecureKeys {
  static const authToken = 'auth_token';
  static const refreshToken = 'refresh_token';
  static const tokenExpiryMillis = 'token_expiry_millis';
}

/// Implementación móvil/escritorio usando FlutterSecureStorage.
class SecureStorageStore implements SecureStore {
  final FlutterSecureStorage _storage;
  const SecureStorageStore({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage.read(key: key);
  }

  @override
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }
}

