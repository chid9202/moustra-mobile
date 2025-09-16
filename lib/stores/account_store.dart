import 'package:flutter/material.dart';
import 'package:moustra/services/clients/store_api.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';

final accountStore = ValueNotifier<List<AccountStoreDto>?>(null);

Future<List<AccountStoreDto>> useAccountStore() async {
  print('0000000000000000 ${accountStore.value}');
  if (accountStore.value == null) {
    final value = await StoreApi<AccountStoreDto>().getStore(StoreKeys.account);
    print('1111111111111111 $value');
    accountStore.value = value;
    return value;
  }
  print('2222222222222222 ${accountStore.value}');
  return accountStore.value ?? [];
}

Future<List<AccountStoreDto>> getAccountsHook() async {
  await useAccountStore();
  return accountStore.value ?? [];
}

Future<AccountStoreDto?> getAccountHook(String? uuid) async {
  if (uuid == null || uuid == '') {
    return null;
  }
  await useAccountStore();
  print('3333333333333333 ${accountStore.value}');
  return accountStore.value?.firstWhere(
    (account) => account.accountUuid == uuid,
  );
}
