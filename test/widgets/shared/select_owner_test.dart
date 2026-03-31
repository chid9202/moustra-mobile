import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/stores/account_store.dart';
import 'package:moustra/widgets/shared/select_owner.dart';
import '../../test_helpers/test_helpers.dart';
import '../../test_helpers/mock_data.dart';

void main() {
  setUpAll(() {
    installNoOpDioApiClient();
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  setUp(() {
    // Pre-populate the account store so _loadAccounts() finds data
    // and doesn't make an API call
    accountStore.value = MockDataFactory.createAccountStoreDtoList(3);
  });

  tearDown(() {
    accountStore.value = null;
  });

  group('SelectOwner', () {
    testWidgets('renders with Owner label', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectOwner(selectedOwner: null, onChanged: (owner) {}),
      );

      expect(find.text('Owner'), findsOneWidget);
    });

    testWidgets('renders as DropdownButtonFormField', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectOwner(selectedOwner: null, onChanged: (owner) {}),
      );

      expect(
        find.byType(DropdownButtonFormField<AccountStoreDto>),
        findsOneWidget,
      );
    });

    testWidgets('renders with OutlineInputBorder decoration', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectOwner(selectedOwner: null, onChanged: (owner) {}),
      );

      expect(find.byType(SelectOwner), findsOneWidget);
    });

    testWidgets('shows dropdown items from account store', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectOwner(selectedOwner: null, onChanged: (owner) {}),
      );

      // Wait for accounts to load
      await tester.pump();

      // Tap to open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<AccountStoreDto>));
      await tester.pumpAndSettle();

      // Should show account names
      expect(find.text('Test User 1'), findsWidgets);
      expect(find.text('Test User 2'), findsWidgets);
      expect(find.text('Test User 3'), findsWidgets);
    });

    testWidgets('calls onChanged when a value is selected', (
      WidgetTester tester,
    ) async {
      AccountStoreDto? selectedOwner;

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SelectOwner(
          selectedOwner: null,
          onChanged: (owner) => selectedOwner = owner,
        ),
      );

      await tester.pump();

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<AccountStoreDto>));
      await tester.pumpAndSettle();

      // Select the first option
      await tester.tap(find.text('Test User 1').last);
      await tester.pumpAndSettle();

      expect(selectedOwner, isNotNull);
    });
  });
}
