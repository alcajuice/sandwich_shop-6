import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/main.dart';
import 'package:sandwich_shop/models/auth.dart';

void main() {
  setUp(() {
    // Ensure a clean auth state before each test
    Auth.instance.logout();
  });

  testWidgets('login flow updates AppBar label', (WidgetTester tester) async {
    // Start the full app so AppBar and navigation are present
    await tester.pumpWidget(const App());

    // AppBar should show the Login button initially
    expect(find.text('Login'), findsOneWidget);

    // Tap the Login button in the AppBar
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // We should be on the LoginScreen: two TextFields (username, password)
    final usernameField = find.byType(TextField).at(0);
    final passwordField = find.byType(TextField).at(1);
    expect(usernameField, findsOneWidget);
    expect(passwordField, findsOneWidget);

    // Enter credentials
    await tester.enterText(usernameField, 'alice');
    await tester.enterText(passwordField, 'secret');

    // Tap the Login button on the LoginScreen
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));

    // Let async login simulation run and navigation complete
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Auth should be logged in and AppBar should show the username
    expect(Auth.instance.isLoggedIn, isTrue);
    expect(Auth.instance.username, equals('alice'));
    expect(find.text('alice'), findsOneWidget);
  });
}
