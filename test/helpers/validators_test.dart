import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/helpers/validators.dart';

void main() {
  group('Validators.required', () {
    test('returns error for null', () {
      expect(Validators.required('Name')(null), 'Name is required');
    });

    test('returns error for empty string', () {
      expect(Validators.required('Name')(''), 'Name is required');
    });

    test('returns error for whitespace-only', () {
      expect(Validators.required('Name')('   '), 'Name is required');
    });

    test('returns null for valid value', () {
      expect(Validators.required('Name')('John'), isNull);
    });
  });

  group('Validators.email', () {
    test('returns error for null', () {
      expect(Validators.email(null), isNotNull);
    });

    test('returns error for empty', () {
      expect(Validators.email(''), isNotNull);
    });

    test('returns error for invalid email', () {
      expect(Validators.email('notanemail'), isNotNull);
      expect(Validators.email('missing@'), isNotNull);
      expect(Validators.email('@missing.com'), isNotNull);
    });

    test('returns null for valid email', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('a@b.c'), isNull);
    });
  });

  group('Validators.minLength', () {
    test('returns error for short value', () {
      expect(Validators.minLength(5)('abc'), isNotNull);
    });

    test('returns error for null', () {
      expect(Validators.minLength(1)(null), isNotNull);
    });

    test('returns null for long enough value', () {
      expect(Validators.minLength(3)('abc'), isNull);
      expect(Validators.minLength(3)('abcd'), isNull);
    });
  });

  group('Validators.maxLength', () {
    test('returns error for value exceeding max', () {
      expect(Validators.maxLength(3)('abcd'), isNotNull);
    });

    test('returns null for value within limit', () {
      expect(Validators.maxLength(3)('abc'), isNull);
    });

    test('returns null for null value', () {
      expect(Validators.maxLength(3)(null), isNull);
    });
  });

  group('Validators.numeric', () {
    test('returns error for non-numeric', () {
      expect(Validators.numeric('abc'), isNotNull);
    });

    test('returns null for numeric string', () {
      expect(Validators.numeric('123'), isNull);
      expect(Validators.numeric('12.5'), isNull);
      expect(Validators.numeric('-3'), isNull);
    });

    test('returns null for empty (use required for presence)', () {
      expect(Validators.numeric(''), isNull);
      expect(Validators.numeric(null), isNull);
    });
  });

  group('Validators.compose', () {
    test('returns first error found', () {
      final validator = Validators.compose([
        Validators.required('Field'),
        Validators.minLength(5),
      ]);
      expect(validator(''), 'Field is required');
    });

    test('returns minLength error when required passes', () {
      final validator = Validators.compose([
        Validators.required('Field'),
        Validators.minLength(5),
      ]);
      expect(validator('abc'), 'Must be at least 5 characters');
    });

    test('returns null when all validators pass', () {
      final validator = Validators.compose([
        Validators.required('Field'),
        Validators.minLength(3),
      ]);
      expect(validator('abcdef'), isNull);
    });
  });
}
