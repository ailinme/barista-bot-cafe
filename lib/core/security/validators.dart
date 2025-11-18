import 'dart:core';

class Validators {
  static String? requiredField(String? value, {String fieldName = 'Campo'}) {
    final v = sanitize(value);
    if (v == null || v.isEmpty) return 'Por favor ingresa $fieldName';
    return null;
  }

  static String? email(String? value) {
    final v = sanitize(value)?.toLowerCase();
    if (v == null || v.isEmpty) return 'Por favor ingresa tu correo';
    // Permite + en el local-part y subdominios básicos
    final emailRegex = RegExp(r'^[^\s@+]+(\+[^\s@]+)?@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(v)) return 'Ingresa un correo válido';
    return null;
  }

  static String? phone(String? value) {
    final digits = sanitize(value)?.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits == null || digits.isEmpty) return 'Por favor ingresa tu teléfono';
    if (digits.length < 10 || digits.length > 15) {
      return 'Ingresa un teléfono válido';
    }
    return null;
  }

  static String? name(String? value) {
    final v = sanitize(value);
    if (v == null || v.isEmpty) return 'Por favor ingresa tu nombre';
    // Letras básicas + acentos en español, espacio, apóstrofe y guion
    final rx = RegExp(
      r"^[A-Za-z\u00C1\u00C9\u00CD\u00D3\u00DA\u00DC\u00D1\u00E1\u00E9\u00ED\u00F3\u00FA\u00FC\u00F1' -]{2,}$"
    );
    if (!rx.hasMatch(v)) return 'Nombre inválido';
    return null;
  }

  static String? password(String? value) {
    final s = value?.trim();
    if (s == null || s.isEmpty) return 'Por favor ingresa tu contraseña';
    if (s.length < 8) return 'Debe tener al menos 8 caracteres';

    final hasUpper = RegExp(r'[A-Z]').hasMatch(s);
    final hasLower = RegExp(r'[a-z]').hasMatch(s);
    final hasDigit = RegExp(r'[0-9]').hasMatch(s);
    // Triple comillas raw para poder incluir ' y "
    final hasSpecial = RegExp(r'''[!@#\$%^&*()_+\-=\[\]{};:\\'",.<>/?]''').hasMatch(s);

    if (!hasUpper || !hasLower || !hasDigit || !hasSpecial) {
      return 'Incluye mayúscula, minúscula, número y símbolo';
    }
    return null;
  }

  static String? sanitizeAndLimit(String? value, {int? maxLength}) {
    final s = sanitize(value);
    if (s == null) return null;
    if (maxLength != null && s.length > maxLength) return s.substring(0, maxLength);
    return s;
  }

  static String? sanitize(String? value) {
    if (value == null) return null;
    // Quitar caracteres de control y colapsar espacios
    var v = value.replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), '');
    v = v.replaceAll(RegExp(r'\s+'), ' ').trim();
    return v;
  }
}

