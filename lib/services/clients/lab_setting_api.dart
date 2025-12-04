import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/lab_setting_dto.dart';

class LabSettingApi {
  Future<LabSettingDto> getLabSetting() async {
    final res = await apiClient.get('/lab/setting');
    if (res.statusCode != 200) {
      throw Exception('Failed to get lab setting: ${res.body}');
    }
    final Map<String, dynamic> data = jsonDecode(res.body);
    return LabSettingDto.fromJson(data);
  }

  Future<void> updateLabSetting(LabSettingDto setting) async {
    final res = await apiClient.put('/lab/setting', body: setting.toJson());
    if (res.statusCode != 200) {
      throw Exception('Failed to update lab setting: ${res.body}');
    }
  }
}

final LabSettingApi labSettingApi = LabSettingApi();


