import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/colony_wizard/colony_wizard_screen.dart';
import 'package:moustra/screens/colony_wizard/state/wizard_state.dart';
import 'package:moustra/screens/colony_wizard/widgets/wizard_stepper.dart';

import '../../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    installNoOpDioApiClient();
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      dotenv.loadFromString(envString: '', isOptional: true);
    }
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  setUp(() {
    // Reset the global wizard state before each test
    wizardState.reset();
  });

  group('ColonyWizardScreen', () {
    testWidgets('renders with title and progress', (tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(child: const ColonyWizardScreen()),
      );
      await tester.pump();

      expect(find.text('Colony Setup Wizard'), findsOneWidget);
      expect(find.text('0% Complete'), findsOneWidget);
    });

    testWidgets('shows close button', (tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(child: const ColonyWizardScreen()),
      );
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows WizardStepper', (tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(child: const ColonyWizardScreen()),
      );
      await tester.pump();

      expect(find.byType(WizardStepper), findsOneWidget);
    });

    testWidgets('shows LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(child: const ColonyWizardScreen()),
      );
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('does not show bottom bar on step 0', (tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(child: const ColonyWizardScreen()),
      );
      await tester.pump();

      // Step 0 hides back/next navigation
      expect(find.text('Back'), findsNothing);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('contains a PageView', (tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(child: const ColonyWizardScreen()),
      );
      await tester.pump();

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('renders Scaffold as root widget', (tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(child: const ColonyWizardScreen()),
      );
      await tester.pump();

      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('has SafeArea', (tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(child: const ColonyWizardScreen()),
      );
      await tester.pump();

      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
