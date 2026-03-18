import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/profile_dto.dart';

void main() {
  group('ProfileResponseDto', () {
    test('fromJson with complete data', () {
      final json = {
        'accountUuid': 'account-uuid-1',
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@example.com',
        'labName': 'Mouse Lab',
        'labUuid': 'lab-uuid-1',
        'onboarded': true,
        'onboardedDate': '2024-01-01T00:00:00Z',
        'position': 'PI',
        'role': 'admin',
        'plan': 'premium',
      };

      final dto = ProfileResponseDto.fromJson(json);

      expect(dto.accountUuid, equals('account-uuid-1'));
      expect(dto.firstName, equals('John'));
      expect(dto.lastName, equals('Doe'));
      expect(dto.email, equals('john@example.com'));
      expect(dto.labName, equals('Mouse Lab'));
      expect(dto.labUuid, equals('lab-uuid-1'));
      expect(dto.onboarded, isTrue);
      expect(dto.onboardedDate, isNotNull);
      expect(dto.onboardedDate!.year, equals(2024));
      expect(dto.position, equals('PI'));
      expect(dto.role, equals('admin'));
      expect(dto.plan, equals('premium'));
    });

    test('fromJson with null optional fields', () {
      final json = {
        'accountUuid': 'account-uuid-1',
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@example.com',
        'labName': 'Mouse Lab',
        'labUuid': 'lab-uuid-1',
        'onboarded': false,
        'onboardedDate': null,
        'position': null,
        'role': 'member',
        'plan': 'free',
      };

      final dto = ProfileResponseDto.fromJson(json);

      expect(dto.onboardedDate, isNull);
      expect(dto.position, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'accountUuid': 'account-uuid-1',
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@example.com',
        'labName': 'Mouse Lab',
        'labUuid': 'lab-uuid-1',
        'onboarded': true,
        'onboardedDate': '2024-01-01T00:00:00.000Z',
        'position': 'PI',
        'role': 'admin',
        'plan': 'premium',
      };

      final dto = ProfileResponseDto.fromJson(json);
      final output = dto.toJson();

      expect(output['accountUuid'], equals(json['accountUuid']));
      expect(output['firstName'], equals(json['firstName']));
      expect(output['email'], equals(json['email']));
      expect(output['role'], equals(json['role']));
      expect(output['plan'], equals(json['plan']));
    });
  });

  group('ProfileRequestDto', () {
    test('toJson produces correct output', () {
      final dto = ProfileRequestDto(
        email: 'john@example.com',
        firstName: 'John',
        lastName: 'Doe',
      );

      final output = dto.toJson();

      expect(output['email'], equals('john@example.com'));
      expect(output['firstName'], equals('John'));
      expect(output['lastName'], equals('Doe'));
    });
  });
}
