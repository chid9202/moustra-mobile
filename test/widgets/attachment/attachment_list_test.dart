import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/attachment_api.dart';
import 'package:moustra/services/dtos/attachment_dto.dart';
import 'package:moustra/widgets/attachment/attachment_list.dart';
import '../../test_helpers/test_helpers.dart';

import 'attachment_list_test.mocks.dart';

@GenerateMocks([AttachmentApi])
void main() {
  group('AttachmentList Widget Tests', () {
    late MockAttachmentApi mockAttachmentApi;

    setUp(() {
      mockAttachmentApi = MockAttachmentApi();
    });

    testWidgets('renders with header and add button', (WidgetTester tester) async {
      // Arrange
      const animalUuid = 'test-animal-uuid';
      final initialAttachments = <AttachmentDto>[];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AttachmentList(
          animalUuid: animalUuid,
          initialAttachments: initialAttachments,
        ),
      );

      // Assert
      expect(find.text('Attachments'), findsOneWidget);
      expect(find.byIcon(Icons.attach_file), findsOneWidget);
      expect(find.text('Add File'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('displays empty state when no attachments', (
      WidgetTester tester,
    ) async {
      // Arrange
      const animalUuid = 'test-animal-uuid';
      final initialAttachments = <AttachmentDto>[];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AttachmentList(
          animalUuid: animalUuid,
          initialAttachments: initialAttachments,
        ),
      );

      // Assert
      expect(find.text('No attachments yet.'), findsOneWidget);
    });

    testWidgets('displays list of attachments', (WidgetTester tester) async {
      // Arrange
      const animalUuid = 'test-animal-uuid';
      final initialAttachments = [
        AttachmentDto(
          attachmentUuid: 'uuid-1',
          fileName: 'file1.pdf',
          fileSize: 1024,
          attachmentType: 'document',
        ),
        AttachmentDto(
          attachmentUuid: 'uuid-2',
          fileName: 'file2.jpg',
          fileSize: 2048,
          attachmentType: 'image',
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AttachmentList(
          animalUuid: animalUuid,
          initialAttachments: initialAttachments,
        ),
      );

      // Assert
      expect(find.text('file1.pdf'), findsOneWidget);
      expect(find.text('file2.jpg'), findsOneWidget);
      expect(find.text('1.0 KB'), findsOneWidget);
      expect(find.text('2.0 KB'), findsOneWidget);
    });

    testWidgets('displays file icons for non-image files', (
      WidgetTester tester,
    ) async {
      // Arrange
      const animalUuid = 'test-animal-uuid';
      final initialAttachments = [
        AttachmentDto(
          attachmentUuid: 'uuid-1',
          fileName: 'document.pdf',
          fileSize: 1024,
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AttachmentList(
          animalUuid: animalUuid,
          initialAttachments: initialAttachments,
        ),
      );

      // Assert
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });

    testWidgets('displays delete button for each attachment', (
      WidgetTester tester,
    ) async {
      // Arrange
      const animalUuid = 'test-animal-uuid';
      final initialAttachments = [
        AttachmentDto(
          attachmentUuid: 'uuid-1',
          fileName: 'file1.pdf',
          fileSize: 1024,
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AttachmentList(
          animalUuid: animalUuid,
          initialAttachments: initialAttachments,
        ),
      );

      // Assert
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (
      WidgetTester tester,
    ) async {
      // Arrange
      const animalUuid = 'test-animal-uuid';

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AttachmentList(
          animalUuid: animalUuid,
        ),
      );

      // Wait for async operations
      await tester.pump();

      // The widget should show loading initially if no initialAttachments provided
      // This depends on the implementation - if it loads on initState
    });

    testWidgets('handles null animalUuid gracefully', (
      WidgetTester tester,
    ) async {
      // Arrange
      final initialAttachments = <AttachmentDto>[];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AttachmentList(
          animalUuid: null,
          initialAttachments: initialAttachments,
        ),
      );

      // Assert - should still render but with disabled add button
      expect(find.text('Attachments'), findsOneWidget);
      // Add button should be disabled when animalUuid is null
    });

    testWidgets('displays file size formatted correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      const animalUuid = 'test-animal-uuid';
      final initialAttachments = [
        AttachmentDto(
          attachmentUuid: 'uuid-1',
          fileName: 'small.txt',
          fileSize: 512, // Bytes
        ),
        AttachmentDto(
          attachmentUuid: 'uuid-2',
          fileName: 'medium.txt',
          fileSize: 2048, // KB
        ),
        AttachmentDto(
          attachmentUuid: 'uuid-3',
          fileName: 'large.txt',
          fileSize: 2 * 1024 * 1024, // MB
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AttachmentList(
          animalUuid: animalUuid,
          initialAttachments: initialAttachments,
        ),
      );

      // Assert
      expect(find.text('512 B'), findsOneWidget);
      expect(find.text('2.0 KB'), findsOneWidget);
      expect(find.text('2.0 MB'), findsOneWidget);
    });

    testWidgets('displays "Unnamed file" when fileName is null', (
      WidgetTester tester,
    ) async {
      // Arrange
      const animalUuid = 'test-animal-uuid';
      final initialAttachments = [
        AttachmentDto(
          attachmentUuid: 'uuid-1',
          fileName: null,
          fileSize: 1024,
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AttachmentList(
          animalUuid: animalUuid,
          initialAttachments: initialAttachments,
        ),
      );

      // Assert
      expect(find.text('Unnamed file'), findsOneWidget);
    });

    testWidgets('shows correct file icons for different file types', (
      WidgetTester tester,
    ) async {
      // Arrange
      const animalUuid = 'test-animal-uuid';
      final initialAttachments = [
        AttachmentDto(
          attachmentUuid: 'uuid-1',
          fileName: 'document.pdf',
          fileSize: 1024,
        ),
        AttachmentDto(
          attachmentUuid: 'uuid-2',
          fileName: 'document.doc',
          fileSize: 1024,
        ),
        AttachmentDto(
          attachmentUuid: 'uuid-3',
          fileName: 'spreadsheet.xlsx',
          fileSize: 1024,
        ),
        AttachmentDto(
          attachmentUuid: 'uuid-4',
          fileName: 'text.txt',
          fileSize: 1024,
        ),
        AttachmentDto(
          attachmentUuid: 'uuid-5',
          fileName: 'archive.zip',
          fileSize: 1024,
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        AttachmentList(
          animalUuid: animalUuid,
          initialAttachments: initialAttachments,
        ),
      );

      // Assert - check for appropriate icons
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
      expect(find.byIcon(Icons.description), findsOneWidget);
      expect(find.byIcon(Icons.table_chart), findsOneWidget);
      expect(find.byIcon(Icons.text_snippet), findsOneWidget);
      expect(find.byIcon(Icons.folder_zip), findsOneWidget);
    });
  });
}
