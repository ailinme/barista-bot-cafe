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
    final emailRegex = RegExp(r'^[^\s@+]+(\+[^\s@]+)?@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(v)) return 'Ingresa un correo valido';
    return null;
  }

  static String? phone(String? value) {
    final digits = sanitize(value)?.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits == null || digits.isEmpty) return 'Por favor ingresa tu telefono';
    if (digits.length < 10 || digits.length > 15) {
      return 'Ingresa un telefono valido';
    }
    return null;
  }

  static String? name(String? value) {
    final v = sanitize(value);
    if (v == null || v.isEmpty) return 'Por favor ingresa tu nombre';
    final rx = RegExp(r"^[A-Za-z' -]{2,}$");
    if (!rx.hasMatch(v)) return 'Nombre invalido';
    return null;
  }

  static String? password(String? value) {
    final s = value?.trim();
    if (s == null || s.isEmpty) return 'Por favor ingresa tu contrasena';
    if (s.length < 8) return 'Debe tener al menos 8 caracteres';

    final hasUpper = RegExp(r'[A-Z]').hasMatch(s);
    final hasLower = RegExp(r'[a-z]').hasMatch(s);
    final hasDigit = RegExp(r'[0-9]').hasMatch(s);
    final hasSpecial = RegExp(r"""[!@#\$%^&*()_+\-=\[\]{};:\\'",.<>/?]""").hasMatch(s);

    if (!hasUpper || !hasLower || !hasDigit || !hasSpecial) {
      return 'Incluye mayuscula, minuscula, numero y simbolo';
    }
    return null;
  }

  static String? passwordLogin(String? value) {
    final s = value?.trim();
    if (s == null || s.isEmpty) return 'Por favor ingresa tu contrasena';
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
    var v = value.replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), '');
    v = v.replaceAll(RegExp(r'\s+'), ' ').trim();
    return v;
  }
}
