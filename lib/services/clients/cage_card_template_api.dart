import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/cage_card_template_dto.dart';

class CageCardTemplateApi {
  static const String _basePath = '/cage-card-template';

  Future<List<CageCardTemplateDto>> getTemplates() async {
    final res = await apiClient.get(_basePath);
    final List<dynamic> data = jsonDecode(res.body);
    return data
        .map((j) => CageCardTemplateDto.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<CageCardTemplateDto> setDefaultTemplate(String templateUuid) async {
    final res = await apiClient.put(
      '$_basePath/$templateUuid',
      body: {'isDefault': true},
    );
    return CageCardTemplateDto.fromJson(jsonDecode(res.body));
  }
}

final CageCardTemplateApi cageCardTemplateApi = CageCardTemplateApi();
