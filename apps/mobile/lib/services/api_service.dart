import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../models/product.dart';
import '../models/store.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:4000';
  static const String tokenKey = 'auth_token';

  late final Dio dio;
  final SharedPreferences prefs;

  ApiService(this.prefs) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = prefs.getString(tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          prefs.remove(tokenKey);
        }
        return handler.next(error);
      },
    ));
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<User> getProfile() async {
    final response = await dio.get('/auth/me');
    return User.fromJson(response.data);
  }

  Future<User> updateProfile({
    String? name,
    String? email,
    String? businessName,
    String? phone,
    String? role,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (businessName != null) data['businessName'] = businessName;
    if (phone != null) data['phone'] = phone;
    if (role != null) data['role'] = role;

    final response = await dio.patch('/users/profile', data: data);
    return User.fromJson(response.data);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await dio.patch(
      '/users/password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<Store> createStore({
    required String name,
    required String description,
    required String phone,
    required String address,
    String? logo,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'description': description,
      'phone': phone,
      'address': address,
    };
    if (logo != null) data['logo'] = logo;

    final response = await dio.post('/stores', data: data);
    return Store.fromJson(response.data);
  }

  Future<Store> getMyStore() async {
    final response = await dio.get('/stores/my-store');
    return Store.fromJson(response.data);
  }

  Future<Store> updateStore({
    String? name,
    String? description,
    String? phone,
    String? address,
    String? logo,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (logo != null) data['logo'] = logo;

    final response = await dio.patch('/stores/my-store', data: data);
    return Store.fromJson(response.data);
  }

  Future<List<Product>> getProducts() async {
    final response = await dio.get('/products');
    final List<dynamic> data = response.data as List;
    return data.map((item) => Product.fromJson(item)).toList();
  }

  Future<Product> createProduct({
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String category,
    String? imageUrl,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'category': category,
    };
    if (imageUrl != null) data['imageUrl'] = imageUrl;

    final response = await dio.post('/products', data: data);
    return Product.fromJson(response.data);
  }

  Future<Product> updateProduct({
    required String id,
    String? name,
    String? description,
    double? price,
    int? quantity,
    String? category,
    String? imageUrl,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (quantity != null) data['quantity'] = quantity;
    if (category != null) data['category'] = category;
    if (imageUrl != null) data['imageUrl'] = imageUrl;

    final response = await dio.patch('/products/$id', data: data);
    return Product.fromJson(response.data);
  }

  Future<void> deleteProduct(String id) async {
    await dio.delete('/products/$id');
  }

  Future<void> saveToken(String token) async {
    await prefs.setString(tokenKey, token);
  }

  Future<void> clearToken() async {
    await prefs.remove(tokenKey);
  }

  Future<String?> getToken() async {
    return prefs.getString(tokenKey);
  }
}
