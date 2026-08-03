import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/client_home.dart';
import 'mocks/fake_auth_service.dart';

void main() {
  group('ClientHome', () {
    late FakeAuthService fakeAuthService;

    setUp(() {
      fakeAuthService = FakeAuthService();
    });

    testWidgets('renders client dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ClientHome(authService: fakeAuthService),
        ),
      );

      expect(find.text('Client Dashboard'), findsOneWidget);
      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('Customers'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
    });
  });
}
