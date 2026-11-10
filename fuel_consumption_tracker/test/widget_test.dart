import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fuel_consumption_tracker/main.dart';
import 'package:fuel_consumption_tracker/providers/fuel_provider.dart';
import 'package:fuel_consumption_tracker/providers/profile_provider.dart';
import 'package:fuel_consumption_tracker/screens/login_screen.dart';

void main() {
  testWidgets('App loads and shows login when not signed in',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final profileProvider = ProfileProvider();

    await tester.pumpWidget(
      MyApp(
        initialDarkMode: false,
        fuelProvider: FuelProvider(),
        profileProvider: profileProvider,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Login form blocks submission when fields are empty',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final profileProvider = ProfileProvider();

    await tester.pumpWidget(
      MyApp(
        initialDarkMode: false,
        fuelProvider: FuelProvider(),
        profileProvider: profileProvider,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);

    final signInButton = find.widgetWithText(FilledButton, 'Sign In');
    await tester.ensureVisible(signInButton);
    await tester.pumpAndSettle();
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    expect(find.text('Enter your email'), findsWidgets);
    expect(find.text('Enter your password'), findsWidgets);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(profileProvider.isLoggedIn, isFalse);
  });
}