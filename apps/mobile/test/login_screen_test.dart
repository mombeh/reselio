import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/login_screen.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LoginScreen', () {
    late ApiService apiService;
    late AuthService authService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      apiService = ApiService(prefs);
      authService = AuthService(apiService);
    });

    testWidgets('renders login form', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(authService: authService),
        ),
      );

      expect(find.text('Reselio'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text("Don't have an account? Register"), findsOneWidget);
    });

    testWidgets('shows error when email is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(authService: authService),
        ),
      );

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error when password is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(authService: authService),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Please enter your password'), findsOneWidget);
    });
  });
}
