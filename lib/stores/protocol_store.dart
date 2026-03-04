import 'package:flutter/material.dart';
import 'package:moustra/services/clients/protocol_api.dart';
import 'package:moustra/services/dtos/protocol_dto.dart';

final protocolStore = ValueNotifier<List<ProtocolDto>?>(null);

Future<List<ProtocolDto>> useProtocolStore() async {
  if (protocolStore.value == null) {
    await refreshProtocolStore();
  }
  return protocolStore.value ?? [];
}

Future<void> refreshProtocolStore() async {
  try {
    final page = await protocolApi.getProtocols(pageSize: 1000);
    protocolStore.value = page.results;
  } catch (e) {
    debugPrint('Error refreshing protocol store: $e');
  }
}
