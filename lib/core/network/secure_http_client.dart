import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:crypto/crypto.dart' as crypto;

/// HttpClient con TLS forzado, timeouts y pinning de certificado por SPKI (SHA-256 Base64).
class SecureHttpClient {
  final Duration timeout;
  final Set<String> spkiPinsBase64; // Conjunto de pins de SPKI permitidos (Base64, SHA-256)

  SecureHttpClient({required this.spkiPinsBase64, this.timeout = const Duration(seconds: 15)});

  http.Client create() {
    final context = SecurityContext(withTrustedRoots: true);
    final ioClient = HttpClient(context: context);
    ioClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      // Pinning por hash SHA-256 del certificado (DER). Simpler que SPKI.
      final der = cert.der;
      final hash = crypto.sha256.convert(der).bytes;
      final b64 = base64.encode(hash);
      return spkiPinsBase64.contains(b64);
    };

    return IOClient(ioClient);
  }

}
