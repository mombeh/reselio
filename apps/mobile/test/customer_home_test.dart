import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/customer_home.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CustomerHome', () {
    late ApiService apiService;
    late AuthService authService;

    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      apiService = ApiService(prefs);
      authService = AuthService(apiService);
    });

    testWidgets('renders customer dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomerHome(authService: authService),
        ),
      );

      expect(find.text('Customer Dashboard'), findsOneWidget);
      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('Browse Products'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
    });
  });
}
