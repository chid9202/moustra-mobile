import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/attachment_dto.dart';

import 'attachment_api_test.mocks.dart';

// Testable version of AttachmentApi that accepts a client
class TestableAttachmentApi {
  final DioApiClient apiClient;
  static const String _animalBasePath = '/animal';

  TestableAttachmentApi(this.apiClient);

  Future<List<AttachmentDto>> getAnimalAttachments(String animalUuid) async {
    final res = await apiClient.get('$_animalBasePath/$animalUuid/attachment');
    if (res.statusCode != 200) {
      throw Exception('Failed to get attachments: ${res.data}');
    }
    final List<dynamic> data = res.data;
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
      throw Exception('Failed to upload attachment: ${res.data}');
    }

    return AttachmentDto.fromJson(res.data);
  }

  Future<void> deleteAnimalAttachment(
    String animalUuid,
    String attachmentUuid,
  ) async {
    final res = await apiClient.delete(
      '$_animalBasePath/$animalUuid/attachment/$attachmentUuid',
    );
    if (res.statusCode != 204) {
      throw Exception('Failed to delete attachment: ${res.data}');
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
      throw Exception('Failed to get attachment link: ${res.data}');
    }
    final data = res.data;
    return data['link'] as String;
  }
}

@GenerateMocks([DioApiClient])
void main() {
  group('AttachmentApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableAttachmentApi attachmentApi;
    late File testFile;

    setUp(() {
      mockApiClient = MockDioApiClient();
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
        final mockResponse = Response(
          data: [
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
          ],
          statusCode: 200,
          requestOptions: RequestOptions(),
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
        final mockResponse = Response(data: [], statusCode: 200, requestOptions: RequestOptions());

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
        final mockResponse = Response(data: 'Not Found', statusCode: 404, requestOptions: RequestOptions());

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

        final mockResponse = Response(
          data: {
            'attachmentUuid': 'new-uuid',
            'fileName': 'test_file.txt',
            'fileSize': 12,
            'attachmentType': null,
            'createdDate': '2023-01-01T00:00:00Z',
          },
          statusCode: 201,
          requestOptions: RequestOptions(),
        );

        when(
          mockApiClient.uploadFile(
            '/animal/$animalUuid/attachment',
            file: testFile,
            fields: null,
          ),
        ).thenAnswer((_) async => mockResponse);

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

        final mockResponse = Response(
          data: {
            'attachmentUuid': 'new-uuid',
            'fileName': 'test_file.txt',
            'fileSize': 12,
            'attachmentType': attachmentType,
            'createdDate': '2023-01-01T00:00:00Z',
          },
          statusCode: 201,
          requestOptions: RequestOptions(),
        );

        when(
          mockApiClient.uploadFile(
            '/animal/$animalUuid/attachment',
            file: testFile,
            fields: {'attachment_type': attachmentType},
          ),
        ).thenAnswer((_) async => mockResponse);

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

        final mockResponse = Response(
          data: 'Bad Request',
          statusCode: 400,
          requestOptions: RequestOptions(),
        );

        when(
          mockApiClient.uploadFile(
            '/animal/$animalUuid/attachment',
            file: testFile,
            fields: null,
          ),
        ).thenAnswer((_) async => mockResponse);

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
        final mockResponse = Response(data: '', statusCode: 204, requestOptions: RequestOptions());

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
        final mockResponse = Response(data: 'Not Found', statusCode: 404, requestOptions: RequestOptions());

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
        final mockResponse = Response(
          data: {'link': expectedLink},
          statusCode: 200,
          requestOptions: RequestOptions(),
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
        final mockResponse = Response(data: 'Not Found', statusCode: 404, requestOptions: RequestOptions());

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
