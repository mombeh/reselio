import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/seller_detail_screen.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/models/auth_response.dart';

class FakeApiService implements ApiService {
  Map<String, dynamic>? sellerResponse;
  Map<String, dynamic>? statusResponse;
  Exception? throwError;

  @override
  Future<Map<String, dynamic>> getSellerById(String id) async {
    if (throwError != null) throw throwError!;
    await Future.delayed(const Duration(milliseconds: 1));
    return sellerResponse ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> updateSellerStatus(String id, bool isActive) async {
    if (throwError != null) throw throwError!;
    await Future.delayed(const Duration(milliseconds: 1));
    return statusResponse ?? <String, dynamic>{'isActive': isActive};
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
  group('SellerDetailScreen', () {
    late FakeApiService fakeApiService;
    late FakeAuthService fakeAuthService;

    setUp(() {
      fakeApiService = FakeApiService();
      fakeAuthService = FakeAuthService(fakeApiService);
    });

    testWidgets('should show loading state initially', (tester) async {
      fakeApiService.sellerResponse = <String, dynamic>{};

      await tester.pumpWidget(
        MaterialApp(
          home: SellerDetailScreen(
            authService: fakeAuthService,
            sellerId: 'seller1',
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should show error state when API fails', (tester) async {
      fakeApiService.throwError = Exception('API Error');

      await tester.pumpWidget(
        MaterialApp(
          home: SellerDetailScreen(
            authService: fakeAuthService,
            sellerId: 'seller1',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('should show seller details on success', (tester) async {
      fakeApiService.sellerResponse = <String, dynamic>{
        '_id': 'seller1',
        'name': 'Jane Doe',
        'email': 'jane@test.com',
        'phone': '+237 6XX XXX XXX',
        'businessName': 'Fashion Store',
        'address': 'Yaoundé, Cameroon',
        'role': 'client',
        'isActive': true,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: SellerDetailScreen(
            authService: fakeAuthService,
            sellerId: 'seller1',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsWidgets);
      expect(find.text('jane@test.com'), findsWidgets);
      expect(find.text('Fashion Store'), findsWidgets);
      expect(find.text('Active'), findsWidgets);
      expect(find.text('Suspend'), findsOneWidget);
    });

    testWidgets('should show suspend button for active seller', (tester) async {
      fakeApiService.sellerResponse = <String, dynamic>{
        '_id': 'seller1',
        'name': 'Jane Doe',
        'email': 'jane@test.com',
        'role': 'client',
        'isActive': true,
      };
      fakeApiService.statusResponse = <String, dynamic>{'isActive': false};

      await tester.pumpWidget(
        MaterialApp(
          home: SellerDetailScreen(
            authService: fakeAuthService,
            sellerId: 'seller1',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Suspend'), findsOneWidget);

      await tester.tap(find.text('Suspend'));
      await tester.pumpAndSettle();

      expect(fakeApiService.statusResponse?['isActive'], false);
    });

    testWidgets('should show activate button for inactive seller', (tester) async {
      fakeApiService.sellerResponse = <String, dynamic>{
        '_id': 'seller1',
        'name': 'Jane Doe',
        'email': 'jane@test.com',
        'role': 'client',
        'isActive': false,
      };
      fakeApiService.statusResponse = <String, dynamic>{'isActive': true};

      await tester.pumpWidget(
        MaterialApp(
          home: SellerDetailScreen(
            authService: fakeAuthService,
            sellerId: 'seller1',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Activate'), findsOneWidget);

      await tester.tap(find.text('Activate'));
      await tester.pumpAndSettle();

      expect(fakeApiService.statusResponse?['isActive'], true);
    });

    testWidgets('should handle status update failure', (tester) async {
      fakeApiService.sellerResponse = <String, dynamic>{
        '_id': 'seller1',
        'name': 'Jane Doe',
        'email': 'jane@test.com',
        'role': 'client',
        'isActive': true,
      };
      fakeApiService.throwError = Exception('Update failed');

      await tester.pumpWidget(
        MaterialApp(
          home: SellerDetailScreen(
            authService: fakeAuthService,
            sellerId: 'seller1',
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Suspend'));
      await tester.pumpAndSettle();

      expect(find.text('Update failed'), findsOneWidget);
    });
  });
}
