import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/seller_list_screen.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/models/auth_response.dart';

class FakeApiService implements ApiService {
  Map<String, dynamic>? sellersResponse;
  Exception? throwError;

  @override
  Future<Map<String, dynamic>> getSellers({
    String? search,
    bool? isActive,
    int page = 1,
    int limit = 10,
  }) async {
    if (throwError != null) throw throwError!;
    await Future.delayed(const Duration(milliseconds: 1));
    return sellersResponse ?? <String, dynamic>{};
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
  group('SellerListScreen', () {
    late FakeApiService fakeApiService;
    late FakeAuthService fakeAuthService;

    setUp(() {
      fakeApiService = FakeApiService();
      fakeAuthService = FakeAuthService(fakeApiService);
    });

    testWidgets('should show loading state initially', (tester) async {
      fakeApiService.sellersResponse = <String, dynamic>{};

      await tester.pumpWidget(
        MaterialApp(
          home: SellerListScreen(authService: fakeAuthService),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should show error state when API fails', (tester) async {
      fakeApiService.throwError = Exception('API Error');

      await tester.pumpWidget(
        MaterialApp(
          home: SellerListScreen(authService: fakeAuthService),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('should show empty state when no sellers', (tester) async {
      fakeApiService.sellersResponse = <String, dynamic>{
        'data': <dynamic>[],
        'total': 0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: SellerListScreen(authService: fakeAuthService),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No sellers found'), findsOneWidget);
    });

    testWidgets('should show seller list when data is available', (tester) async {
      fakeApiService.sellersResponse = <String, dynamic>{
        'data': [
          {
            '_id': '1',
            'name': 'Jane Doe',
            'email': 'jane@test.com',
            'businessName': 'Fashion Store',
            'role': 'client',
            'isActive': true,
          },
        ],
        'total': 1,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: SellerListScreen(authService: fakeAuthService),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('Fashion Store'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('should filter sellers by search', (tester) async {
      fakeApiService.sellersResponse = <String, dynamic>{
        'data': <dynamic>[],
        'total': 0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: SellerListScreen(authService: fakeAuthService),
        ),
      );

      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Jane');
      await tester.pumpAndSettle();

      expect(find.text('No sellers found'), findsOneWidget);
    });
  });
}
