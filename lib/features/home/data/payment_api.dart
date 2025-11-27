import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PaymentPreference {
  final String preferenceId;
  final String initPoint;
  final String? sandboxInitPoint;
  final String checkoutUrl;
  final String? mode;

  const PaymentPreference({
    required this.preferenceId,
    required this.initPoint,
    required this.checkoutUrl,
    this.sandboxInitPoint,
    this.mode,
  });
}

class PaymentApi {
  PaymentApi._internal();
  static final PaymentApi instance = PaymentApi._internal();

  // Ajusta esta URL con el deployment de tu backend (Express/Firebase Functions).
  static final String baseUrl = _detectBaseUrl();

  static String _detectBaseUrl() {
    const envUrl = String.fromEnvironment('PAYMENTS_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8080';
    // Web/desktop simulador: usar host local
    return 'http://localhost:8080';
  }

  Future<PaymentPreference> createPreference({
    required List<Map<String, dynamic>> items,
    required String userId,
  }) async {
    final uri = Uri.parse('$baseUrl/payments/create_preference');
    try {
      final resp = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'items': items, 'userId': userId}))
          .timeout(const Duration(seconds: 12));
      if (resp.statusCode != 200) {
        throw Exception('Respuesta inválida del backend de pagos');
      }
      final data = jsonDecode(resp.body);
      if (data['status'] != 'ok') throw Exception(data['message'] ?? 'No se pudo crear la preferencia');
      final sandboxInitPoint = data['sandboxInitPoint'] as String? ?? data['sandbox_init_point'] as String?;
      final initPoint = data['initPoint'] as String? ?? data['init_point'] as String?;
      final mode = data['mode'] as String?;
      final checkoutUrlField = data['checkoutUrl'] as String?;
      final checkoutUrl = checkoutUrlField ??
          ((mode == 'production')
              ? (initPoint ?? sandboxInitPoint)
              : (sandboxInitPoint ?? initPoint));
      if (checkoutUrl == null || checkoutUrl.isEmpty) throw Exception('El backend no regreso URL de checkout');
      return PaymentPreference(
        preferenceId: data['preferenceId'] as String,
        initPoint: initPoint ?? '',
        sandboxInitPoint: sandboxInitPoint,
        checkoutUrl: checkoutUrl,
        mode: mode,
      );
    } catch (e) {
      throw Exception('Backend de pagos no disponible ($e)');
    }
  }
}
