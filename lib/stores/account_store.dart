import 'package:flutter/material.dart';
import 'package:moustra/services/clients/store_api.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/stores/profile_store.dart';

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

/// Get account by UUID. If uuid is null/empty, returns current user's account.
Future<AccountStoreDto?> getAccountHook([String? uuid]) async {
  await useAccountStore();
  
  // If no UUID provided, get current user's account
  final targetUuid = (uuid == null || uuid.isEmpty)
      ? profileState.value?.accountUuid
      : uuid;
  
  if (targetUuid == null || targetUuid.isEmpty) {
    return accountStore.value?.firstOrNull;
  }
  
  return accountStore.value?.firstWhere(
    (account) => account.accountUuid == targetUuid,
    orElse: () => accountStore.value!.first,
  );
}
