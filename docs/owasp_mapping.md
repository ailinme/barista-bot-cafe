# OWASP Mobile Top 10 Mapping

- M1 Improper Platform Usage
  - Control: Centralizar permisos JIT y evitar APIs inseguras
  - Evidencia: `lib/core/permissions/permission_service.dart`, `lib/features/auth/presentation/pages/register_screen.dart`
  - (imagen: diálogo de permisos JIT en registro)

- M2 Insecure Data Storage
  - Control: Almacenar secretos solo en Keychain/Keystore (`flutter_secure_storage`)
  - Evidencia: `lib/core/security/secret_store.dart`
  - (imagen: fragmento de código usando FlutterSecureStorage)

- M5 Insufficient Cryptography
  - Control: TLS obligatorio y pinning de certificado
  - Evidencia: `lib/core/network/secure_http_client.dart`, `lib/core/network/api_service.dart`
  - (imagen: código del cliente HTTPS con pinning)

- M8 Code Tampering
  - Control: Recomendación de firmas, integrity checks, build ofuscado
  - Evidencia: `docs/security.md` (sección despliegue)
  - (imagen: captura de documentación con las recomendaciones)

- M9 Reverse Engineering
  - Control: Build con `--obfuscate` y `--split-debug-info`; no incluir secretos en binarios
  - Evidencia: `docs/security.md` (sección despliegue)
  - (imagen: comando de build con --obfuscate en terminal)
