# MASVS Checklist (Resumen)

- V1: Architecture, Threat Modeling, and Security Requirements
  - Estado: Parcial (documentado en `docs/security.md`)
- V2: Data Storage and Privacy
  - Estado: Cumplido (secretos en Keychain/Keystore; docs de privacidad)
- V3: Cryptography
  - Estado: Cumplido en tránsito (TLS + pinning); en reposo vía Secure Storage
- V4: Authentication and Session Management
  - Estado: Parcial (exp/refresh simulado; falta backend OIDC)
- V5: Network Communication
  - Estado: Cumplido (HTTPS forzado, pinning, timeouts)
- V6: Platform Interaction
  - Estado: Cumplido (permisos JIT + degradación)
- V7: Code Quality and Build Settings
  - Estado: Parcial (CI + lints; recomendaciones de ofuscado)

