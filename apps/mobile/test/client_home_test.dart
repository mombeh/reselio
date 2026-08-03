import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/client_home.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ClientHome', () {
    late ApiService apiService;
    late AuthService authService;

    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      apiService = ApiService(prefs);
      authService = AuthService(apiService);
    });

    testWidgets('renders client dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ClientHome(authService: authService),
        ),
      );

      expect(find.text('Client Dashboard'), findsOneWidget);
      expect(find.text('My Orders'), findsOneWidget);
      expect(find.text('Customers'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
    });
  });
}
