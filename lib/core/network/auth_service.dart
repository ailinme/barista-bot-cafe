import 'package:barista_bot_cafe/core/network/api_service.dart';

class AuthService {
  // Configura tu URL de backend HTTPS
  static const String baseUrl = 'https://api.tu-backend.com';
  // Reemplaza con el hash SHA-256 Base64 del certificado del backend
  static const Set<String> derCertPinsBase64 = {
    // 'base64Sha256DerAqui'
  };

  static final ApiService _api = ApiService(baseUrl: baseUrl, certPinsBase64: derCertPinsBase64);

  static ApiService get client => _api;
}

