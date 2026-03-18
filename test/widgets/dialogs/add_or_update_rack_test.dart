import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/setting_dto.dart';
import 'package:moustra/stores/setting_store.dart';
import 'package:moustra/widgets/dialogs/add_or_update_rack.dart';
import '../../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    installNoOpDioApiClient();
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  setUp(() {
    // Pre-populate settingStore so _loadDefaults doesn't trigger an API call
    settingStore.value = SettingDto(
      accountSetting: AccountSettingDto(
        enableDailyReport: false,
        onboardingTour: false,
        animalCreationTour: false,
        useComment: true,
        enableCustomWeanDate: true,
      ),
      labSetting: LabSettingStoreDto(
        defaultRackWidth: 8,
        defaultRackHeight: 10,
        defaultWeanDate: 21,
        useEid: false,
      ),
    );
  });

  tearDown(() {
    settingStore.value = null;
  });

  group('AddOrUpdateRackDialog - Add Mode', () {
    testWidgets('renders with "Add Rack" title for new rack', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithDialog(
        tester,
        const AddOrUpdateRackDialog(),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Add Rack'), findsOneWidget);
    });

    testWidgets('shows Create button for new rack', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithDialog(
        tester,
        const AddOrUpdateRackDialog(),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('shows Cancel button', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithDialog(
        tester,
        const AddOrUpdateRackDialog(),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('shows form fields after loading defaults', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithDialog(
        tester,
        const AddOrUpdateRackDialog(),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Rack Name'), findsOneWidget);
      expect(find.text('Rack Width'), findsOneWidget);
      expect(find.text('Rack Height'), findsOneWidget);
    });

    testWidgets('closes dialog when Cancel is tapped', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithDialog(
        tester,
        const AddOrUpdateRackDialog(),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('validates empty rack name', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithDialog(
        tester,
        const AddOrUpdateRackDialog(),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Tap Create without filling name
      await tester.tap(find.text('Create'));
      await tester.pump();

      expect(find.text('Please enter a rack name'), findsOneWidget);
    });
  });

  group('AddOrUpdateRackDialog - Edit Mode', () {
    testWidgets('renders with "Edit Rack" title for existing rack', (
      WidgetTester tester,
    ) async {
      final rackData = RackDto(
        rackUuid: 'rack-uuid',
        rackName: 'My Rack',
        rackWidth: 5,
        rackHeight: 4,
      );

      await TestHelpers.pumpWidgetWithDialog(
        tester,
        AddOrUpdateRackDialog(rackData: rackData),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Rack'), findsOneWidget);
    });

    testWidgets('shows Update button for existing rack', (
      WidgetTester tester,
    ) async {
      final rackData = RackDto(
        rackUuid: 'rack-uuid',
        rackName: 'My Rack',
        rackWidth: 5,
        rackHeight: 4,
      );

      await TestHelpers.pumpWidgetWithDialog(
        tester,
        AddOrUpdateRackDialog(rackData: rackData),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Update'), findsOneWidget);
    });

    testWidgets('pre-fills form fields with rack data', (
      WidgetTester tester,
    ) async {
      final rackData = RackDto(
        rackUuid: 'rack-uuid',
        rackName: 'My Rack',
        rackWidth: 8,
        rackHeight: 10,
      );

      await TestHelpers.pumpWidgetWithDialog(
        tester,
        AddOrUpdateRackDialog(rackData: rackData),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('My Rack'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('validates rack width must be at least 1', (
      WidgetTester tester,
    ) async {
      final rackData = RackDto(
        rackUuid: 'rack-uuid',
        rackName: 'My Rack',
        rackWidth: 5,
        rackHeight: 4,
      );

      await TestHelpers.pumpWidgetWithDialog(
        tester,
        AddOrUpdateRackDialog(rackData: rackData),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      final widthField = find.byType(TextFormField).at(1);
      await tester.enterText(widthField, '0');
      await tester.pump();

      await tester.tap(find.text('Update'));
      await tester.pump();

      expect(find.text('Width must be at least 1'), findsOneWidget);
    });

    testWidgets('validates rack height must be at least 1', (
      WidgetTester tester,
    ) async {
      final rackData = RackDto(
        rackUuid: 'rack-uuid',
        rackName: 'My Rack',
        rackWidth: 5,
        rackHeight: 4,
      );

      await TestHelpers.pumpWidgetWithDialog(
        tester,
        AddOrUpdateRackDialog(rackData: rackData),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      final heightField = find.byType(TextFormField).at(2);
      await tester.enterText(heightField, '0');
      await tester.pump();

      await tester.tap(find.text('Update'));
      await tester.pump();

      expect(find.text('Height must be at least 1'), findsOneWidget);
    });
  });
}
