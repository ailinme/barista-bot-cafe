import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// Telemetría ligera: guarda eventos en Realtime DB (degrada silenciosamente si falla).
class Telemetry {
  Telemetry._();
  static DatabaseReference? _ref;

  static Future<void> init() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      _ref = FirebaseDatabase.instance.ref('events/$uid');
    } catch (_) {
      _ref = null;
    }
  }

  static Future<void> track(String name, {Map<String, dynamic>? data}) async {
    final ref = _ref;
    if (ref == null) return;
    try {
      await ref.push().set({
        'name': name,
        'data': data,
        'ts': ServerValue.timestamp,
      });
    } catch (_) {
      // No interrumpir UX si falla.
    }
  }
}
