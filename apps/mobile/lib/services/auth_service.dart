import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/auth_response.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService apiService;
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  AuthService(this.apiService);

  Future<bool> loadUser() async {
    final token = await apiService.getToken();
    if (token == null || token.isEmpty) return false;

    try {
      _isLoading = true;
      notifyListeners();
      _currentUser = await apiService.getProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      await apiService.clearToken();
      return false;
    }
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await apiService.register(
        name: name,
        email: email,
        password: password,
      );
      await apiService.saveToken(response.accessToken);
      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await apiService.login(
        email: email,
        password: password,
      );
      await apiService.saveToken(response.accessToken);
      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateRole(String role) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedUser = await apiService.updateProfile(role: role);
      _currentUser = updatedUser;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? businessName,
    String? phone,
    String? address,
    String? currency,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await apiService.updateProfile(
        name: name,
        email: email,
        businessName: businessName,
        phone: phone,
        address: address,
        currency: currency,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await apiService.logout();
    } catch (e) {
      // Ignore logout errors, still clear local data
    }
    await apiService.clearToken();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> ensureClientRole() async {
    if (_currentUser == null) return;
    if (_currentUser!.role == 'client') return;

    _isLoading = true;
    notifyListeners();
    try {
      final updatedUser = await apiService.updateProfile(role: 'client');
      _currentUser = updatedUser;
    } catch (e) {
      // If profile update fails, keep current user data
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
