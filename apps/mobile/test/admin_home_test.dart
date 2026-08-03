import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/admin_home.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AdminHome', () {
    late ApiService apiService;
    late AuthService authService;

    setUp(() async {
      final prefs = await SharedPreferences.getInstance();
      apiService = ApiService(prefs);
      authService = AuthService(apiService);
    });

    testWidgets('renders admin dashboard', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdminHome(authService: authService),
        ),
      );

      expect(find.text('Admin Dashboard'), findsOneWidget);
      expect(find.text('User Management'), findsOneWidget);
      expect(find.text('All Orders'), findsOneWidget);
      expect(find.text('System Settings'), findsOneWidget);
    });
  });
}
