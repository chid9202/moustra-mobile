import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/user_detail_dto.dart';

void main() {
  final userJson = {
    'email': 'john@example.com',
    'firstName': 'John',
    'lastName': 'Doe',
    'isActive': true,
  };

  final accountSettingJson = {
    'enableDailyReport': true,
    'onboardingTour': false,
    'animalCreationTour': true,
  };

  final labJson = {'labId': 1, 'labUuid': 'lab-uuid-1', 'labName': 'Mouse Lab'};

  group('UserDetailDto', () {
    test('fromJson with complete data', () {
      final json = {
        'accountId': 1,
        'accountUuid': 'account-uuid-1',
        'user': userJson,
        'status': 'active',
        'role': 'admin',
        'isActive': true,
        'position': 'Principal Investigator',
        'accountSetting': accountSettingJson,
        'onboarded': true,
        'lab': labJson,
      };

      final dto = UserDetailDto.fromJson(json);

      expect(dto.accountId, equals(1));
      expect(dto.accountUuid, equals('account-uuid-1'));
      expect(dto.user.email, equals('john@example.com'));
      expect(dto.user.firstName, equals('John'));
      expect(dto.status, equals('active'));
      expect(dto.role, equals('admin'));
      expect(dto.isActive, isTrue);
      expect(dto.position, equals('Principal Investigator'));
      expect(dto.accountSetting.enableDailyReport, isTrue);
      expect(dto.onboarded, isTrue);
      expect(dto.lab.labName, equals('Mouse Lab'));
    });

    test('fromJson with null position', () {
      final json = {
        'accountId': 1,
        'accountUuid': 'account-uuid-1',
        'user': userJson,
        'status': 'active',
        'role': 'admin',
        'isActive': true,
        'accountSetting': accountSettingJson,
        'onboarded': true,
        'lab': labJson,
      };

      final dto = UserDetailDto.fromJson(json);

      expect(dto.position, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'accountId': 1,
        'accountUuid': 'account-uuid-1',
        'user': userJson,
        'status': 'active',
        'role': 'admin',
        'isActive': true,
        'position': 'PI',
        'accountSetting': accountSettingJson,
        'onboarded': true,
        'lab': labJson,
      };

      final dto = UserDetailDto.fromJson(json);
      final output = dto.toJson();

      expect(output['accountId'], equals(1));
      expect(output['accountUuid'], equals('account-uuid-1'));
      expect(output['role'], equals('admin'));
      expect(output['position'], equals('PI'));
    });
  });

  group('PutUserDetailDto', () {
    test('fromJson with complete data', () {
      final json = {
        'accountUuid': 'account-uuid-1',
        'email': 'john@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'role': 'admin',
        'position': 'PI',
        'isActive': true,
        'accountSetting': accountSettingJson,
      };

      final dto = PutUserDetailDto.fromJson(json);

      expect(dto.accountUuid, equals('account-uuid-1'));
      expect(dto.email, equals('john@example.com'));
      expect(dto.firstName, equals('John'));
      expect(dto.role, equals('admin'));
      expect(dto.isActive, isTrue);
      expect(dto.accountSetting!.enableDailyReport, isTrue);
    });

    test('fromJson with minimal data', () {
      final json = {'role': 'member', 'isActive': false};

      final dto = PutUserDetailDto.fromJson(json);

      expect(dto.accountUuid, isNull);
      expect(dto.email, isNull);
      expect(dto.firstName, isNull);
      expect(dto.lastName, isNull);
      expect(dto.position, isNull);
      expect(dto.accountSetting, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'accountUuid': 'account-uuid-1',
        'email': 'john@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'role': 'admin',
        'position': 'PI',
        'isActive': true,
      };

      final dto = PutUserDetailDto.fromJson(json);
      final output = dto.toJson();

      expect(output['role'], equals('admin'));
      expect(output['isActive'], isTrue);
    });
  });

  group('PostUserDetailDto', () {
    test('fromJson with complete data', () {
      final json = {
        'accountUuid': 'account-uuid-1',
        'email': 'john@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'role': 'member',
        'position': 'Researcher',
        'isActive': true,
        'lab': 'lab-uuid-1',
      };

      final dto = PostUserDetailDto.fromJson(json);

      expect(dto.accountUuid, equals('account-uuid-1'));
      expect(dto.email, equals('john@example.com'));
      expect(dto.firstName, equals('John'));
      expect(dto.lastName, equals('Doe'));
      expect(dto.role, equals('member'));
      expect(dto.position, equals('Researcher'));
      expect(dto.isActive, isTrue);
      expect(dto.lab, equals('lab-uuid-1'));
    });

    test('toJson round-trip', () {
      final json = {
        'accountUuid': 'account-uuid-1',
        'email': 'john@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'role': 'member',
        'isActive': true,
        'lab': 'lab-uuid-1',
      };

      final dto = PostUserDetailDto.fromJson(json);
      final output = dto.toJson();

      expect(output['accountUuid'], equals(json['accountUuid']));
      expect(output['email'], equals(json['email']));
      expect(output['lab'], equals(json['lab']));
    });
  });
}
