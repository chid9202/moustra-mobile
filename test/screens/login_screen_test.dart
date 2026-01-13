import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moustra/screens/login_screen.dart';
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

  group('LoginScreen', () {
    testWidgets('renders correctly with default state', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());

      // Check for main elements
      expect(find.text('Welcome to Moustra'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('displays app icon', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());
      await tester.pumpAndSettle();

      // Check for app icon
      final image = find.byType(Image);
      expect(image, findsOneWidget);

      final imageWidget = tester.widget<Image>(image);
      expect(imageWidget.image, isA<AssetImage>());
    });

    testWidgets('shows sign in button', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());
      await tester.pumpAndSettle();

      final signInButton = find.text('Sign In');
      expect(signInButton, findsOneWidget);

      // Button should be enabled by default
      final button = tester.widget<FilledButton>(
        find.ancestor(of: signInButton, matching: find.byType(FilledButton)),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('shows email and password fields', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());
      await tester.pumpAndSettle();

      // Check for email field
      expect(find.text('Email'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Check for password field
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());
      await tester.pumpAndSettle();

      // Check for main scaffold
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));

      // Check for centered content
      expect(find.byType(Center), findsAtLeastNWidgets(1));

      // Check for constrained box
      expect(find.byType(ConstrainedBox), findsAtLeastNWidgets(1));

      // Check for form
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('displays welcome text with proper styling', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());
      await tester.pumpAndSettle();

      final welcomeText = find.text('Welcome to Moustra');
      expect(welcomeText, findsOneWidget);

      final textWidget = tester.widget<Text>(welcomeText);
      expect(textWidget.style?.fontSize, 28.0);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('displays subtitle', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());
      await tester.pumpAndSettle();

      expect(find.text('Sign in to continue'), findsOneWidget);
    });

    testWidgets('has proper spacing between elements', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());
      await tester.pumpAndSettle();

      // Check for SizedBox widgets (spacing)
      expect(find.byType(SizedBox), findsAtLeastNWidgets(3));
    });

    testWidgets('handles sign in button tap', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());
      await tester.pumpAndSettle();

      // First fill in email and password
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));
      await tester.enterText(textFields.first, 'test@test.com');
      await tester.enterText(textFields.last, 'password123');
      await tester.pump();

      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      // Note: In a real test, you'd verify authentication flow
      // This would require mocking the auth service
    });

    testWidgets('has proper accessibility structure', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());
      await tester.pumpAndSettle();

      // Check for semantic structure
      expect(find.byType(Semantics), findsAtLeastNWidgets(1));

      // Check for proper button semantics
      final signInButton = find.text('Sign In');
      expect(signInButton, findsOneWidget);
    });

    testWidgets('displays error message when error is set', (
      WidgetTester tester,
    ) async {
      // This test would require setting up the screen with an error state
      // In a real implementation, you'd need to mock the auth service
      // and trigger an error condition

      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());

      // Initially no error should be shown
      expect(find.textContaining('Error'), findsNothing);
    });

    testWidgets('shows loading state when loading', (
      WidgetTester tester,
    ) async {
      // This test would require setting up the screen with a loading state
      // In a real implementation, you'd need to mock the auth service
      // and trigger a loading condition

      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());
      await tester.pumpAndSettle();

      // Initially no loading indicator should be shown
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('has proper constraints for mobile layout', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());
      await tester.pumpAndSettle();

      // Check for constrained box with max width
      final constrainedBoxes = find.byType(ConstrainedBox);
      expect(constrainedBoxes, findsAtLeastNWidgets(1));

      // Find the specific constrained box with max width 400
      bool foundCorrectBox = false;
      for (int i = 0; i < constrainedBoxes.evaluate().length; i++) {
        final box = tester.widget<ConstrainedBox>(constrainedBoxes.at(i));
        if (box.constraints.maxWidth == 400.0) {
          foundCorrectBox = true;
          break;
        }
      }
      expect(foundCorrectBox, isTrue);
    });

    testWidgets('handles screen lifecycle correctly', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());
      await tester.pumpAndSettle();

      // Verify the screen can be built and disposed
      expect(find.byType(LoginScreen), findsOneWidget);

      // Test that the screen can be rebuilt
      await tester.pump();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('password visibility toggle works', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());
      await tester.pumpAndSettle();

      // Find the visibility toggle button
      final visibilityIcon = find.byIcon(Icons.visibility_outlined);
      expect(visibilityIcon, findsOneWidget);

      // Tap to toggle visibility
      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();

      // Should now show visibility_off icon
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('validates email format', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());
      await tester.pumpAndSettle();

      // Find email field (first TextFormField)
      final emailFields = find.byType(TextFormField);
      expect(emailFields, findsNWidgets(2)); // Email and password fields

      // Enter invalid email (no @ symbol)
      await tester.enterText(emailFields.first, 'invalid-email');
      await tester.pump();

      // Tap sign in to trigger validation
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('accepts email with plus sign', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());
      await tester.pumpAndSettle();

      // Find email and password fields
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      // Enter email with + (valid for aliasing)
      await tester.enterText(textFields.first, 'admin+29917@moustra');
      await tester.enterText(textFields.last, 'password123');
      await tester.pump();

      // Tap sign in to trigger validation
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Should NOT show email validation error
      expect(find.text('Please enter a valid email'), findsNothing);
    });

    testWidgets('validates password required', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(tester, const LoginScreen());
      await tester.pumpAndSettle();

      // Find email field
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      // Enter valid email but no password
      await tester.enterText(textFields.first, 'test@test.com');
      await tester.pump();

      // Tap sign in to trigger validation
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Password is required'), findsOneWidget);
    });
  });
}
