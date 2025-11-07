# Evidencias de Integración Continua

Este documento recopila evidencias locales de la ejecución de análisis y pruebas, equivalentes a lo que corre el pipeline de CI.

- Comando: `flutter analyze`
  - Resultado: sin issues.

Salida observada:

```
Analyzing barista-bot-cafe...
No issues found! (ran in ~3s)
```

- Comando: `flutter test --coverage`
  - Resultado: todas las pruebas pasan. Se generó `coverage/lcov.info`.

Salida observada (resumen):

```
00:00 +0: loading test/rate_limiter_test.dart
00:01 +6: All tests passed!
```

- Artefactos esperados en CI (GitHub Actions):
  - `coverage/lcov.info` como artefacto (job Analyze & Tests).
  - `build/app/outputs/flutter-apk/app-debug.apk` como artefacto (job Build Android).
  - `build/web` empaquetado como artefacto (job Build Web).

Cómo visualizar evidencias en GitHub Actions:
- Abrir la ejecución del workflow en la pestaña `Actions`, seleccionar la corrida, y revisar logs por job.
- Descargar artefactos desde la sección `Artifacts` de la corrida.
