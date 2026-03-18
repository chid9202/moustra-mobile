import 'dart:io';

import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/attachment_dto.dart';

class AttachmentApi {
  static const String _animalBasePath = '/animal';

  /// Get all attachments for an animal
  Future<List<AttachmentDto>> getAnimalAttachments(String animalUuid) async {
    final res = await dioApiClient.get('$_animalBasePath/$animalUuid/attachment');
    if (res.statusCode != 200) {
      throw Exception('Failed to get attachments: ${res.data}');
    }
    final List<dynamic> data = res.data as List<dynamic>;
    return data.map((e) => AttachmentDto.fromJson(e)).toList();
  }

  /// Upload a file attachment to an animal
  Future<AttachmentDto> uploadAnimalAttachment(
    String animalUuid,
    File file, {
    String? attachmentType,
  }) async {
    final fields = <String, String>{};
    if (attachmentType != null) {
      fields['attachment_type'] = attachmentType;
    }

    final res = await dioApiClient.uploadFile(
      '$_animalBasePath/$animalUuid/attachment',
      file: file,
      fields: fields.isNotEmpty ? fields : null,
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to upload attachment: ${res.data}');
    }

    return AttachmentDto.fromJson(res.data as Map<String, dynamic>);
  }

  /// Delete an attachment from an animal
  Future<void> deleteAnimalAttachment(
    String animalUuid,
    String attachmentUuid,
  ) async {
    final res = await dioApiClient.delete(
      '$_animalBasePath/$animalUuid/attachment/$attachmentUuid',
    );
    if (res.statusCode != 204) {
      throw Exception('Failed to delete attachment: ${res.data}');
    }
  }

  /// Get the download link for an attachment
  Future<String> getAttachmentLink(
    String animalUuid,
    String attachmentUuid,
  ) async {
    final res = await dioApiClient.get(
      '$_animalBasePath/$animalUuid/attachment/$attachmentUuid/link',
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to get attachment link: ${res.data}');
    }
    final data = res.data as Map<String, dynamic>;
    return data['link'] as String;
  }
}

final AttachmentApi attachmentApi = AttachmentApi();
