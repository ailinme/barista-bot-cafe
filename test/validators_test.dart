import 'package:flutter_test/flutter_test.dart';
import 'package:barista_bot_cafe/core/security/validators.dart';

void main() {
  group('Validators', () {
    test('email: rejects invalid and accepts valid', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('foo'), isNotNull);
      expect(Validators.email('a@b.c'), isNull);
      expect(Validators.email('user+alias@example.co'), isNull);
    });

    test('password: requires complexity', () {
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('lowercaseonly1!'), isNotNull);
      expect(Validators.password('ValidPass1!'), isNull);
    });

    test('phone: enforces digits length 10..15', () {
      expect(Validators.phone('123'), isNotNull);
      expect(Validators.phone('1234567890'), isNull);
      expect(Validators.phone('(+52) 442-123-4567'), isNull);
    });

    test('name: allows accents and hyphen', () {
      expect(Validators.name(''), isNotNull);
      expect(Validators.name("José O'Connor-Pérez"), isNull);
    });
  });
}

