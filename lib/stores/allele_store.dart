import 'package:flutter/material.dart';
import 'package:moustra/services/clients/allele_api.dart';
import 'package:moustra/services/clients/store_api.dart';
import 'package:moustra/services/dtos/stores/allele_store_dto.dart';

final alleleStore = ValueNotifier<List<AlleleStoreDto>?>(null);

Future<List<AlleleStoreDto>> useAlleleStore() async {
  if (alleleStore.value == null) {
    final value = await StoreApi<AlleleStoreDto>().getStore(StoreKeys.allele);
    alleleStore.value = value;
    return value;
  }
  return alleleStore.value ?? [];
}

Future<List<AlleleStoreDto>> getAllelesHook() async {
  await useAlleleStore();
  return alleleStore.value ?? [];
}

Future<AlleleStoreDto?> getAlleleHook(String? uuid) async {
  if (uuid == null || uuid == '') {
    return null;
  }
  await useAlleleStore();
  return alleleStore.value?.firstWhere((allele) => allele.alleleUuid == uuid);
}

Future<AlleleStoreDto> postAlleleHook(String alleleName) async {
  final newAllele = await alleleApi.postAllele(alleleName);
  // Fetch full list to maintain integrity
  final value = await StoreApi<AlleleStoreDto>().getStore(StoreKeys.allele);
  debugPrint('Allele store updated after create, new count: ${value.length}');
  alleleStore.value = value;
  return newAllele;
}

Future<void> deleteAlleleHook(String alleleUuid) async {
  await alleleApi.deleteAllele(alleleUuid);
  // Fetch full list to maintain integrity
  final value = await StoreApi<AlleleStoreDto>().getStore(StoreKeys.allele);
  debugPrint('Allele store updated after delete, new count: ${value.length}');
  alleleStore.value = value;
}
