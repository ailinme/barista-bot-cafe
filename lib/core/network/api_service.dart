import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barista_bot_cafe/core/network/secure_http_client.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({required this.baseUrl, required Set<String> certPinsBase64})
      : _client = SecureHttpClient(spkiPinsBase64: certPinsBase64).create();

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    final res = await _client.get(_u(path), headers: headers).timeout(const Duration(seconds: 15));
    _ensureHttps();
    return res;
  }

  Future<http.Response> post(String path, {Map<String, String>? headers, Object? body}) async {
    final h = {'Content-Type': 'application/json', ...?headers};
    final res = await _client.post(_u(path), headers: h, body: body is String ? body : jsonEncode(body)).timeout(const Duration(seconds: 15));
    _ensureHttps();
    return res;
  }

  void _ensureHttps() {
    if (!baseUrl.startsWith('https://')) {
      throw StateError('Solo HTTPS permitido');
    }
  }
}

