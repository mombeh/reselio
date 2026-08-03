import 'package:mobile/models/auth_response.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/services/auth_service.dart';
import 'fake_api_service.dart';

class FakeAuthService extends AuthService {
  FakeAuthService() : super(FakeApiService());

  @override
  bool get isLoading => false;

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return AuthResponse(
      accessToken: 'fake-token',
      user: User(
        id: '1',
        name: 'Test User',
        email: email,
        role: 'customer',
      ),
    );
  }

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return AuthResponse(
      accessToken: 'fake-token',
      user: User(
        id: '1',
        name: name,
        email: email,
        role: 'customer',
      ),
    );
  }

  @override
  Future<void> updateRole(String role) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<bool> loadUser() async => true;
}
