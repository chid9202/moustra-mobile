import 'package:flutter/material.dart';
import 'package:moustra/services/clients/setting_api.dart';
import 'package:moustra/services/dtos/setting_dto.dart';

final settingStore = ValueNotifier<SettingDto?>(null);

Future<SettingDto?> useSettingStore() async {
  if (settingStore.value == null) {
    settingApi.getSetting().then((value) {
      settingStore.value = value;
    });
  }
  return settingStore.value;
}

Future<SettingDto?> getSettingHook() async {
  await useSettingStore();
  return settingStore.value;
}

Future<LabSettingStoreDto?> getLabSettingHook() async {
  await useSettingStore();
  return settingStore.value?.labSetting;
}

Future<void> refreshSettingStore() async {
  final value = await settingApi.getSetting();
  settingStore.value = value;
}
