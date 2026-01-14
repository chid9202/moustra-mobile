import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/attachment_dto.dart';

void main() {
  group('AttachmentDto Tests', () {
    test('should create AttachmentDto from JSON', () {
      // Arrange
      final json = {
        'attachmentUuid': 'test-uuid',
        'fileLink': 'https://example.com/file.pdf',
        'fileName': 'test-file.pdf',
        'fileSize': 1024,
        'attachmentType': 'document',
        'createdDate': '2023-01-01T00:00:00Z',
      };

      // Act
      final attachmentDto = AttachmentDto.fromJson(json);

      // Assert
      expect(attachmentDto.attachmentUuid, 'test-uuid');
      expect(attachmentDto.fileLink, 'https://example.com/file.pdf');
      expect(attachmentDto.fileName, 'test-file.pdf');
      expect(attachmentDto.fileSize, 1024);
      expect(attachmentDto.attachmentType, 'document');
      expect(attachmentDto.createdDate, DateTime.parse('2023-01-01T00:00:00Z'));
    });

    test('should create AttachmentDto with minimal required fields', () {
      // Arrange
      final json = {
        'attachmentUuid': 'test-uuid',
      };

      // Act
      final attachmentDto = AttachmentDto.fromJson(json);

      // Assert
      expect(attachmentDto.attachmentUuid, 'test-uuid');
      expect(attachmentDto.fileLink, null);
      expect(attachmentDto.fileName, null);
      expect(attachmentDto.fileSize, null);
      expect(attachmentDto.attachmentType, null);
      expect(attachmentDto.createdDate, null);
    });

    test('should handle null optional fields in JSON', () {
      // Arrange
      final json = {
        'attachmentUuid': 'test-uuid',
        'fileLink': null,
        'fileName': null,
        'fileSize': null,
        'attachmentType': null,
        'createdDate': null,
      };

      // Act
      final attachmentDto = AttachmentDto.fromJson(json);

      // Assert
      expect(attachmentDto.attachmentUuid, 'test-uuid');
      expect(attachmentDto.fileLink, null);
      expect(attachmentDto.fileName, null);
      expect(attachmentDto.fileSize, null);
      expect(attachmentDto.attachmentType, null);
      expect(attachmentDto.createdDate, null);
    });

    test('should convert AttachmentDto to JSON', () {
      // Arrange
      final attachmentDto = AttachmentDto(
        attachmentUuid: 'test-uuid',
        fileLink: 'https://example.com/file.pdf',
        fileName: 'test-file.pdf',
        fileSize: 1024,
        attachmentType: 'document',
        createdDate: DateTime(2023, 1, 1),
      );

      // Act
      final json = attachmentDto.toJson();

      // Assert
      expect(json['attachmentUuid'], 'test-uuid');
      expect(json['fileLink'], 'https://example.com/file.pdf');
      expect(json['fileName'], 'test-file.pdf');
      expect(json['fileSize'], 1024);
      expect(json['attachmentType'], 'document');
      expect(json['createdDate'], '2023-01-01T00:00:00.000');
    });

    test('should handle null createdDate in toJson', () {
      // Arrange
      final attachmentDto = AttachmentDto(
        attachmentUuid: 'test-uuid',
        createdDate: null,
      );

      // Act
      final json = attachmentDto.toJson();

      // Assert
      expect(json['attachmentUuid'], 'test-uuid');
      expect(json['createdDate'], null);
    });

    group('fileSizeFormatted', () {
      test('should format bytes correctly', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileSize: 512);

        // Act & Assert
        expect(attachmentDto.fileSizeFormatted, '512 B');
      });

      test('should format kilobytes correctly', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileSize: 2048);

        // Act & Assert
        expect(attachmentDto.fileSizeFormatted, '2.0 KB');
      });

      test('should format megabytes correctly', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileSize: 2 * 1024 * 1024);

        // Act & Assert
        expect(attachmentDto.fileSizeFormatted, '2.0 MB');
      });

      test('should return empty string when fileSize is null', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileSize: null);

        // Act & Assert
        expect(attachmentDto.fileSizeFormatted, '');
      });
    });

    group('isImage', () {
      test('should return true for jpg files', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileName: 'image.jpg');

        // Act & Assert
        expect(attachmentDto.isImage, true);
      });

      test('should return true for jpeg files', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileName: 'image.jpeg');

        // Act & Assert
        expect(attachmentDto.isImage, true);
      });

      test('should return true for png files', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileName: 'image.png');

        // Act & Assert
        expect(attachmentDto.isImage, true);
      });

      test('should return true for gif files', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileName: 'image.gif');

        // Act & Assert
        expect(attachmentDto.isImage, true);
      });

      test('should return true for webp files', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileName: 'image.webp');

        // Act & Assert
        expect(attachmentDto.isImage, true);
      });

      test('should return true for bmp files', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileName: 'image.bmp');

        // Act & Assert
        expect(attachmentDto.isImage, true);
      });

      test('should return false for pdf files', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileName: 'document.pdf');

        // Act & Assert
        expect(attachmentDto.isImage, false);
      });

      test('should return false for txt files', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileName: 'text.txt');

        // Act & Assert
        expect(attachmentDto.isImage, false);
      });

      test('should return false when fileName is null', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileName: null);

        // Act & Assert
        expect(attachmentDto.isImage, false);
      });

      test('should handle case-insensitive extensions', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileName: 'IMAGE.JPG');

        // Act & Assert
        expect(attachmentDto.isImage, true);
      });

      test('should handle files with multiple dots', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileName: 'my.image.file.png');

        // Act & Assert
        expect(attachmentDto.isImage, true);
      });
    });

    group('displayName', () {
      test('should return fileName when available', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileName: 'test-file.pdf');

        // Act & Assert
        expect(attachmentDto.displayName, 'test-file.pdf');
      });

      test('should return "Unnamed file" when fileName is null', () {
        // Arrange
        final attachmentDto = AttachmentDto(fileName: null);

        // Act & Assert
        expect(attachmentDto.displayName, 'Unnamed file');
      });
    });
  });
}
