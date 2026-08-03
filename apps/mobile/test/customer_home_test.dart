import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/customer_home.dart';
import 'mocks/fake_auth_service.dart';

void main() {
  group('CustomerHome', () {
    late FakeAuthService fakeAuthService;

    setUp(() {
      fakeAuthService = FakeAuthService();
    });

    testWidgets('renders customer dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomerHome(authService: fakeAuthService),
        ),
      );

      expect(find.text('Customer Dashboard'), findsOneWidget);
      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('Browse Products'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
    });
  });
}
