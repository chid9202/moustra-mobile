import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/lab_setting_dto.dart';

void main() {
  group('LabSettingDto', () {
    test('fromJson with complete data', () {
      final json = {
        'defaultRackWidth': 5,
        'defaultRackHeight': 10,
        'defaultWeanDate': 21,
        'useEid': true,
        'owner': {
          'accountId': 1,
          'accountUuid': 'owner-uuid-1',
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
            'useComment': true,
            'enableCustomWeanDate': false,
          },
          'onboarded': true,
          'lab': {
            'labId': 1,
            'labUuid': 'lab-uuid-1',
            'labName': 'Mouse Lab',
          },
        },
        'labName': 'Mouse Lab',
      };

      final dto = LabSettingDto.fromJson(json);

      expect(dto.defaultRackWidth, equals(5));
      expect(dto.defaultRackHeight, equals(10));
      expect(dto.defaultWeanDate, equals(21));
      expect(dto.useEid, isTrue);
      expect(dto.owner, isNotNull);
      expect(dto.owner!.accountId, equals(1));
      expect(dto.owner!.user.email, equals('john@example.com'));
      expect(dto.owner!.accountSetting!.useComment, isTrue);
      expect(dto.owner!.accountSetting!.enableCustomWeanDate, isFalse);
      expect(dto.owner!.lab!.labName, equals('Mouse Lab'));
      expect(dto.labName, equals('Mouse Lab'));
    });

    test('fromJson with minimal data', () {
      final json = <String, dynamic>{};

      final dto = LabSettingDto.fromJson(json);

      expect(dto.defaultRackWidth, isNull);
      expect(dto.defaultRackHeight, isNull);
      expect(dto.defaultWeanDate, isNull);
      expect(dto.useEid, isFalse);
      expect(dto.owner, isNull);
      expect(dto.labName, equals(''));
    });

    test('toJson round-trip', () {
      final json = {
        'defaultRackWidth': 5,
        'defaultRackHeight': 10,
        'defaultWeanDate': 21,
        'useEid': true,
        'labName': 'Mouse Lab',
      };

      final dto = LabSettingDto.fromJson(json);
      final output = dto.toJson();

      expect(output['defaultRackWidth'], equals(5));
      expect(output['defaultRackHeight'], equals(10));
      expect(output['defaultWeanDate'], equals(21));
      expect(output['useEid'], isTrue);
      expect(output['labName'], equals('Mouse Lab'));
      expect(output['owner'], isNull);
    });
  });

  group('LabSettingOwnerDto', () {
    test('fromJson with missing user creates default', () {
      final json = {
        'accountId': 1,
        'accountUuid': 'owner-uuid-1',
        'status': 'active',
        'role': 'admin',
        'isActive': true,
        'onboarded': true,
      };

      final dto = LabSettingOwnerDto.fromJson(json);

      expect(dto.user.email, equals(''));
      expect(dto.user.firstName, equals(''));
      expect(dto.user.lastName, equals(''));
    });

    test('fromJson with all defaults', () {
      final json = <String, dynamic>{};

      final dto = LabSettingOwnerDto.fromJson(json);

      expect(dto.accountId, equals(0));
      expect(dto.accountUuid, equals(''));
      expect(dto.status, equals(''));
      expect(dto.role, equals(''));
      expect(dto.isActive, isTrue);
      expect(dto.position, isNull);
      expect(dto.accountSetting, isNull);
      expect(dto.onboarded, isFalse);
      expect(dto.lab, isNull);
    });
  });

  group('LabSettingAccountSettingDto', () {
    test('fromJson with all fields', () {
      final json = {
        'enableDailyReport': true,
        'onboardingTour': false,
        'animalCreationTour': true,
        'useComment': true,
        'enableCustomWeanDate': false,
      };

      final dto = LabSettingAccountSettingDto.fromJson(json);

      expect(dto.enableDailyReport, isTrue);
      expect(dto.onboardingTour, isFalse);
      expect(dto.animalCreationTour, isTrue);
      expect(dto.useComment, isTrue);
      expect(dto.enableCustomWeanDate, isFalse);
    });

    test('fromJson with defaults', () {
      final json = <String, dynamic>{};

      final dto = LabSettingAccountSettingDto.fromJson(json);

      expect(dto.enableDailyReport, isFalse);
      expect(dto.onboardingTour, isFalse);
      expect(dto.animalCreationTour, isFalse);
      expect(dto.useComment, isNull);
      expect(dto.enableCustomWeanDate, isNull);
    });
  });

  group('LabSettingLabDto', () {
    test('fromJson and toJson round-trip', () {
      final json = {
        'labId': 1,
        'labUuid': 'lab-uuid-1',
        'labName': 'Mouse Lab',
      };

      final dto = LabSettingLabDto.fromJson(json);
      final output = dto.toJson();

      expect(output['labId'], equals(1));
      expect(output['labUuid'], equals('lab-uuid-1'));
      expect(output['labName'], equals('Mouse Lab'));
    });

    test('fromJson with defaults', () {
      final json = <String, dynamic>{};

      final dto = LabSettingLabDto.fromJson(json);

      expect(dto.labId, equals(0));
      expect(dto.labUuid, equals(''));
      expect(dto.labName, equals(''));
    });
  });
}
