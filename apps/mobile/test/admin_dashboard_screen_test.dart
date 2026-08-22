import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/admin_dashboard_screen.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/models/auth_response.dart';

class FakeApiService implements ApiService {
  Map<String, dynamic>? dashboardResponse;
  Exception? throwError;

  @override
  Future<Map<String, dynamic>> getAdminDashboard() async {
    if (throwError != null) throw throwError!;
    await Future.delayed(const Duration(milliseconds: 1));
    return dashboardResponse ?? <String, dynamic>{};
  }

  @override
  String getErrorMessage(dynamic error) => 'Something went wrong';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthService extends ChangeNotifier implements AuthService {
  @override
  final ApiService apiService;

  FakeAuthService(this.apiService);

  @override
  User? get currentUser => null;

  @override
  bool get isAuthenticated => false;

  @override
  bool get isLoading => false;

  @override
  Future<bool> loadUser() async => false;

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<void> updateProfile({
    String? name,
    String? email,
    String? businessName,
    String? phone,
    String? address,
    String? currency,
  }) async {}

  @override
  Future<void> updateRole(String role) async {}
}

void main() {
  group('AdminDashboardScreen', () {
    late FakeApiService fakeApiService;
    late FakeAuthService fakeAuthService;

    setUp(() {
      fakeApiService = FakeApiService();
      fakeAuthService = FakeAuthService(fakeApiService);
    });

    testWidgets('should show loading state initially', (tester) async {
      fakeApiService.dashboardResponse = <String, dynamic>{};

      await tester.pumpWidget(
        MaterialApp(
          home: AdminDashboardScreen(authService: fakeAuthService),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should show error state when API fails', (tester) async {
      fakeApiService.throwError = Exception('API Error');

      await tester.pumpWidget(
        MaterialApp(
          home: AdminDashboardScreen(authService: fakeAuthService),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('should show dashboard metrics on success', (tester) async {
      fakeApiService.dashboardResponse = <String, dynamic>{
        'totalSellers': 10,
        'totalCustomers': 100,
        'totalProducts': 50,
        'totalOrders': 200,
        'pendingOrders': 20,
        'totalRevenue': 5000000,
        'activeUsers': 80,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: AdminDashboardScreen(authService: fakeAuthService),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('10'), findsWidgets);
      expect(find.text('100'), findsWidgets);
      expect(find.text('50'), findsWidgets);
      expect(find.text('200'), findsWidgets);
      expect(find.text('20'), findsWidgets);
      expect(find.text('80'), findsWidgets);
      expect(find.text('Platform Overview'), findsOneWidget);
    });

    testWidgets('should show empty state when no data', (tester) async {
      fakeApiService.dashboardResponse = <String, dynamic>{};

      await tester.pumpWidget(
        MaterialApp(
          home: AdminDashboardScreen(authService: fakeAuthService),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('0'), findsWidgets);
    });
  });
}
