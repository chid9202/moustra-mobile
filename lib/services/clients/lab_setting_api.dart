import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/lab_setting_dto.dart';

class LabSettingApi {
  Future<LabSettingDto> getLabSetting() async {
    final res = await dioApiClient.get('/lab/setting');
    if (res.statusCode != 200) {
      throw Exception('Failed to get lab setting: ${res.data}');
    }
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return LabSettingDto.fromJson(data);
  }

  Future<void> updateLabSetting(LabSettingDto setting) async {
    final res = await dioApiClient.put('/lab/setting', body: setting.toJson());
    if (res.statusCode != 200) {
      throw Exception('Failed to update lab setting: ${res.data}');
    }
  }

  Future<void> postErrorReport({
    String? subject,
    required String message,
  }) async {
    final res = await dioApiClient.post('/error-report', body: {
      'subject': subject ?? '',
      'message': message,
    });
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to submit feedback: ${res.data}');
    }
  }
}

final LabSettingApi labSettingApi = LabSettingApi();
