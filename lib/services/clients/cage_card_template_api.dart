import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/cage_card_template_dto.dart';

class CageCardTemplateApi {
  static const String _basePath = '/cage-card-template';

  Future<List<CageCardTemplateDto>> getTemplates() async {
    final res = await dioApiClient.get(_basePath);
    final List<dynamic> data = res.data as List<dynamic>;
    return data
        .map((j) => CageCardTemplateDto.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<CageCardTemplateDto> setDefaultTemplate(String templateUuid) async {
    final res = await dioApiClient.put(
      '$_basePath/$templateUuid',
      body: {'isDefault': true},
    );
    return CageCardTemplateDto.fromJson(res.data as Map<String, dynamic>);
  }
}

final CageCardTemplateApi cageCardTemplateApi = CageCardTemplateApi();
