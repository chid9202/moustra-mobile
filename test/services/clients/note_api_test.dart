import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/note_dto.dart';
import 'package:moustra/services/dtos/note_entity_type.dart';

import 'note_api_test.mocks.dart';

class TestableNoteApi {
  final DioApiClient apiClient;

  TestableNoteApi(this.apiClient);

  Future<NoteDto> createNote(
    String entityUuid,
    NoteEntityType entityType,
    String content,
  ) async {
    final path = '/${entityType.value}/$entityUuid/note';
    final res = await apiClient.post(path, body: {'content': content});
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
    final res = await apiClient.put(path, body: {'content': content});
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
    final res = await apiClient.delete(path);
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Failed to delete note: ${res.data}');
    }
  }
}

Map<String, dynamic> _sampleNoteJson({
  String uuid = 'note-uuid-1',
  String content = 'Test note',
}) =>
    {
      'noteUuid': uuid,
      'content': content,
      'createdDate': '2025-06-01T10:00:00Z',
      'createdBy': null,
      'updatedDate': null,
    };

@GenerateMocks([DioApiClient])
void main() {
  group('NoteApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableNoteApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = TestableNoteApi(mockApiClient);
    });

    group('createNote', () {
      test('should return NoteDto on success', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleNoteJson(),
                  statusCode: 201,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.createNote(
          'entity-uuid-1',
          NoteEntityType.animal,
          'Test note',
        );

        expect(result.noteUuid, 'note-uuid-1');
        expect(result.content, 'Test note');
        verify(mockApiClient.post(
          '/animal/entity-uuid-1/note',
          body: anyNamed('body'),
          query: anyNamed('query'),
        )).called(1);
      });

      test('should use correct path for cage entity type', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleNoteJson(),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        await api.createNote('cage-uuid', NoteEntityType.cage, 'Cage note');

        verify(mockApiClient.post(
          '/cage/cage-uuid/note',
          body: anyNamed('body'),
          query: anyNamed('query'),
        )).called(1);
      });

      test('should throw on error status', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Error',
                  statusCode: 400,
                  requestOptions: RequestOptions(),
                ));

        expect(
          () => api.createNote('uuid', NoteEntityType.animal, 'note'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateNote', () {
      test('should return updated NoteDto on 200', () async {
        when(mockApiClient.put(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleNoteJson(content: 'Updated note'),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.updateNote(
          'entity-uuid-1',
          NoteEntityType.mating,
          'note-uuid-1',
          'Updated note',
        );

        expect(result.content, 'Updated note');
        verify(mockApiClient.put(
          '/mating/entity-uuid-1/note/note-uuid-1',
          body: anyNamed('body'),
          query: anyNamed('query'),
        )).called(1);
      });

      test('should throw on non-200 status', () async {
        when(mockApiClient.put(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Error',
                  statusCode: 400,
                  requestOptions: RequestOptions(),
                ));

        expect(
          () => api.updateNote('uuid', NoteEntityType.animal, 'nid', 'text'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteNote', () {
      test('should complete on 204', () async {
        when(mockApiClient.delete(any)).thenAnswer((_) async => Response(
              data: null,
              statusCode: 204,
              requestOptions: RequestOptions(),
            ));

        await api.deleteNote(
          'entity-uuid-1',
          NoteEntityType.litter,
          'note-uuid-1',
        );

        verify(mockApiClient.delete('/litter/entity-uuid-1/note/note-uuid-1'))
            .called(1);
      });

      test('should throw on error status', () async {
        when(mockApiClient.delete(any)).thenAnswer((_) async => Response(
              data: 'Error',
              statusCode: 400,
              requestOptions: RequestOptions(),
            ));

        expect(
          () => api.deleteNote('uuid', NoteEntityType.animal, 'nid'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
