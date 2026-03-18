import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/note_dto.dart';
import 'package:moustra/widgets/note/single_note.dart';
import '../../test_helpers/test_helpers.dart';

NoteDto _createTestNote({
  String? noteUuid,
  String? content,
  AccountDto? createdBy,
  DateTime? createdDate,
}) {
  return NoteDto(
    noteUuid: noteUuid ?? 'note-uuid-1',
    content: content ?? 'Test note content',
    createdDate: createdDate ?? DateTime(2025, 1, 15, 10, 30),
    createdBy: createdBy ??
        AccountDto(
          accountUuid: 'account-uuid',
          user: UserDto(firstName: 'John', lastName: 'Doe'),
        ),
  );
}

void main() {
  group('SingleNote', () {
    testWidgets('renders note content in view mode', (
      WidgetTester tester,
    ) async {
      final note = _createTestNote(content: 'My important note');

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleNote(
          note: note,
          isEditing: false,
          editingContent: '',
          onStartEdit: () {},
          onCancelEdit: () {},
          onSaveEdit: () {},
          onDelete: () {},
          onEditingContentChange: (_) {},
        ),
      );

      expect(find.text('My important note'), findsOneWidget);
    });

    testWidgets('renders creator name and date', (WidgetTester tester) async {
      final note = _createTestNote();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleNote(
          note: note,
          isEditing: false,
          editingContent: '',
          onStartEdit: () {},
          onCancelEdit: () {},
          onSaveEdit: () {},
          onDelete: () {},
          onEditingContentChange: (_) {},
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('shows initials in avatar', (WidgetTester tester) async {
      final note = _createTestNote();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleNote(
          note: note,
          isEditing: false,
          editingContent: '',
          onStartEdit: () {},
          onCancelEdit: () {},
          onSaveEdit: () {},
          onDelete: () {},
          onEditingContentChange: (_) {},
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('shows edit and delete buttons in view mode', (
      WidgetTester tester,
    ) async {
      final note = _createTestNote();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleNote(
          note: note,
          isEditing: false,
          editingContent: '',
          onStartEdit: () {},
          onCancelEdit: () {},
          onSaveEdit: () {},
          onDelete: () {},
          onEditingContentChange: (_) {},
        ),
      );

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('calls onStartEdit when edit button tapped', (
      WidgetTester tester,
    ) async {
      bool editCalled = false;
      final note = _createTestNote();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleNote(
          note: note,
          isEditing: false,
          editingContent: '',
          onStartEdit: () => editCalled = true,
          onCancelEdit: () {},
          onSaveEdit: () {},
          onDelete: () {},
          onEditingContentChange: (_) {},
        ),
      );

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pump();

      expect(editCalled, isTrue);
    });

    testWidgets('calls onDelete when delete button tapped', (
      WidgetTester tester,
    ) async {
      bool deleteCalled = false;
      final note = _createTestNote();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleNote(
          note: note,
          isEditing: false,
          editingContent: '',
          onStartEdit: () {},
          onCancelEdit: () {},
          onSaveEdit: () {},
          onDelete: () => deleteCalled = true,
          onEditingContentChange: (_) {},
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(deleteCalled, isTrue);
    });

    testWidgets('shows TextField and Cancel/Save buttons in editing mode', (
      WidgetTester tester,
    ) async {
      final note = _createTestNote(content: 'Editing this note');

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleNote(
          note: note,
          isEditing: true,
          editingContent: 'Editing this note',
          onStartEdit: () {},
          onCancelEdit: () {},
          onSaveEdit: () {},
          onDelete: () {},
          onEditingContentChange: (_) {},
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('calls onCancelEdit when Cancel button tapped in edit mode', (
      WidgetTester tester,
    ) async {
      bool cancelCalled = false;
      final note = _createTestNote();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleNote(
          note: note,
          isEditing: true,
          editingContent: 'some content',
          onStartEdit: () {},
          onCancelEdit: () => cancelCalled = true,
          onSaveEdit: () {},
          onDelete: () {},
          onEditingContentChange: (_) {},
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(cancelCalled, isTrue);
    });

    testWidgets('calls onSaveEdit when Save button tapped in edit mode', (
      WidgetTester tester,
    ) async {
      bool saveCalled = false;
      final note = _createTestNote();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleNote(
          note: note,
          isEditing: true,
          editingContent: 'updated content',
          onStartEdit: () {},
          onCancelEdit: () {},
          onSaveEdit: () => saveCalled = true,
          onDelete: () {},
          onEditingContentChange: (_) {},
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(saveCalled, isTrue);
    });

    testWidgets('renders as Card with elevation 0', (
      WidgetTester tester,
    ) async {
      final note = _createTestNote();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleNote(
          note: note,
          isEditing: false,
          editingContent: '',
          onStartEdit: () {},
          onCancelEdit: () {},
          onSaveEdit: () {},
          onDelete: () {},
          onEditingContentChange: (_) {},
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 0);
    });

    testWidgets('shows "System" when createdBy is null', (
      WidgetTester tester,
    ) async {
      final note = _createTestNote(createdBy: null);

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleNote(
          note: NoteDto(
            noteUuid: 'note-1',
            content: 'System note',
            createdDate: DateTime(2025, 1, 15),
            createdBy: null,
          ),
          isEditing: false,
          editingContent: '',
          onStartEdit: () {},
          onCancelEdit: () {},
          onSaveEdit: () {},
          onDelete: () {},
          onEditingContentChange: (_) {},
        ),
      );

      expect(find.text('System'), findsOneWidget);
      expect(find.text('SY'), findsOneWidget);
    });

    testWidgets('has bottom margin when not last', (
      WidgetTester tester,
    ) async {
      final note = _createTestNote();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleNote(
          note: note,
          isEditing: false,
          editingContent: '',
          onStartEdit: () {},
          onCancelEdit: () {},
          onSaveEdit: () {},
          onDelete: () {},
          onEditingContentChange: (_) {},
          isLast: false,
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, const EdgeInsets.only(bottom: 8));
    });

    testWidgets('has no bottom margin when last', (
      WidgetTester tester,
    ) async {
      final note = _createTestNote();

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleNote(
          note: note,
          isEditing: false,
          editingContent: '',
          onStartEdit: () {},
          onCancelEdit: () {},
          onSaveEdit: () {},
          onDelete: () {},
          onEditingContentChange: (_) {},
          isLast: true,
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, const EdgeInsets.only(bottom: 0));
    });
  });
}
