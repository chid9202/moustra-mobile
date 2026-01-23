import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/widgets/cages_grid_floating_bar.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/constants/cages_grid_constants.dart';
import '../test_helpers/test_helpers.dart';

void main() {
  group('CagesGridFloatingBar Widget Tests', () {
    late List<RackSimpleDto> mockRacks;
    late RackSimpleDto mockSelectedRack;

    setUp(() {
      mockRacks = [
        RackSimpleDto(
          rackId: 1,
          rackUuid: 'rack-uuid-1',
          rackName: 'Test Rack 1',
        ),
        RackSimpleDto(
          rackId: 2,
          rackUuid: 'rack-uuid-2',
          rackName: 'Test Rack 2',
        ),
      ];
      mockSelectedRack = mockRacks[0];
    });

    testWidgets(
      'search field should not have autofocus enabled in wide layout',
      (WidgetTester tester) async {
        String? lastSearchQuery;
        String? lastSearchType;

        await TestHelpers.pumpWidgetWithTheme(
          tester,
          MediaQuery(
            data: const MediaQueryData(size: Size(800, 800)),
            child: CagesGridFloatingBar(
              racks: mockRacks,
              selectedRack: mockSelectedRack,
              onRackSelected: (_) {},
              onAddRack: () {},
              onEditRack: () {},
              searchType: CagesGridConstants.searchTypeAnimalTag,
              searchQuery: '',
              onSearchTypeChanged: (value) {
                lastSearchType = value;
              },
              onSearchQueryChanged: (value) {
                lastSearchQuery = value;
              },
              zoomLevel: 1.0,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the TextField (search field)
        final textFieldFinder = find.byType(TextField);
        expect(textFieldFinder, findsOneWidget);

        // Get the TextField widget and verify autofocus is false
        final textField = tester.widget<TextField>(textFieldFinder);
        expect(
          textField.autofocus,
          isFalse,
          reason: 'Search field should not auto-focus on load',
        );
      },
    );

    testWidgets(
      'search field should not have autofocus when widget is rebuilt',
      (WidgetTester tester) async {
        String lastSearchQuery = '';
        String lastSearchType = CagesGridConstants.searchTypeAnimalTag;

        await TestHelpers.pumpWidgetWithTheme(
          tester,
          MediaQuery(
            data: const MediaQueryData(size: Size(800, 800)),
            child: CagesGridFloatingBar(
              racks: mockRacks,
              selectedRack: mockSelectedRack,
              onRackSelected: (_) {},
              onAddRack: () {},
              onEditRack: () {},
              searchType: lastSearchType,
              searchQuery: lastSearchQuery,
              onSearchTypeChanged: (value) {
                lastSearchType = value;
              },
              onSearchQueryChanged: (value) {
                lastSearchQuery = value;
              },
              zoomLevel: 1.0,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify autofocus is false on initial load
        final textFieldFinder = find.byType(TextField);
        final textField = tester.widget<TextField>(textFieldFinder);
        expect(textField.autofocus, isFalse);

        // Update the widget with new search query
        await tester.pumpWidget(
          TestHelpers.createTestApp(
            child: MediaQuery(
              data: const MediaQueryData(size: Size(800, 800)),
              child: CagesGridFloatingBar(
                racks: mockRacks,
                selectedRack: mockSelectedRack,
                onRackSelected: (_) {},
                onAddRack: () {},
                onEditRack: () {},
                searchType: lastSearchType,
                searchQuery: 'test query',
                onSearchTypeChanged: (value) {
                  lastSearchType = value;
                },
                onSearchQueryChanged: (value) {
                  lastSearchQuery = value;
                },
                zoomLevel: 1.0,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify autofocus is still false after rebuild
        final updatedTextField = tester.widget<TextField>(textFieldFinder);
        expect(
          updatedTextField.autofocus,
          isFalse,
          reason: 'Search field should not auto-focus after widget rebuild',
        );
      },
    );
  });
}
