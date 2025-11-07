# Herramientas de CI/CD para Flutter (Móvil)

Este documento resume opciones comunes para automatizar Integración Continua (CI) y despliegues (CD) en proyectos Flutter móviles, destacando características aplicables a Android/Web y requisitos para iOS.

- GitHub Actions (adoptada en este proyecto)
  - Runners Linux/Windows/macOS (iOS requiere macOS).
  - Matrices de jobs, caché de `pub` y Gradle, artefactos, secretos.
  - Integración nativa con PRs y checks.
  - Publicación de artefactos (APK, Web), y fácil integración con Codecov/Play Store mediante acciones de la comunidad.
  - Ideal si el repo ya vive en GitHub.

- Codemagic
  - Enfoque específico para Flutter; plantillas para Android, iOS, Web.
  - Gestión de firmas (Android keystore/iOS certificates) simplificada, builds en macOS listos.
  - Integraciones con Play Console, App Store Connect, Firebase App Distribution.
  - UI amigable, logs detallados, flujos YAML opcionales.

- Bitrise
  - Workflows visuales, Steps marketplace (Gradle, Xcode, Fastlane).
  - Runners macOS para iOS, caché inteligente, integraciones de store y test.
  - Buen soporte para proyectos móviles multi-plataforma.

- GitLab CI/CD
  - `.gitlab-ci.yml`, runners compartidos o propios (incluye macOS si gestionas runners).
  - Potente orquestación y control de permisos; integración con repos GitLab.

- CircleCI / Azure DevOps / Jenkins
  - CircleCI: pipelines declarativos, caching, orbs de comunidad; macOS disponible en planes.
  - Azure DevOps: Pipelines YAML, Service Connections, distribución a stores.
  - Jenkins: altamente configurable on‑prem; requiere mantener agentes (incluido macOS para iOS).

Características clave a considerar para desarrollo móvil Flutter
- Soporte de plataformas: macOS para iOS; Linux para Android/Web.
- Caché: `~/.pub-cache`, Gradle (`~/.gradle`), `build/` selectivo.
- Artefactos: APK/AAB, IPA, `build/web`, reportes de cobertura `lcov.info`.
- Pruebas: ejecución headless de unit/widget tests; integración con Firebase Test Lab para tests de integración en dispositivos.
- Seguridad: manejo de secretos (tokens, keystore, certificados) y variables protegidas.
- Firma y publicación: Fastlane/App Store Connect/Play Console; tracks (internal/beta/production).
- Escalabilidad: matrices por Flutter/Dart Channels, flavors, ABI splits.
- Observabilidad: logs, retención de artefactos, anotaciones en PRs, badges de estado.

Recomendación para este proyecto
- Mantener GitHub Actions como CI por integración directa y simplicidad.
- Añadir en fases:
  1) Cacheo de pub/Gradle.
  2) Job opcional de pruebas de integración (si se agregan) en emulador/Flutter Test.
  3) Job de iOS en macOS (si se requiere), gestionando secretos de firma.
  4) Publicación a Play Console/TestFlight cuando el proyecto esté listo para distribución.
