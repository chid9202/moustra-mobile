import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/setting_dto.dart';

class SettingApi {
  Future<SettingDto> getSetting() async {
    final res = await apiClient.get('/store/Settings');
    if (res.statusCode != 200) {
      throw Exception('Failed to get setting: ${res.body}');
    }
    final Map<String, dynamic> data = jsonDecode(res.body);
    return SettingDto.fromJson(data);
  }

  Future<SettingDto> updateSetting(SettingDto setting) async {
    final res = await apiClient.put('/setting', body: setting.toJson());
    if (res.statusCode != 200) {
      throw Exception('Failed to update setting: ${res.body}');
    }
    final Map<String, dynamic> data = jsonDecode(res.body);
    return SettingDto.fromJson(data);
  }

  Future<SettingDto> updateAccountSetting(
    AccountSettingDto accountSetting,
  ) async {
    final res = await apiClient.put(
      '/setting/account',
      body: accountSetting.toJson(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to update account setting: ${res.body}');
    }
    final Map<String, dynamic> data = jsonDecode(res.body);
    return SettingDto.fromJson(data);
  }

  Future<SettingDto> updateLabSetting(LabSettingStoreDto labSetting) async {
    final res = await apiClient.put('/setting/lab', body: labSetting.toJson());
    if (res.statusCode != 200) {
      throw Exception('Failed to update lab setting: ${res.body}');
    }
    final Map<String, dynamic> data = jsonDecode(res.body);
    return SettingDto.fromJson(data);
  }
}

final SettingApi settingApi = SettingApi();
