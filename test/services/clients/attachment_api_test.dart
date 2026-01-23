import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/attachment_dto.dart';

import 'attachment_api_test.mocks.dart';

// Testable version of AttachmentApi that accepts a client
class TestableAttachmentApi {
  final ApiClient apiClient;
  static const String _animalBasePath = '/animal';

  TestableAttachmentApi(this.apiClient);

  Future<List<AttachmentDto>> getAnimalAttachments(String animalUuid) async {
    final res = await apiClient.get('$_animalBasePath/$animalUuid/attachment');
    if (res.statusCode != 200) {
      throw Exception('Failed to get attachments: ${res.body}');
    }
    final List<dynamic> data = jsonDecode(res.body);
    return data.map((e) => AttachmentDto.fromJson(e)).toList();
  }

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

@GenerateMocks([ApiClient])
void main() {
  group('AttachmentApi Tests', () {
    late MockApiClient mockApiClient;
    late TestableAttachmentApi attachmentApi;
    late File testFile;

    setUp(() {
      mockApiClient = MockApiClient();
      attachmentApi = TestableAttachmentApi(mockApiClient);
      // Create a temporary test file
      testFile = File('test_file.txt');
    });

    tearDown(() {
      // Clean up test file if it exists
      if (testFile.existsSync()) {
        testFile.deleteSync();
      }
    });

    group('getAnimalAttachments', () {
      test('should return list of attachments', () async {
        // Arrange
        const animalUuid = 'test-animal-uuid';
        final mockResponse = http.Response(
          jsonEncode([
            {
              'attachmentUuid': 'uuid-1',
              'fileName': 'file1.pdf',
              'fileSize': 1024,
              'attachmentType': 'document',
              'createdDate': '2023-01-01T00:00:00Z',
            },
            {
              'attachmentUuid': 'uuid-2',
              'fileName': 'file2.jpg',
              'fileSize': 2048,
              'attachmentType': 'image',
              'createdDate': '2023-01-02T00:00:00Z',
            },
          ]),
          200,
        );

        when(
          mockApiClient.get('/animal/$animalUuid/attachment'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await attachmentApi.getAnimalAttachments(animalUuid);

        // Assert
        expect(result.length, equals(2));
        expect(result.first.attachmentUuid, equals('uuid-1'));
        expect(result.first.fileName, equals('file1.pdf'));
        expect(result.last.attachmentUuid, equals('uuid-2'));
        expect(result.last.fileName, equals('file2.jpg'));
        verify(mockApiClient.get('/animal/$animalUuid/attachment')).called(1);
      });

      test('should return empty list when no attachments', () async {
        // Arrange
        const animalUuid = 'test-animal-uuid';
        final mockResponse = http.Response(jsonEncode([]), 200);

        when(
          mockApiClient.get('/animal/$animalUuid/attachment'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await attachmentApi.getAnimalAttachments(animalUuid);

        // Assert
        expect(result.length, equals(0));
        verify(mockApiClient.get('/animal/$animalUuid/attachment')).called(1);
      });

      test('should throw exception on non-200 status', () async {
        // Arrange
        const animalUuid = 'test-animal-uuid';
        final mockResponse = http.Response('Not Found', 404);

        when(
          mockApiClient.get('/animal/$animalUuid/attachment'),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => attachmentApi.getAnimalAttachments(animalUuid),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('uploadAnimalAttachment', () {
      test('should upload file and return attachment', () async {
        // Arrange
        const animalUuid = 'test-animal-uuid';
        testFile.writeAsStringSync('test content');

        final mockStreamedResponse = http.StreamedResponse(
          Stream.value(
            utf8.encode(
              jsonEncode({
                'attachmentUuid': 'new-uuid',
                'fileName': 'test_file.txt',
                'fileSize': 12,
                'attachmentType': null,
                'createdDate': '2023-01-01T00:00:00Z',
              }),
            ),
          ),
          201,
        );

        when(
          mockApiClient.uploadFile(
            '/animal/$animalUuid/attachment',
            file: testFile,
            fields: null,
          ),
        ).thenAnswer((_) async => mockStreamedResponse);

        // Act
        final result = await attachmentApi.uploadAnimalAttachment(
          animalUuid,
          testFile,
        );

        // Assert
        expect(result.attachmentUuid, equals('new-uuid'));
        expect(result.fileName, equals('test_file.txt'));
        expect(result.fileSize, equals(12));
        verify(
          mockApiClient.uploadFile(
            '/animal/$animalUuid/attachment',
            file: testFile,
            fields: null,
          ),
        ).called(1);
      });

      test('should upload file with attachment type', () async {
        // Arrange
        const animalUuid = 'test-animal-uuid';
        const attachmentType = 'document';
        testFile.writeAsStringSync('test content');

        final mockStreamedResponse = http.StreamedResponse(
          Stream.value(
            utf8.encode(
              jsonEncode({
                'attachmentUuid': 'new-uuid',
                'fileName': 'test_file.txt',
                'fileSize': 12,
                'attachmentType': attachmentType,
                'createdDate': '2023-01-01T00:00:00Z',
              }),
            ),
          ),
          201,
        );

        when(
          mockApiClient.uploadFile(
            '/animal/$animalUuid/attachment',
            file: testFile,
            fields: {'attachment_type': attachmentType},
          ),
        ).thenAnswer((_) async => mockStreamedResponse);

        // Act
        final result = await attachmentApi.uploadAnimalAttachment(
          animalUuid,
          testFile,
          attachmentType: attachmentType,
        );

        // Assert
        expect(result.attachmentUuid, equals('new-uuid'));
        expect(result.attachmentType, equals(attachmentType));
        verify(
          mockApiClient.uploadFile(
            '/animal/$animalUuid/attachment',
            file: testFile,
            fields: {'attachment_type': attachmentType},
          ),
        ).called(1);
      });

      test('should throw exception on non-200/201 status', () async {
        // Arrange
        const animalUuid = 'test-animal-uuid';
        testFile.writeAsStringSync('test content');

        final mockStreamedResponse = http.StreamedResponse(
          Stream.value(utf8.encode('Bad Request')),
          400,
        );

        when(
          mockApiClient.uploadFile(
            '/animal/$animalUuid/attachment',
            file: testFile,
            fields: null,
          ),
        ).thenAnswer((_) async => mockStreamedResponse);

        // Act & Assert
        expect(
          () => attachmentApi.uploadAnimalAttachment(animalUuid, testFile),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteAnimalAttachment', () {
      test('should delete attachment successfully', () async {
        // Arrange
        const animalUuid = 'test-animal-uuid';
        const attachmentUuid = 'test-attachment-uuid';
        final mockResponse = http.Response('', 204);

        when(
          mockApiClient.delete(
            '/animal/$animalUuid/attachment/$attachmentUuid',
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await attachmentApi.deleteAnimalAttachment(animalUuid, attachmentUuid);

        // Assert
        verify(
          mockApiClient.delete(
            '/animal/$animalUuid/attachment/$attachmentUuid',
          ),
        ).called(1);
      });

      test('should throw exception on non-204 status', () async {
        // Arrange
        const animalUuid = 'test-animal-uuid';
        const attachmentUuid = 'test-attachment-uuid';
        final mockResponse = http.Response('Not Found', 404);

        when(
          mockApiClient.delete(
            '/animal/$animalUuid/attachment/$attachmentUuid',
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () =>
              attachmentApi.deleteAnimalAttachment(animalUuid, attachmentUuid),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getAttachmentLink', () {
      test('should return download link', () async {
        // Arrange
        const animalUuid = 'test-animal-uuid';
        const attachmentUuid = 'test-attachment-uuid';
        const expectedLink = 'https://example.com/download/file.pdf';
        final mockResponse = http.Response(
          jsonEncode({'link': expectedLink}),
          200,
        );

        when(
          mockApiClient.get(
            '/animal/$animalUuid/attachment/$attachmentUuid/link',
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await attachmentApi.getAttachmentLink(
          animalUuid,
          attachmentUuid,
        );

        // Assert
        expect(result, equals(expectedLink));
        verify(
          mockApiClient.get(
            '/animal/$animalUuid/attachment/$attachmentUuid/link',
          ),
        ).called(1);
      });

      test('should throw exception on non-200 status', () async {
        // Arrange
        const animalUuid = 'test-animal-uuid';
        const attachmentUuid = 'test-attachment-uuid';
        final mockResponse = http.Response('Not Found', 404);

        when(
          mockApiClient.get(
            '/animal/$animalUuid/attachment/$attachmentUuid/link',
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => attachmentApi.getAttachmentLink(animalUuid, attachmentUuid),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
