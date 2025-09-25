# Estrategia de Versionamiento - Barista Bot Cafe

## Estructura de Ramas
- **main**: Código estable para producción
- **develop**: Rama de integración continua
- **feature/**: Nuevas funcionalidades (ej: feature/auth-google)
- **hotfix/**: Correcciones urgentes (ej: hotfix/login-crash)

## Convenciones de Commits (Conventional Commits)
- `feat:` nueva funcionalidad
- `fix:` corrección de bug  
- `docs:` documentación
- `refactor:` refactoring sin nuevos features

**Ejemplos:**
- `feat(auth): add Google Sign-In`
- `fix(menu): resolve loading issue`

## Política de Pull Requests
- **Mínimo 1 revisor** para merge a develop
- **Mínimo 2 revisores** para merge a main
- **CI debe pasar** antes del merge

## Tagging Semántico
- `v0.1.0` - Setup inicial y MVP básico
- `v0.2.0` - Chat IA integrado
- `v0.3.0` - Sistema de pagos
- `v1.0.0` - Release producción
