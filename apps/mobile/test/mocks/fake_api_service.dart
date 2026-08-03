import 'package:mobile/models/auth_response.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/services/api_service.dart';
import 'fake_shared_preferences.dart';

class FakeApiService extends ApiService {
  FakeApiService() : super(FakeSharedPreferences());

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
  Future<User> getProfile() async {
    return User(
      id: '1',
      name: 'Test User',
      email: 'test@example.com',
      role: 'customer',
    );
  }

  @override
  Future<User> updateProfile({
    String? name,
    String? email,
    String? businessName,
    String? phone,
    String? role,
  }) async {
    return User(
      id: '1',
      name: name ?? 'Test User',
      email: email ?? 'test@example.com',
      role: role ?? 'customer',
    );
  }
}
