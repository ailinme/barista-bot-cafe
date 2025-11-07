![CI](https://github.com/${{ github.repository }}/actions/workflows/flutter-ci.yml/badge.svg)

# barista_bot_cafe

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- Lab: Write your first Flutter app: https://docs.flutter.dev/get-started/codelab
- Cookbook: Useful Flutter samples: https://docs.flutter.dev/cookbook

For help getting started with Flutter development, view the
online documentation: https://docs.flutter.dev/, which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Integrantes
- Ailin Mejia Estrella - Scrum Master

## Seguridad (OWASP y protección de datos)
- Ver `docs/security.md` para el detalle de validaciones, manejo de secretos, cifrado en tránsito, y mapeo OWASP (M1, M2, M5, M8, M9).
- Dependencias usadas: `flutter_secure_storage`, `permission_handler`, `http`, `crypto`.

## Verificación de Cambios (Paso a Paso)
- Sigue `docs/paso_a_paso_verificacion.txt` para:
  - Ejecutar la app en Android/Windows.
  - Configurar TLS/pinning y validar permisos JIT.
  - Validar registro/login y rate limiting.
