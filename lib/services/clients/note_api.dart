import 'package:moustra/services/clients/dio_api_client.dart';
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
    final res = await dioApiClient.post(path, body: payload);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to create note: ${res.data}');
    }
    return NoteDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<NoteDto> updateNote(
    String entityUuid,
    NoteEntityType entityType,
    String noteUuid,
    String content,
  ) async {
    final path = '/${entityType.value}/$entityUuid/note/$noteUuid';
    final payload = PutNoteDto(content: content);
    final res = await dioApiClient.put(path, body: payload);
    if (res.statusCode != 200) {
      throw Exception('Failed to update note: ${res.data}');
    }
    return NoteDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteNote(
    String entityUuid,
    NoteEntityType entityType,
    String noteUuid,
  ) async {
    final path = '/${entityType.value}/$entityUuid/note/$noteUuid';
    final res = await dioApiClient.delete(path);
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Failed to delete note: ${res.data}');
    }
  }
}

final NoteApi noteApi = NoteApi();
