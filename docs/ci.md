# CI para Flutter

Este proyecto está configurado con GitHub Actions para ejecutar un pipeline de Integración Continua (CI) al hacer `push` en `main` y `feature/**`, y en `pull_request` contra `main`.

Ubicación del workflow: `.github/workflows/flutter-ci.yml`.

Elementos automatizados del pipeline:
- Analyze & Tests (Linux):
  - Configura Java 17 y Flutter estable.
  - Ejecuta `flutter pub get`, `flutter analyze` y `flutter test --coverage`.
  - Publica `coverage/lcov.info` como artefacto.
- Build Android (APK):
  - Depende de que pase el job de análisis y pruebas.
  - Ejecuta `flutter build apk --debug` y sube `app-debug.apk` como artefacto.
- Build Web:
  - Depende de que pase el job de análisis y pruebas.
  - Ejecuta `flutter build web` y publica el directorio `build/web` como artefacto.

Ejecución del pipeline:
- Automática por eventos (`push`/`pull_request`).
- Manual: realizar un `push` a una rama `feature/**` o abrir un PR a `main`.

Cómo verificar localmente antes del CI:
- `flutter pub get`
- `flutter analyze` (asegura 0 issues)
- `flutter test --coverage` (genera `coverage/lcov.info`)

Resultados y artefactos:
- Cobertura: `coverage/lcov.info` se adjunta a la corrida del workflow.
- APK debug: `build/app/outputs/flutter-apk/app-debug.apk` como artefacto descargable.
- Web build: `build/web` empaquetado como artefacto.

Notas y recomendaciones:
- Si deseas publicar cobertura en un servicio externo (por ejemplo, Codecov), se puede añadir un job que suba `lcov.info`.
- Builds de iOS requieren runners con macOS y configuración de firmas; este pipeline actual no incluye iOS (evita bloqueos por falta de credenciales). Si se requiere, se puede agregar un job en macOS con `flutter build ipa` + `fastlane`/`xcodebuild`.
- El workflow fue creado con el contenido exacto solicitado. En GitHub Actions se recomienda normalmente usar referencias `@v4`/`@v2` (por ejemplo, `actions/checkout@v4`, `subosito/flutter-action@v2`). Si se aprueba, puedo ajustar a esas referencias estándar.
