import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/services/dtos/account_dto.dart';

void main() {
  group('AccountHelper', () {
    group('getOwnerName', () {
      test('returns empty string for null account', () {
        expect(AccountHelper.getOwnerName(null), '');
      });

      test('returns empty string when user is null', () {
        final account = AccountDto(accountUuid: 'uuid1', user: null);
        expect(AccountHelper.getOwnerName(account), '');
      });

      test('returns full name when first and last name present', () {
        final account = AccountDto(
          accountUuid: 'uuid1',
          user: UserDto(firstName: 'Jane', lastName: 'Smith'),
        );
        expect(AccountHelper.getOwnerName(account), 'Jane Smith');
      });

      test('returns email when firstName is empty', () {
        final account = AccountDto(
          accountUuid: 'uuid1',
          user: UserDto(
              firstName: '', lastName: 'Smith', email: 'smith@example.com'),
        );
        expect(AccountHelper.getOwnerName(account), 'smith@example.com');
      });

      test('returns email when lastName is empty', () {
        final account = AccountDto(
          accountUuid: 'uuid1',
          user: UserDto(
              firstName: 'Jane', lastName: '', email: 'jane@example.com'),
        );
        expect(AccountHelper.getOwnerName(account), 'jane@example.com');
      });

      test('returns email when both names are empty', () {
        final account = AccountDto(
          accountUuid: 'uuid1',
          user: UserDto(
              firstName: '', lastName: '', email: 'user@example.com'),
        );
        expect(AccountHelper.getOwnerName(account), 'user@example.com');
      });

      test('returns empty string when names empty and email is null', () {
        final account = AccountDto(
          accountUuid: 'uuid1',
          user: UserDto(firstName: '', lastName: '', email: null),
        );
        expect(AccountHelper.getOwnerName(account), '');
      });
    });
  });
}
