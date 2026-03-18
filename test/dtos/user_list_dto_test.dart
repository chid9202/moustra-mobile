import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/user_list_dto.dart';

void main() {
  group('UserListDto', () {
    test('fromJson with complete data', () {
      final json = {
        'accountId': 1,
        'accountUuid': 'account-uuid-1',
        'user': {
          'email': 'john@example.com',
          'firstName': 'John',
          'lastName': 'Doe',
          'isActive': true,
        },
        'status': 'active',
        'role': 'admin',
        'isActive': true,
        'position': 'PI',
        'accountSetting': {
          'enableDailyReport': true,
          'onboardingTour': false,
          'animalCreationTour': true,
        },
        'onboarded': true,
        'lab': {
          'labId': 1,
          'labUuid': 'lab-uuid-1',
          'labName': 'Mouse Lab',
        },
      };

      final dto = UserListDto.fromJson(json);

      expect(dto.accountId, equals(1));
      expect(dto.accountUuid, equals('account-uuid-1'));
      expect(dto.user.email, equals('john@example.com'));
      expect(dto.user.firstName, equals('John'));
      expect(dto.user.lastName, equals('Doe'));
      expect(dto.user.isActive, isTrue);
      expect(dto.status, equals('active'));
      expect(dto.role, equals('admin'));
      expect(dto.isActive, isTrue);
      expect(dto.position, equals('PI'));
      expect(dto.accountSetting.enableDailyReport, isTrue);
      expect(dto.accountSetting.onboardingTour, isFalse);
      expect(dto.onboarded, isTrue);
      expect(dto.lab.labName, equals('Mouse Lab'));
    });

    test('fromJson with null position', () {
      final json = {
        'accountId': 1,
        'accountUuid': 'account-uuid-1',
        'user': {
          'email': 'john@example.com',
          'firstName': 'John',
          'lastName': 'Doe',
          'isActive': true,
        },
        'status': 'active',
        'role': 'member',
        'isActive': true,
        'accountSetting': {
          'enableDailyReport': false,
          'onboardingTour': false,
          'animalCreationTour': false,
        },
        'onboarded': false,
        'lab': {
          'labId': 1,
          'labUuid': 'lab-uuid-1',
          'labName': 'Lab',
        },
      };

      final dto = UserListDto.fromJson(json);

      expect(dto.position, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'accountId': 1,
        'accountUuid': 'account-uuid-1',
        'user': {
          'email': 'john@example.com',
          'firstName': 'John',
          'lastName': 'Doe',
          'isActive': true,
        },
        'status': 'active',
        'role': 'admin',
        'isActive': true,
        'position': 'PI',
        'accountSetting': {
          'enableDailyReport': true,
          'onboardingTour': false,
          'animalCreationTour': true,
        },
        'onboarded': true,
        'lab': {
          'labId': 1,
          'labUuid': 'lab-uuid-1',
          'labName': 'Mouse Lab',
        },
      };

      final dto = UserListDto.fromJson(json);
      final output = dto.toJson();

      expect(output['accountId'], equals(json['accountId']));
      expect(output['role'], equals(json['role']));
      expect(output['position'], equals(json['position']));
    });
  });

  group('UserDto', () {
    test('fromJson with complete data', () {
      final json = {
        'email': 'john@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'isActive': true,
      };

      final dto = UserDto.fromJson(json);

      expect(dto.email, equals('john@example.com'));
      expect(dto.firstName, equals('John'));
      expect(dto.lastName, equals('Doe'));
      expect(dto.isActive, isTrue);
    });

    test('toJson round-trip', () {
      final json = {
        'email': 'john@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'isActive': true,
      };

      final dto = UserDto.fromJson(json);
      final output = dto.toJson();

      expect(output['email'], equals(json['email']));
      expect(output['firstName'], equals(json['firstName']));
    });
  });

  group('AccountSettingDto', () {
    test('fromJson and toJson', () {
      final json = {
        'enableDailyReport': true,
        'onboardingTour': false,
        'animalCreationTour': true,
      };

      final dto = AccountSettingDto.fromJson(json);
      final output = dto.toJson();

      expect(output['enableDailyReport'], equals(true));
      expect(output['onboardingTour'], equals(false));
      expect(output['animalCreationTour'], equals(true));
    });
  });

  group('LabDto', () {
    test('fromJson and toJson', () {
      final json = {
        'labId': 1,
        'labUuid': 'lab-uuid-1',
        'labName': 'Mouse Lab',
      };

      final dto = LabDto.fromJson(json);

      expect(dto.labId, equals(1));
      expect(dto.labUuid, equals('lab-uuid-1'));
      expect(dto.labName, equals('Mouse Lab'));

      final output = dto.toJson();

      expect(output['labId'], equals(1));
      expect(output['labUuid'], equals('lab-uuid-1'));
    });
  });
}
