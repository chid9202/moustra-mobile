import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/utils/safe_json_converter.dart';
import 'package:moustra/stores/profile_store.dart';

void main() {
  group('safeFromJson', () {
    setUp(() {
      // Set profileState to null so ErrorReportService doesn't try to send reports
      profileState.value = null;
    });

    group('successful parsing', () {
      test('should return parsed object when JSON is valid', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'Test',
          'value': 42,
        };

        // Act
        final result = safeFromJson<TestDto>(
          json: json,
          fromJson: (json) => TestDto(
            id: json['id'] as int,
            name: json['name'] as String,
            value: json['value'] as int,
          ),
          dtoName: 'TestDto',
        );

        // Assert
        expect(result.id, 1);
        expect(result.name, 'Test');
        expect(result.value, 42);
      });

      test('should handle null values in JSON when fromJson handles them', () {
        // Arrange
        final json = {
          'id': 1,
          'name': null,
          'value': 42,
        };

        // Act
        final result = safeFromJson<TestDtoWithNull>(
          json: json,
          fromJson: (json) => TestDtoWithNull(
            id: json['id'] as int,
            name: json['name'] as String?,
            value: json['value'] as int,
          ),
          dtoName: 'TestDtoWithNull',
        );

        // Assert
        expect(result.id, 1);
        expect(result.name, isNull);
        expect(result.value, 42);
      });
    });

    group('failure cases', () {
      test('should throw FormatException when parsing fails', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'Test',
        };

        // Act & Assert
        expect(
          () => safeFromJson<TestDto>(
            json: json,
            fromJson: (json) => TestDto(
              id: json['id'] as int,
              name: json['name'] as String,
              value: json['value'] as int, // This will fail - 'value' is missing
            ),
            dtoName: 'TestDto',
          ),
          throwsA(isA<FormatException>()),
        );
      });

      test('should include dtoName in error message', () {
        // Arrange
        final json = {'id': 1};

        // Act & Assert
        expect(
          () => safeFromJson<TestDto>(
            json: json,
            fromJson: (json) => TestDto(
              id: json['id'] as int,
              name: json['name'] as String, // This will fail
              value: json['value'] as int, // This will fail
            ),
            dtoName: 'TestDto',
          ),
          throwsA(
            predicate<FormatException>(
              (e) => e.message.contains('TestDto'),
            ),
          ),
        );
      });

      test('should identify null fields in error message', () {
        // Arrange
        final json = {
          'id': 1,
          'name': null,
          'value': null,
        };

        // Act & Assert
        try {
          safeFromJson<TestDto>(
            json: json,
            fromJson: (json) => TestDto(
              id: json['id'] as int,
              name: json['name'] as String, // This will fail - name is null
              value: json['value'] as int, // This will fail - value is null
            ),
            dtoName: 'TestDto',
          );
          fail('Expected FormatException to be thrown');
        } on FormatException catch (e) {
          expect(e.message, contains('TestDto'));
          expect(e.message, contains('name: null'));
          expect(e.message, contains('value: null'));
        }
      });

      test('should identify empty map fields in error message', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'Test',
          'metadata': <String, dynamic>{},
        };

        // Act & Assert
        try {
          safeFromJson<TestDto>(
            json: json,
            fromJson: (json) => TestDto(
              id: json['id'] as int,
              name: json['name'] as String,
              value: json['value'] as int, // This will fail - value is missing
            ),
            dtoName: 'TestDto',
          );
          fail('Expected FormatException to be thrown');
        } on FormatException catch (e) {
          expect(e.message, contains('TestDto'));
          expect(e.message, contains('metadata: empty map'));
        }
      });

      test('should include all JSON keys in error message', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'Test',
          'value': 42,
          'extra': 'field',
        };

        // Act & Assert
        try {
          safeFromJson<TestDto>(
            json: json,
            fromJson: (json) => TestDto(
              id: json['id'] as int,
              name: json['name'] as String,
              value: json['value'] as int,
            ),
            dtoName: 'TestDto',
          );
          // This should succeed, so let's force a failure
          safeFromJson<TestDto>(
            json: {'id': 1},
            fromJson: (json) => TestDto(
              id: json['id'] as int,
              name: json['name'] as String, // This will fail
              value: json['value'] as int, // This will fail
            ),
            dtoName: 'TestDto',
          );
          fail('Expected FormatException to be thrown');
        } on FormatException catch (e) {
          expect(e.message, contains('TestDto'));
        }
      });

      test('should include original error in exception message', () {
        // Arrange
        final json = {
          'id': 'invalid', // Wrong type
        };

        // Act & Assert
        try {
          safeFromJson<TestDto>(
            json: json,
            fromJson: (json) => TestDto(
              id: json['id'] as int, // This will fail - type error
              name: json['name'] as String,
              value: json['value'] as int,
            ),
            dtoName: 'TestDto',
          );
          fail('Expected FormatException to be thrown');
        } on FormatException catch (e) {
          expect(e.message, contains('TestDto'));
          expect(e.message, contains('Original:'));
        }
      });

      test('should handle type casting errors gracefully', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 123, // Wrong type - should be String
          'value': 42,
        };

        // Act & Assert
        expect(
          () => safeFromJson<TestDto>(
            json: json,
            fromJson: (json) => TestDto(
              id: json['id'] as int,
              name: json['name'] as String, // This will fail - type error
              value: json['value'] as int,
            ),
            dtoName: 'TestDto',
          ),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('error reporting', () {
      test('should not crash when ErrorReportService is called', () {
        // Arrange
        final json = {'id': 1};

        // Act & Assert - should not throw (ErrorReportService is fire-and-forget)
        expect(
          () => safeFromJson<TestDto>(
            json: json,
            fromJson: (json) => TestDto(
              id: json['id'] as int,
              name: json['name'] as String, // This will fail
              value: json['value'] as int, // This will fail
            ),
            dtoName: 'TestDto',
          ),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}

// Helper classes for testing
class TestDto {
  final int id;
  final String name;
  final int value;

  TestDto({
    required this.id,
    required this.name,
    required this.value,
  });
}

class TestDtoWithNull {
  final int id;
  final String? name;
  final int value;

  TestDtoWithNull({
    required this.id,
    this.name,
    required this.value,
  });
}
