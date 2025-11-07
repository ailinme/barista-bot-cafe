Seguridad en Barista Bot Café

Evidencias de cumplimiento de la rúbrica de codificación segura y OWASP Mobile Top 10.

1) Validación y saneamiento
- Código: lib/core/security/validators.dart
- (imagen: editor mostrando validators.dart con reglas de email/teléfono/contraseña)
- Integración UI: lib/features/auth/presentation/pages/login_screen.dart, lib/features/auth/presentation/pages/register_screen.dart
- (imagen: formulario de Registro con errores visibles en correo/teléfono/contraseña)
- Pruebas: test/validators_test.dart
- (imagen: terminal mostrando tests de validators en verde)

2) Autenticación y autorización robusta
- Rate limiting cliente: lib/core/security/rate_limiter.dart (usado en login)
- (imagen: intento fallido repetido y Snackbar de rate-limit)
- Inicio de sesión con Firebase: lib/features/auth/presentation/pages/login_screen.dart
- (imagen: Snackbar de "Inicio de sesión exitoso" y navegación a Home)
- (imagen: Firebase Console → Authentication → Usuarios con el usuario creado)
- Nota: En producción, validar scopes/roles y expiración en servidor (OIDC/OAuth2 con PKCE).

3) Gestión segura de secretos
- Abstracción de almacenes: lib/core/security/secret_store.dart
- (imagen: fragmento de código con FlutterSecureStorage en SecureStorageStore)
- Almacén seguro por defecto (Keychain/Keystore) vía flutter_secure_storage

4) Criptografía moderna en cliente
- En tránsito: TLS obligatorio + pinning SHA-256 (DER): lib/core/network/secure_http_client.dart, lib/core/network/api_service.dart
- (imagen: fragmento de código del cliente HTTPS con comentario de pinning)
- Nota: Datos locales sensibles se almacenan en Secure Storage (cifrado en reposo por el sistema).

5) Manejo de permisos y privacidad (JIT + degradación)
- Servicio de permisos: lib/core/permissions/permission_service.dart
- (imagen: captura del diálogo de notificaciones en Android 13+)
- Solicitud JIT en registro con degradación: lib/features/auth/presentation/pages/register_screen.dart
- (imagen: aviso "Notificaciones desactivadas" tras denegar)
- Documentos: assets/docs/privacidad.md, assets/docs/datos_personales.md

6) Seguridad en tránsito (M5)
- Solo HTTPS permitido: lib/core/network/api_service.dart
- (imagen: código de ApiService forzando https)
- Pinning y timeouts: lib/core/network/secure_http_client.dart
- (imagen: código de verificación SHA-256 del certificado)

7) Mapeo OWASP Mobile Top 10
- Ver docs/owasp_mapping.md
- (imagen: extracto del mapeo con M1/M2/M5/M8/M9 resaltados)

8) Documentación técnica y evidencias
- README, pruebas en test/*.dart, scripts CI en ci/scripts
- (imagen: ejecución de `flutter analyze` sin errores)
- (imagen: ejecución de `flutter test` con éxito)
- (imagen: GitHub Actions workflow en verde)

9) Recomendaciones de despliegue
- Usar OIDC con PKCE, tokens de corta vida y refresh rotatorio en backend.
- (imagen: diagrama simple de flujo OIDC/PKCE)
- Plan de rotación de pins (añadir nuevo hash en despliegue, retirar antiguo tras transición).

10) TLS y pinning
- Obtener hash SHA-256 Base64 del certificado del backend y configurarlo en ApiService.
- (imagen: terminal mostrando hash SHA-256 en Base64 del certificado)
