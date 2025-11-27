import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// Logger sencillo: envía eventos a Realtime Database con degradación silenciosa.
class AppLogger {
  AppLogger._();
  static DatabaseReference? _baseRef;

  static Future<void> init() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      _baseRef = FirebaseDatabase.instance.ref('logs/$uid');
      await _baseRef!.keepSynced(false);
    } catch (_) {
      _baseRef = null;
    }
  }

  static Future<void> logInfo(String message, {Map<String, dynamic>? data}) async {
    await _log('info', message, data: data);
  }

  static Future<void> logError(String message, Object error, StackTrace stackTrace, {Map<String, dynamic>? data}) async {
    await _log('error', message, data: {
      'error': error.toString(),
      'stack': stackTrace.toString(),
      ...?data,
    });
  }

  static Future<void> _log(String level, String message, {Map<String, dynamic>? data}) async {
    final ref = _baseRef;
    if (ref == null) return;
    try {
      await ref.push().set({
        'level': level,
        'message': message,
        'data': data,
        'ts': ServerValue.timestamp,
      });
    } catch (_) {
      // Degradar silenciosamente: no bloquear la app por fallas de log.
    }
  }
}
