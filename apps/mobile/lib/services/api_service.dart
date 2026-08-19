import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../models/customer.dart';
import '../models/customer_summary.dart';
import '../models/dashboard_metrics.dart';
import '../models/daily_sale.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/shared_product.dart';
import '../models/notification_model.dart';
import '../models/store.dart';
import '../models/top_product.dart';
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

  String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Unable to connect. Please check your internet connection.';
      }
      if (error.type == DioExceptionType.cancel) {
        return 'Request was cancelled. Please try again.';
      }
      if (error.response?.data != null && error.response!.data is Map) {
        final data = error.response!.data as Map;
        if (data['message'] != null) {
          return data['message'].toString();
        }
        if (data['error'] != null) {
          return data['error'].toString();
        }
      }
      if (error.response?.statusMessage != null) {
        return error.response!.statusMessage!;
      }
      return 'Something went wrong. Please try again.';
    }
    if (error is String) {
      return error;
    }
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
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
    String? address,
    String? currency,
    String? role,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (businessName != null) data['businessName'] = businessName;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (currency != null) data['currency'] = currency;
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

  Future<List<Product>> getProducts({String? search, String? category}) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null && category.isNotEmpty) params['category'] = category;
    final response = await dio.get('/products', queryParameters: params);
    final List<dynamic> data = response.data as List;
    return data.map((item) => Product.fromJson(item)).toList();
  }

  Future<List<Product>> getPublicProducts({String? search, String? category}) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null && category.isNotEmpty) params['category'] = category;
    final response = await dio.get('/products/public', queryParameters: params);
    final List<dynamic> data = response.data as List;
    return data.map((item) => Product.fromJson(item)).toList();
  }

  Future<Map<String, dynamic>> getPublicStore(String userId) async {
    final response = await dio.get('/stores/public/$userId');
    return response.data as Map<String, dynamic>;
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

  Future<String> getProductShareUrl(String id) async {
    final response = await dio.get('/products/$id/share');
    return response.data['shareUrl'] as String;
  }

  Future<SharedProduct> getPublicProduct(String publicId) async {
    final response = await dio.get('/products/public/$publicId');
    return SharedProduct.fromJson(response.data);
  }

  Future<List<NotificationModel>> getNotifications() async {
    final response = await dio.get('/notifications');
    final data = List<dynamic>.from(response.data);
    return data.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<int> getUnreadNotificationCount() async {
    final response = await dio.get('/notifications');
    final data = List<dynamic>.from(response.data);
    return data.where((item) => item['isRead'] != true).length;
  }

  Future<void> markNotificationRead(String id) async {
    await dio.patch('/notifications/$id/read');
  }

  Future<void> markAllNotificationsRead() async {
    await dio.patch('/notifications/read-all');
  }

  Future<List<Customer>> getCustomers() async {
    final response = await dio.get('/customers');
    final List<dynamic> data = response.data as List;
    return data.map((item) => Customer.fromJson(item)).toList();
  }

  Future<Customer> getCustomer(String id) async {
    final response = await dio.get('/customers/$id');
    return Customer.fromJson(response.data);
  }

  Future<Customer> createCustomer({
    required String fullName,
    required String phoneNumber,
    String? email,
    String? address,
    String? notes,
  }) async {
    final data = <String, dynamic>{
      'fullName': fullName,
      'phoneNumber': phoneNumber,
    };
    if (email != null && email.isNotEmpty) data['email'] = email;
    if (address != null && address.isNotEmpty) data['address'] = address;
    if (notes != null && notes.isNotEmpty) data['notes'] = notes;

    final response = await dio.post('/customers', data: data);
    return Customer.fromJson(response.data);
  }

  Future<Customer> updateCustomer({
    required String id,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? address,
    String? notes,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null && fullName.isNotEmpty) data['fullName'] = fullName;
    if (phoneNumber != null && phoneNumber.isNotEmpty) data['phoneNumber'] = phoneNumber;
    if (email != null) data['email'] = email;
    if (address != null && address.isNotEmpty) data['address'] = address;
    if (notes != null && notes.isNotEmpty) data['notes'] = notes;

    final response = await dio.patch('/customers/$id', data: data);
    return Customer.fromJson(response.data);
  }

  Future<void> deleteCustomer(String id) async {
    await dio.delete('/customers/$id');
  }

  Future<List<Customer>> getCustomersForOrder() async {
    final response = await dio.get('/orders/customers/list');
    final data = List<dynamic>.from(response.data);
    return data
        .map((item) => Customer.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getOrders({
    String? status,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final params = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final response = await dio.get('/orders', queryParameters: params);
    final data = response.data as Map<String, dynamic>;
    final List<dynamic> ordersList = data['data'] as List;
    return {
      'orders': ordersList.map((item) => Order.fromJson(item)).toList(),
      'total': data['total'] as int,
      'page': data['page'] as int,
      'limit': data['limit'] as int,
      'totalPages': data['totalPages'] as int,
    };
  }

  Future<Map<String, dynamic>> getOrdersByCustomer(String customerId) async {
    final response = await dio.get('/orders/customer/$customerId');
    final data = response.data as Map<String, dynamic>;
    final List<dynamic> ordersList = data['data'] as List;
    return {
      'orders': ordersList.map((item) => Order.fromJson(item)).toList(),
      'total': data['total'] as int,
      'page': data['page'] as int,
      'limit': data['limit'] as int,
      'totalPages': data['totalPages'] as int,
    };
  }

  Future<Order> getOrder(String id) async {
    final response = await dio.get('/orders/$id');
    return Order.fromJson(response.data);
  }

  Future<Order> createOrder({
    String? customerId,
    required List<Map<String, dynamic>> items,
    double advancePaid = 0,
  }) async {
    final data = <String, dynamic>{
      'items': items,
      'advancePaid': advancePaid,
    };
    if (customerId != null) {
      data['customerId'] = customerId;
    }

    final response = await dio.post('/orders', data: data);
    return Order.fromJson(response.data);
  }

  Future<Order> updateOrderStatus(String id, String status) async {
    final response = await dio.patch('/orders/$id/status', data: {'status': status});
    return Order.fromJson(response.data);
  }

  Future<void> cancelOrder(String id) async {
    await dio.delete('/orders/$id');
  }

  Future<DashboardMetrics> getDashboardMetrics() async {
    final response = await dio.get('/orders/dashboard');
    final data = response.data as Map<String, dynamic>;
    return DashboardMetrics.fromJson(data);
  }

  Future<Map<String, dynamic>> getAggregatedDashboard() async {
    final response = await dio.get('/dashboard');
    final data = response.data as Map<String, dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> getSalesReport({String? period, String? startDate, String? endDate}) async {
    final params = <String, dynamic>{};
    if (period != null) params['period'] = period;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await dio.get('/reports/sales', queryParameters: params);
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getProductPerformance() async {
    final response = await dio.get('/reports/products');
    final List<dynamic> data = response.data as List;
    return data.map((item) => item as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getCustomerReport() async {
    final response = await dio.get('/reports/customers');
    final List<dynamic> data = response.data as List;
    return data.map((item) => item as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getRevenueTrend({String? period, String? startDate, String? endDate}) async {
    final params = <String, dynamic>{};
    if (period != null) params['period'] = period;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await dio.get('/reports/revenue', queryParameters: params);
    final List<dynamic> data = response.data as List;
    return data.map((item) => item as Map<String, dynamic>).toList();
  }

  Future<List<DailySale>> getDailySales({int days = 7}) async {
    final response = await dio.get('/orders/analytics/daily?days=$days');
    final List<dynamic> data = response.data as List;
    return data.map((item) => DailySale.fromJson(item)).toList();
  }

  Future<List<CustomerSummary>> getTopCustomers({int limit = 5}) async {
    final response = await dio.get('/orders/customers');
    final List<dynamic> data = response.data as List;
    final all = data.map((item) => CustomerSummary.fromJson(item)).toList();
    return all.take(limit).toList();
  }

  Future<List<TopProduct>> getTopProducts() async {
    final response = await dio.get('/orders/analytics/products');
    final List<dynamic> data = response.data as List;
    return data.map((item) => TopProduct.fromJson(item)).toList();
  }

  Future<void> saveToken(String token) async {
    await prefs.setString(tokenKey, token);
  }

  Future<void> clearToken() async {
    await prefs.remove(tokenKey);
  }

  Future<void> logout() async {
    await dio.post('/auth/logout');
  }

  Future<void> addFavorite(String productId) async {
    await dio.post('/favorites', data: {'productId': productId});
  }

  Future<void> removeFavorite(String productId) async {
    await dio.delete('/favorites/$productId');
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final response = await dio.get('/favorites');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> getMyOrders({String? status, int page = 1, int limit = 10}) async {
    final params = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status.isNotEmpty) params['status'] = status;

    final response = await dio.get('/orders/my-orders', queryParameters: params);
    final data = response.data as Map<String, dynamic>;
    final List<dynamic> ordersList = data['data'] as List;
    return {
      'orders': ordersList.map((item) => Order.fromJson(item)).toList(),
      'total': data['total'] as int,
      'page': data['page'] as int,
      'limit': data['limit'] as int,
      'totalPages': data['totalPages'] as int,
    };
  }

  Future<String?> getToken() async {
    return prefs.getString(tokenKey);
  }
}
