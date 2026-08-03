import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/role_selection_screen.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RoleSelectionScreen', () {
    late ApiService apiService;
    late AuthService authService;

    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      apiService = ApiService(prefs);
      authService = AuthService(apiService);
    });

    testWidgets('renders role selection options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RoleSelectionScreen(authService: authService),
        ),
      );

      expect(find.text('Select Your Role'), findsOneWidget);
      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('Client'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });

    testWidgets('shows customer subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RoleSelectionScreen(authService: authService),
        ),
      );

      expect(find.text('Browse and purchase products'), findsOneWidget);
    });

    testWidgets('shows client subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RoleSelectionScreen(authService: authService),
        ),
      );

      expect(find.text('Manage orders and customers'), findsOneWidget);
    });

    testWidgets('shows admin subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RoleSelectionScreen(authService: authService),
        ),
      );

      expect(find.text('Full system access and management'), findsOneWidget);
    });
  });
}
