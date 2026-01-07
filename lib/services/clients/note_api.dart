import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/note_dto.dart';
import 'package:moustra/services/dtos/note_entity_type.dart';
import 'package:moustra/services/dtos/post_note_dto.dart';
import 'package:moustra/services/dtos/put_note_dto.dart';

class NoteApi {
  Future<NoteDto> createNote(
    String entityUuid,
    NoteEntityType entityType,
    String content,
  ) async {
    final path = '/${entityType.value}/$entityUuid/note';
    final payload = PostNoteDto(content: content);
    final res = await apiClient.post(path, body: payload);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to create note: ${res.body}');
    }
    return NoteDto.fromJson(jsonDecode(res.body));
  }

  Future<NoteDto> updateNote(
    String entityUuid,
    NoteEntityType entityType,
    String noteUuid,
    String content,
  ) async {
    final path = '/${entityType.value}/$entityUuid/note/$noteUuid';
    final payload = PutNoteDto(content: content);
    final res = await apiClient.put(path, body: payload);
    if (res.statusCode != 200) {
      throw Exception('Failed to update note: ${res.body}');
    }
    return NoteDto.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteNote(
    String entityUuid,
    NoteEntityType entityType,
    String noteUuid,
  ) async {
    final path = '/${entityType.value}/$entityUuid/note/$noteUuid';
    final res = await apiClient.delete(path);
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Failed to delete note: ${res.body}');
    }
  }
}

final NoteApi noteApi = NoteApi();

