import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Page object for interacting with the Login screen in integration tests.
class LoginRobot {
  LoginRobot(this.tester);

  final WidgetTester tester;

  /// Finders for login screen elements.
  Finder get emailField => find.widgetWithText(TextFormField, 'Email');
  Finder get passwordField => find.widgetWithText(TextFormField, 'Password');
  Finder get signInButton => find.text('Sign In');
  Finder get welcomeText => find.text('Welcome to Moustra');
  Finder get errorIcon => find.byIcon(Icons.error_outline);
  Finder get loadingIndicator => find.byType(CircularProgressIndicator);

  /// Verifies that the login screen is displayed with key elements.
  Future<void> verifyLoginScreenDisplayed() async {
    expect(welcomeText, findsOneWidget);
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(signInButton, findsOneWidget);
  }

  /// Enters the given email into the email field.
  Future<void> enterEmail(String email) async {
    await tester.enterText(emailField, email);
    await tester.pump();
  }

  /// Enters the given password into the password field.
  Future<void> enterPassword(String password) async {
    await tester.enterText(passwordField, password);
    await tester.pump();
  }

  /// Taps the Sign In button.
  Future<void> tapSignIn() async {
    await tester.tap(signInButton);
    await tester.pump();
  }

  /// Verifies that an error message is displayed.
  Future<void> verifyErrorDisplayed() async {
    expect(errorIcon, findsOneWidget);
  }

  /// Verifies that the loading indicator is shown.
  Future<void> verifyLoading() async {
    expect(loadingIndicator, findsOneWidget);
  }
}
