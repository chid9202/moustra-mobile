import 'dart:convert';
import 'dart:io';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/attachment_dto.dart';

class AttachmentApi {
  static const String _animalBasePath = '/animal';

  /// Get all attachments for an animal
  Future<List<AttachmentDto>> getAnimalAttachments(String animalUuid) async {
    final res = await apiClient.get('$_animalBasePath/$animalUuid/attachment');
    if (res.statusCode != 200) {
      throw Exception('Failed to get attachments: ${res.body}');
    }
    final List<dynamic> data = jsonDecode(res.body);
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

    final res = await apiClient.uploadFile(
      '$_animalBasePath/$animalUuid/attachment',
      file: file,
      fields: fields.isNotEmpty ? fields : null,
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      final body = await res.stream.bytesToString();
      throw Exception('Failed to upload attachment: $body');
    }

    final body = await res.stream.bytesToString();
    return AttachmentDto.fromJson(jsonDecode(body));
  }

  /// Delete an attachment from an animal
  Future<void> deleteAnimalAttachment(
    String animalUuid,
    String attachmentUuid,
  ) async {
    final res = await apiClient.delete(
      '$_animalBasePath/$animalUuid/attachment/$attachmentUuid',
    );
    if (res.statusCode != 204) {
      throw Exception('Failed to delete attachment: ${res.body}');
    }
  }

  /// Get the download link for an attachment
  Future<String> getAttachmentLink(
    String animalUuid,
    String attachmentUuid,
  ) async {
    final res = await apiClient.get(
      '$_animalBasePath/$animalUuid/attachment/$attachmentUuid/link',
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to get attachment link: ${res.body}');
    }
    final data = jsonDecode(res.body);
    return data['link'] as String;
  }
}

final AttachmentApi attachmentApi = AttachmentApi();
