import 'package:flutter/material.dart';
import 'package:moustra/services/clients/store_api.dart';
import 'package:moustra/services/dtos/stores/gene_store_dto.dart';

final geneStore = ValueNotifier<List<GeneStoreDto>?>(null);

Future<List<GeneStoreDto>> useGeneStore() async {
  if (geneStore.value == null) {
    final value = await StoreApi<GeneStoreDto>().getStore(StoreKeys.gene);
    geneStore.value = value;
    return value;
  }
  return geneStore.value ?? [];
}

Future<List<GeneStoreDto>> getGenesHook() async {
  await useGeneStore();
  return geneStore.value ?? [];
}

Future<GeneStoreDto?> getGeneHook(String? uuid) async {
  if (uuid == null || uuid == '') {
    return null;
  }
  await useGeneStore();
  return geneStore.value?.firstWhere((gene) => gene.geneUuid == uuid);
}
