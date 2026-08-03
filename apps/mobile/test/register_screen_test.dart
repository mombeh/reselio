import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/register_screen.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RegisterScreen', () {
    late ApiService apiService;
    late AuthService authService;

    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      apiService = ApiService(prefs);
      authService = AuthService(apiService);
    });

    testWidgets('renders registration form', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterScreen(authService: authService),
        ),
      );

      expect(find.text('Register'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('shows error when name is too short', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterScreen(authService: authService),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'J');
      await tester.tap(find.text('Register'));
      await tester.pump();

      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
    });

    testWidgets('shows error when passwords do not match', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterScreen(authService: authService),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'differentpassword');
      await tester.tap(find.text('Register'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
