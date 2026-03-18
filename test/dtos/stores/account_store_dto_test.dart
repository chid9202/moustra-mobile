import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/account_dto.dart';

void main() {
  group('AccountStoreDto', () {
    test('fromJson with complete data', () {
      final json = {
        'accountId': 1,
        'accountUuid': 'account-uuid-1',
        'isActive': true,
        'user': {
          'email': 'test@example.com',
          'firstName': 'John',
          'lastName': 'Doe',
          'isActive': true,
        },
      };

      final dto = AccountStoreDto.fromJson(json);

      expect(dto.accountId, equals(1));
      expect(dto.accountUuid, equals('account-uuid-1'));
      expect(dto.isActive, isTrue);
      expect(dto.user.firstName, equals('John'));
      expect(dto.user.lastName, equals('Doe'));
      expect(dto.user.email, equals('test@example.com'));
    });

    test('fromJson with minimal data', () {
      final json = {
        'accountId': 2,
        'accountUuid': 'account-uuid-2',
        'user': {
          'firstName': 'Jane',
          'lastName': 'Smith',
        },
      };

      final dto = AccountStoreDto.fromJson(json);

      expect(dto.accountId, equals(2));
      expect(dto.isActive, isNull);
      expect(dto.user.email, isNull);
    });

    test('toJson round-trip', () {
      final json = {
        'accountId': 1,
        'accountUuid': 'account-uuid-1',
        'isActive': true,
        'user': {
          'firstName': 'John',
          'lastName': 'Doe',
        },
      };

      final dto = AccountStoreDto.fromJson(json);
      final output = dto.toJson();

      expect(output['accountId'], equals(1));
      expect(output['accountUuid'], equals('account-uuid-1'));
      expect(output['isActive'], isTrue);
      expect(output['user'], isA<Map<String, dynamic>>());
      expect((output['user'] as Map)['firstName'], equals('John'));
    });

    test('toJson omits null values (includeIfNull: false)', () {
      final dto = AccountStoreDto(
        accountId: 1,
        accountUuid: 'uuid-1',
        user: UserDto(firstName: 'John', lastName: 'Doe'),
      );

      final output = dto.toJson();

      expect(output.containsKey('isActive'), isFalse);
    });

    test('toAccountDto converts correctly', () {
      final dto = AccountStoreDto(
        accountId: 1,
        accountUuid: 'account-uuid-1',
        user: UserDto(firstName: 'John', lastName: 'Doe'),
        isActive: true,
      );

      final accountDto = dto.toAccountDto();

      expect(accountDto.accountId, equals(1));
      expect(accountDto.accountUuid, equals('account-uuid-1'));
      expect(accountDto.isActive, isTrue);
      expect(accountDto.user!.firstName, equals('John'));
    });
  });
}
