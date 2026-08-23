import 'package:flutter/material.dart';
import 'package:mobile/screens/welcome_screen.dart';
import 'package:mobile/screens/login_screen.dart';
import 'package:mobile/screens/register_screen.dart';
import 'package:mobile/screens/role_selection_screen.dart';
import 'package:mobile/screens/customer_home.dart';
import 'package:mobile/screens/client_home.dart';
import 'package:mobile/screens/admin_home.dart';
import 'package:mobile/screens/profile_screen.dart';
import 'package:mobile/screens/splash_screen.dart';
import 'package:mobile/screens/create_store_screen.dart';
import 'package:mobile/screens/my_store_screen.dart';
import 'package:mobile/screens/product_list_screen.dart';
import 'package:mobile/screens/customer_product_list_screen.dart';
import 'package:mobile/screens/favorites_screen.dart';
import 'package:mobile/screens/my_products_screen.dart';
import 'package:mobile/screens/add_product_screen.dart';
import 'package:mobile/screens/product_detail_screen.dart';
import 'package:mobile/screens/customer_list_screen.dart';
import 'package:mobile/screens/add_customer_screen.dart';
import 'package:mobile/screens/customer_detail_screen.dart';
import 'package:mobile/screens/order_list_screen.dart';
import 'package:mobile/screens/create_order_screen.dart';
import 'package:mobile/screens/notification_screen.dart';
import 'package:mobile/screens/order_detail_screen.dart';
import 'package:mobile/screens/order_confirmation_screen.dart';
import 'package:mobile/screens/dashboard_screen.dart';
import 'package:mobile/screens/reports_screen.dart';
import 'package:mobile/screens/shared_product_screen.dart';
import 'package:mobile/screens/admin_dashboard_screen.dart';
import 'package:mobile/screens/seller_list_screen.dart';
import 'package:mobile/screens/seller_detail_screen.dart';
import 'package:mobile/screens/admin_customer_list_screen.dart';
import 'package:mobile/screens/admin_customer_detail_screen.dart';
import 'package:mobile/models/store.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/models/customer.dart';
import 'package:mobile/models/order.dart';
import 'package:mobile/services/auth_service.dart';

class AppRouter {
  static const String root = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String roleSelection = '/role-selection';
  static const String customerHome = '/customer-home';
  static const String clientHome = '/client-home';
  static const String adminHome = '/admin-home';
  static const String profile = '/profile';
  static const String createStore = '/create-store';
  static const String myStore = '/my-store';
  static const String productList = '/product-list';
  static const String customerProductList = '/customer-product-list';
  static const String favorites = '/favorites';
  static const String myProducts = '/my-products';
  static const String addProduct = '/add-product';
  static const String productDetail = '/product-detail';
  static const String customerList = '/customer-list';
  static const String addCustomer = '/add-customer';
  static const String customerDetail = '/customer-detail';
  static const String orderList = '/order-list';
  static const String createOrder = '/create-order';
  static const String orderDetail = '/order-detail';
  static const String orderConfirmation = '/order-confirmation';
  static const String dashboard = '/dashboard';
  static const String reports = '/reports';
  static const String sharedProduct = '/shared-product';
  static const String notifications = '/notifications';
  static const String adminDashboard = '/admin-dashboard';
  static const String sellerList = '/seller-list';
  static const String sellerDetail = '/seller-detail';
  static const String adminCustomerList = '/admin-customer-list';
  static const String adminCustomerDetail = '/admin-customer-detail';

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
    AuthService? authService,
  ) {
    Map<String, dynamic> args = {};
    if (settings.arguments is Map) {
      args = settings.arguments as Map<String, dynamic>;
      authService = args['authService'] as AuthService? ?? authService;
    }

    switch (settings.name) {
      case root:
        return MaterialPageRoute(
          builder: (_) => SplashScreen(authService: authService),
          settings: settings,
        );
      case welcome:
        return MaterialPageRoute(
          builder: (_) => WelcomeScreen(authService: authService!),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(authService: authService!),
          settings: settings,
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => RegisterScreen(authService: authService!),
          settings: settings,
        );
      case roleSelection:
        return MaterialPageRoute(
          builder: (_) => RoleSelectionScreen(authService: authService!),
          settings: settings,
        );
      case customerHome:
        return MaterialPageRoute(
          builder: (_) => CustomerHome(authService: authService!),
          settings: settings,
        );
      case clientHome:
        return MaterialPageRoute(
          builder: (_) => ClientHome(authService: authService!),
          settings: settings,
        );
      case adminHome:
        return MaterialPageRoute(
          builder: (_) => AdminHome(authService: authService!),
          settings: settings,
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(authService: authService!),
          settings: settings,
        );
      case createStore:
        return MaterialPageRoute(
          builder: (_) => CreateStoreScreen(
            authService: authService!,
            store: args['store'] as Store?,
          ),
          settings: settings,
        );
      case myStore:
        return MaterialPageRoute(
          builder: (_) => MyStoreScreen(authService: authService!),
          settings: settings,
        );
      case productList:
        return MaterialPageRoute(
          builder: (_) => ProductListScreen(authService: authService!),
          settings: settings,
        );
      case customerProductList:
        return MaterialPageRoute(
          builder: (_) => CustomerProductListScreen(authService: authService!),
          settings: settings,
        );
      case favorites:
        return MaterialPageRoute(
          builder: (_) => FavoritesScreen(authService: authService!),
          settings: settings,
        );
      case myProducts:
        return MaterialPageRoute(
          builder: (_) => MyProductsScreen(authService: authService!),
          settings: settings,
        );
      case addProduct:
        return MaterialPageRoute(
          builder: (_) => AddProductScreen(
            authService: authService!,
            product: args['product'] as Product?,
          ),
          settings: settings,
        );
      case productDetail:
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            authService: authService,
            product: args['product'] as Product,
            shareUrl: args['shareUrl'] as String?,
          ),
          settings: settings,
        );
      case sharedProduct:
        return MaterialPageRoute(
          builder: (_) => SharedProductScreen(
            publicId: args['publicId'] as String,
          ),
          settings: settings,
        );
      case notifications:
        return MaterialPageRoute(
          builder: (_) => NotificationScreen(authService: authService),
          settings: settings,
        );
      case customerList:
        return MaterialPageRoute(
          builder: (_) => CustomerListScreen(authService: authService!),
          settings: settings,
        );
      case addCustomer:
        return MaterialPageRoute(
          builder: (_) => AddCustomerScreen(
            authService: authService!,
            customer: args['customer'] as Customer?,
          ),
          settings: settings,
        );
      case customerDetail:
        return MaterialPageRoute(
          builder: (_) => CustomerDetailScreen(
            customer: args['customer'] as Customer,
            authService: authService,
          ),
          settings: settings,
        );
      case orderList:
        return MaterialPageRoute(
          builder: (_) => OrderListScreen(authService: authService!),
          settings: settings,
        );
      case createOrder:
        return MaterialPageRoute(
          builder: (_) => CreateOrderScreen(
            authService: authService!,
            initialItems: args['initialItems'] as List<Map<String, dynamic>>?,
          ),
          settings: settings,
        );
      case orderDetail:
        return MaterialPageRoute(
          builder: (_) => OrderDetailScreen(
            authService: authService!,
            order: args['order'] as Order,
          ),
          settings: settings,
        );
      case orderConfirmation:
        return MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(
            authService: authService!,
            order: args['order'] as Order,
          ),
          settings: settings,
        );
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => DashboardScreen(authService: authService!),
          settings: settings,
        );
      case reports:
        return MaterialPageRoute(
          builder: (_) => ReportsScreen(authService: authService!),
          settings: settings,
        );
      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => AdminDashboardScreen(authService: authService!),
          settings: settings,
        );
      case sellerList:
        return MaterialPageRoute(
          builder: (_) => SellerListScreen(authService: authService!),
          settings: settings,
        );
      case sellerDetail:
        return MaterialPageRoute(
          builder: (_) => SellerDetailScreen(
            authService: authService!,
            sellerId: args['sellerId'] as String,
          ),
          settings: settings,
        );
      case adminCustomerList:
        return MaterialPageRoute(
          builder: (_) => AdminCustomerListScreen(authService: authService!),
          settings: settings,
        );
      case adminCustomerDetail:
        return MaterialPageRoute(
          builder: (_) => AdminCustomerDetailScreen(
            authService: authService!,
            customerId: args['customerId'] as String,
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => SplashScreen(authService: authService),
          settings: settings,
        );
    }
  }
}
