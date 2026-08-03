import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/profile_screen.dart';
import 'mocks/fake_auth_service.dart';

void main() {
  group('ProfileScreen', () {
    late FakeAuthService fakeAuthService;

    setUp(() {
      fakeAuthService = FakeAuthService();
    });

    testWidgets('renders profile with default values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(authService: fakeAuthService),
        ),
      );

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('User'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Role'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });
  });
}
