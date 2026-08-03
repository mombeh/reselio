import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/admin_home.dart';
import 'mocks/fake_auth_service.dart';

void main() {
  group('AdminHome', () {
    late FakeAuthService fakeAuthService;

    setUp(() {
      fakeAuthService = FakeAuthService();
    });

    testWidgets('renders admin dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdminHome(authService: fakeAuthService),
        ),
      );

      expect(find.text('Admin Dashboard'), findsOneWidget);
      expect(find.text('User Management'), findsOneWidget);
      expect(find.text('All Orders'), findsOneWidget);
      expect(find.text('System Settings'), findsOneWidget);
    });
  });
}
