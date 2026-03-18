import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/profile_dto.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/stores/account_store.dart';
import 'package:moustra/stores/profile_store.dart';

import '../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    installNoOpDioApiClient();
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  setUp(() {
    accountStore.value = null;
    profileState.value = null;
  });

  tearDown(() {
    accountStore.value = null;
    profileState.value = null;
  });

  AccountStoreDto _makeAccount(String uuid, String firstName) {
    return AccountStoreDto(
      accountId: uuid.hashCode,
      accountUuid: uuid,
      user: UserDto(firstName: firstName, lastName: 'Test'),
    );
  }

  group('useAccountStore', () {
    test('returns existing list when store is populated', () async {
      accountStore.value = [_makeAccount('uuid-1', 'Alice')];

      final result = await useAccountStore();
      expect(result.length, 1);
      expect(result.first.accountUuid, 'uuid-1');
    });
  });

  group('getAccountsHook', () {
    test('returns all accounts when store is populated', () async {
      accountStore.value = [
        _makeAccount('uuid-1', 'Alice'),
        _makeAccount('uuid-2', 'Bob'),
      ];

      final result = await getAccountsHook();
      expect(result.length, 2);
    });

    test('returns empty list when store is empty', () async {
      accountStore.value = [];
      final result = await getAccountsHook();
      expect(result, isEmpty);
    });
  });

  group('getAccountHook', () {
    test('returns matching account when uuid is provided', () async {
      accountStore.value = [
        _makeAccount('uuid-1', 'Alice'),
        _makeAccount('uuid-2', 'Bob'),
      ];

      final result = await getAccountHook('uuid-2');
      expect(result, isNotNull);
      expect(result!.accountUuid, 'uuid-2');
    });

    test('returns first account when uuid does not match (orElse fallback)',
        () async {
      accountStore.value = [
        _makeAccount('uuid-1', 'Alice'),
      ];

      final result = await getAccountHook('non-existent');
      expect(result, isNotNull);
      expect(result!.accountUuid, 'uuid-1');
    });

    test(
        'falls back to profileState accountUuid when uuid is null', () async {
      accountStore.value = [
        _makeAccount('uuid-1', 'Alice'),
        _makeAccount('profile-uuid', 'Profile User'),
      ];
      profileState.value = ProfileResponseDto(
        accountUuid: 'profile-uuid',
        firstName: 'Profile',
        lastName: 'User',
        email: 'test@test.com',
        labName: 'Test Lab',
        labUuid: 'lab-uuid',
        onboarded: true,
        onboardedDate: null,
        position: null,
        role: 'admin',
        plan: 'free',
      );

      final result = await getAccountHook(null);
      expect(result, isNotNull);
      expect(result!.accountUuid, 'profile-uuid');
    });

    test(
        'falls back to profileState accountUuid when uuid is empty', () async {
      accountStore.value = [
        _makeAccount('uuid-1', 'Alice'),
        _makeAccount('profile-uuid', 'Profile User'),
      ];
      profileState.value = ProfileResponseDto(
        accountUuid: 'profile-uuid',
        firstName: 'Profile',
        lastName: 'User',
        email: 'test@test.com',
        labName: 'Test Lab',
        labUuid: 'lab-uuid',
        onboarded: true,
        onboardedDate: null,
        position: null,
        role: 'admin',
        plan: 'free',
      );

      final result = await getAccountHook('');
      expect(result, isNotNull);
      expect(result!.accountUuid, 'profile-uuid');
    });

    test('returns firstOrNull when no uuid and no profileState', () async {
      accountStore.value = [
        _makeAccount('uuid-1', 'Alice'),
      ];
      profileState.value = null;

      final result = await getAccountHook(null);
      expect(result, isNotNull);
      expect(result!.accountUuid, 'uuid-1');
    });

    test('returns null when store is empty and no profileState', () async {
      accountStore.value = [];
      profileState.value = null;

      final result = await getAccountHook(null);
      expect(result, isNull);
    });
  });

  group('accountStore value', () {
    test('can be set and read', () {
      accountStore.value = [_makeAccount('uuid-1', 'Alice')];

      expect(accountStore.value, isNotNull);
      expect(accountStore.value!.length, 1);
      expect(accountStore.value!.first.user.firstName, 'Alice');
    });

    test('defaults to null', () {
      expect(accountStore.value, isNull);
    });
  });
}
