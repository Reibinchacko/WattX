// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:energy_monitor/main.dart';

void main() {
  testWidgets('Login screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EnergyMonitorApp());

    // Verify login screen elements are present
    expect(find.text('ENERGY MONITOR'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Enter your credentials to access your dashboard'),
        findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });

  testWidgets('Login button starts disabled', (WidgetTester tester) async {
    await tester.pumpWidget(const EnergyMonitorApp());

    // Find the Log In button
    final loginButton = find.widgetWithText(ElevatedButton, 'Log In');
    expect(loginButton, findsOneWidget);

    // Verify button is disabled (onPressed is null)
    final button = tester.widget<ElevatedButton>(loginButton);
    expect(button.onPressed, isNull);
  });

  testWidgets('Login button enables when both fields are filled',
      (WidgetTester tester) async {
    await tester.pumpWidget(const EnergyMonitorApp());

    // Find input fields
    final emailField = find.widgetWithText(TextField, 'hello@example.com');
    final passwordField = find.widgetWithText(TextField, 'Enter your password');

    // Initially button should be disabled
    var loginButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Log In'),
    );
    expect(loginButton.onPressed, isNull);

    // Enter email
    await tester.enterText(emailField, 'test@example.com');
    await tester.pump();

    // Button should still be disabled (password empty)
    loginButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Log In'),
    );
    expect(loginButton.onPressed, isNull);

    // Enter password
    await tester.enterText(passwordField, 'password123');
    await tester.pump();

    // Button should now be enabled
    loginButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Log In'),
    );
    expect(loginButton.onPressed, isNotNull);
  });

  testWidgets('Password visibility toggle works', (WidgetTester tester) async {
    await tester.pumpWidget(const EnergyMonitorApp());

    // Find password field
    final passwordField = find.widgetWithText(TextField, 'Enter your password');
    expect(passwordField, findsOneWidget);

    // Find the visibility toggle button
    final visibilityButton = find.descendant(
      of: passwordField,
      matching: find.byType(IconButton),
    );
    expect(visibilityButton, findsOneWidget);

    // Verify password field is obscured initially
    var textField = tester.widget<TextField>(passwordField);
    expect(textField.obscureText, true);

    // Tap visibility toggle
    await tester.tap(visibilityButton);
    await tester.pump();

    // Verify password is now visible
    textField = tester.widget<TextField>(passwordField);
    expect(textField.obscureText, false);
  });
}
