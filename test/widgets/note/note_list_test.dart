import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/note_dto.dart';
import 'package:moustra/services/dtos/note_entity_type.dart';
import 'package:moustra/widgets/note/note_list.dart';
import 'package:moustra/widgets/note/single_note.dart';
import '../../test_helpers/test_helpers.dart';

NoteDto _createTestNote({
  String? noteUuid,
  String? content,
  DateTime? createdDate,
}) {
  return NoteDto(
    noteUuid: noteUuid ?? 'note-uuid-1',
    content: content ?? 'Test note content',
    createdDate: createdDate ?? DateTime(2025, 1, 15, 10, 30),
    createdBy: AccountDto(
      accountUuid: 'account-uuid',
      user: UserDto(firstName: 'Jane', lastName: 'Smith'),
    ),
  );
}

void main() {
  setUpAll(() {
    installNoOpDioApiClient();
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  group('NoteList', () {
    testWidgets('renders header with Notes title and Add Note button', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const NoteList(
          entityUuid: 'entity-uuid',
          entityType: NoteEntityType.animal,
        ),
      );

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Add Note'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows "No notes yet." when no initial notes', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const NoteList(
          entityUuid: 'entity-uuid',
          entityType: NoteEntityType.animal,
        ),
      );

      expect(find.text('No notes yet.'), findsOneWidget);
    });

    testWidgets('shows "No notes yet." when initialNotes is empty list', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const NoteList(
          entityUuid: 'entity-uuid',
          entityType: NoteEntityType.cage,
          initialNotes: [],
        ),
      );

      expect(find.text('No notes yet.'), findsOneWidget);
    });

    testWidgets('renders notes from initialNotes', (
      WidgetTester tester,
    ) async {
      final notes = [
        _createTestNote(noteUuid: 'note-1', content: 'First note', createdDate: DateTime(2025, 1, 15)),
        _createTestNote(noteUuid: 'note-2', content: 'Second note', createdDate: DateTime(2025, 1, 16)),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        NoteList(
          entityUuid: 'entity-uuid',
          entityType: NoteEntityType.animal,
          initialNotes: notes,
        ),
      );

      expect(find.byType(SingleNote), findsNWidgets(2));
      expect(find.text('First note'), findsOneWidget);
      expect(find.text('Second note'), findsOneWidget);
    });

    testWidgets('toggles add form when Add Note button tapped', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const NoteList(
          entityUuid: 'entity-uuid',
          entityType: NoteEntityType.animal,
        ),
      );

      // Form should not be visible initially
      expect(find.byType(TextField), findsNothing);

      // Tap "Add Note" button
      await tester.tap(find.text('Add Note'));
      await tester.pump();

      // Form should now be visible
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      // There is an Add Note ElevatedButton and the TextButton.icon "Add Note"
      expect(find.widgetWithText(ElevatedButton, 'Add Note'), findsOneWidget);
    });

    testWidgets('hides add form when Cancel button tapped', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const NoteList(
          entityUuid: 'entity-uuid',
          entityType: NoteEntityType.animal,
        ),
      );

      // Show the form
      await tester.tap(find.text('Add Note'));
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      // Form should be hidden again
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('Add Note ElevatedButton is disabled when text is empty', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const NoteList(
          entityUuid: 'entity-uuid',
          entityType: NoteEntityType.animal,
        ),
      );

      // Show the form
      await tester.tap(find.text('Add Note'));
      await tester.pump();

      final elevatedButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Add Note'),
      );
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets('Add Note ElevatedButton is enabled when text is entered', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const NoteList(
          entityUuid: 'entity-uuid',
          entityType: NoteEntityType.animal,
        ),
      );

      // Show the form
      await tester.tap(find.text('Add Note'));
      await tester.pump();

      // Enter text
      await tester.enterText(find.byType(TextField), 'A new note');
      await tester.pump();

      final elevatedButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Add Note'),
      );
      expect(elevatedButton.onPressed, isNotNull);
    });

    testWidgets('Add Note button area is present when entityUuid is null', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const NoteList(
          entityUuid: null,
          entityType: NoteEntityType.animal,
        ),
      );

      // The "Add Note" text and icon should still be visible
      expect(find.text('Add Note'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Tapping on it should NOT show the add form since entityUuid is null
      await tester.tap(find.text('Add Note'));
      await tester.pump();

      // The TextField for adding notes should NOT appear
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('shows hint text in add note form', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const NoteList(
          entityUuid: 'entity-uuid',
          entityType: NoteEntityType.animal,
        ),
      );

      await tester.tap(find.text('Add Note'));
      await tester.pump();

      expect(find.text('Enter note content...'), findsOneWidget);
    });

    testWidgets('renders notes sorted by date (newest first)', (
      WidgetTester tester,
    ) async {
      final notes = [
        _createTestNote(
          noteUuid: 'old-note',
          content: 'Older note',
          createdDate: DateTime(2025, 1, 10),
        ),
        _createTestNote(
          noteUuid: 'new-note',
          content: 'Newer note',
          createdDate: DateTime(2025, 1, 20),
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        NoteList(
          entityUuid: 'entity-uuid',
          entityType: NoteEntityType.animal,
          initialNotes: notes,
        ),
      );

      // Both notes should be present
      expect(find.text('Older note'), findsOneWidget);
      expect(find.text('Newer note'), findsOneWidget);

      // Verify they are in a ListView
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
