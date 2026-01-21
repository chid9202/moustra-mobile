import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moustra/screens/signup_screen.dart';
import '../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    // Initialize dotenv - try loading .env file if it exists, otherwise use empty initialization
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // If .env file doesn't exist or can't be loaded, initialize with empty values
      // Env class will use fallback values
      dotenv.env.clear();
    }
  });

  group('SignupScreen', () {
    Future<void> setLargeScreen(WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1200, 2000);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
    }

    testWidgets('renders correctly with default state', (
      WidgetTester tester,
    ) async {
      await setLargeScreen(tester);
      await TestHelpers.pumpWidgetWithTheme(tester, const SignupScreen());
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign up to get started'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows email and password fields', (WidgetTester tester) async {
      await setLargeScreen(tester);
      await TestHelpers.pumpWidgetWithTheme(tester, const SignupScreen());
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('password visibility toggle works', (
      WidgetTester tester,
    ) async {
      await setLargeScreen(tester);
      await TestHelpers.pumpWidgetWithTheme(tester, const SignupScreen());
      await tester.pumpAndSettle();

      // Starts obscured -> shows "visibility" icon.
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      // Now un-obscured -> shows "visibility_off" icon.
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('validates email format', (WidgetTester tester) async {
      await setLargeScreen(tester);
      await TestHelpers.pumpWidgetWithTheme(tester, const SignupScreen());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(2));

      await tester.enterText(fields.first, 'invalid-email');
      await tester.enterText(fields.last, 'Password1!');
      await tester.pump();

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('accepts email with plus sign', (WidgetTester tester) async {
      await setLargeScreen(tester);
      await TestHelpers.pumpWidgetWithTheme(tester, const SignupScreen());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(2));

      await tester.enterText(fields.first, 'admin+29917@moustra.com');
      await tester.enterText(fields.last, 'Password1!');
      await tester.pump();

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsNothing);
    });

    testWidgets('validates password required', (WidgetTester tester) async {
      await setLargeScreen(tester);
      await TestHelpers.pumpWidgetWithTheme(tester, const SignupScreen());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(2));

      await tester.enterText(fields.first, 'test@test.com');
      await tester.pump();

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows password policy checkmarks when requirements met', (
      WidgetTester tester,
    ) async {
      await setLargeScreen(tester);
      await TestHelpers.pumpWidgetWithTheme(tester, const SignupScreen());
      await tester.pumpAndSettle();

      // Initially no green checkmarks.
      expect(find.byIcon(Icons.check), findsNothing);

      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(2));

      // Meets: min length, lower, upper, number, special (and >=3 character types).
      await tester.enterText(fields.last, 'Password1!');
      await tester.pumpAndSettle();

      // Expect at least the "min length" and "3 of the following" to pass, plus some of the sub-items.
      expect(find.byIcon(Icons.check), findsAtLeastNWidgets(2));
    });

    testWidgets('shows link to login', (WidgetTester tester) async {
      await setLargeScreen(tester);
      await TestHelpers.pumpWidgetWithTheme(tester, const SignupScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Already have an account'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
    });
  });
}
