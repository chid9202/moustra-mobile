import 'package:flutter/material.dart';
import 'package:moustra/services/clients/store_api.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';

final accountStore = ValueNotifier<List<AccountStoreDto>?>(null);

Future<List<AccountStoreDto>> useAccountStore() async {
  if (accountStore.value == null) {
    final value = await StoreApi<AccountStoreDto>().getStore(StoreKeys.account);
    accountStore.value = value;
    return value;
  }
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
  return accountStore.value?.firstWhere(
    (account) => account.accountUuid == uuid,
  );
}
