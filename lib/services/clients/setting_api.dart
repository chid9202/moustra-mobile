import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/setting_dto.dart';

class SettingApi {
  Future<SettingDto> getSetting() async {
    final res = await dioApiClient.get('/store/Settings');
    if (res.statusCode != 200) {
      throw Exception('Failed to get setting: ${res.data}');
    }
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return SettingDto.fromJson(data);
  }

  Future<SettingDto> updateSetting(SettingDto setting) async {
    final res = await dioApiClient.put('/setting', body: setting.toJson());
    if (res.statusCode != 200) {
      throw Exception('Failed to update setting: ${res.data}');
    }
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return SettingDto.fromJson(data);
  }

  Future<SettingDto> updateAccountSetting(
    AccountSettingDto accountSetting,
  ) async {
    final res = await dioApiClient.put(
      '/setting/account',
      body: accountSetting.toJson(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to update account setting: ${res.data}');
    }
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return SettingDto.fromJson(data);
  }

  Future<SettingDto> updateLabSetting(LabSettingStoreDto labSetting) async {
    final res = await dioApiClient.put('/setting/lab', body: labSetting.toJson());
    if (res.statusCode != 200) {
      throw Exception('Failed to update lab setting: ${res.data}');
    }
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return SettingDto.fromJson(data);
  }
}

final SettingApi settingApi = SettingApi();
