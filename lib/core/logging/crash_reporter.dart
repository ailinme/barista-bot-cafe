import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'package:barista_bot_cafe/core/logging/app_logger.dart';

/// Adaptador simple para reportar errores controlados y pasarlos a Crashlytics (si disponible).
class CrashReporter {
  CrashReporter._();

  static Future<void> recordError(
    dynamic error,
    StackTrace stack, {
    String reason = 'Error controlado',
  }) async {
    // Registrar en Realtime (no bloqueante).
    unawaited(AppLogger.logError(reason, error, stack));

    // Crashlytics solo en plataformas soportadas (no web).
    if (kIsWeb) return;
    try {
      await FirebaseCrashlytics.instance.recordError(error, stack, reason: reason, fatal: false);
    } catch (_) {
      // Ignorar para no afectar la UX.
    }
  }
}
