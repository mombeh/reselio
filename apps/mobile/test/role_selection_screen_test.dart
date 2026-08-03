import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/role_selection_screen.dart';
import 'mocks/fake_auth_service.dart';

void main() {
  group('RoleSelectionScreen', () {
    late FakeAuthService fakeAuthService;

    setUp(() {
      fakeAuthService = FakeAuthService();
    });

    testWidgets('renders role selection options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RoleSelectionScreen(authService: fakeAuthService),
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
          home: RoleSelectionScreen(authService: fakeAuthService),
        ),
      );

      expect(find.text('Browse and purchase products'), findsOneWidget);
    });

    testWidgets('shows client subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RoleSelectionScreen(authService: fakeAuthService),
        ),
      );

      expect(find.text('Manage orders and customers'), findsOneWidget);
    });

    testWidgets('shows admin subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RoleSelectionScreen(authService: fakeAuthService),
        ),
      );

      expect(find.text('Full system access and management'), findsOneWidget);
    });
  });
}
