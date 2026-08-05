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
import 'package:mobile/models/store.dart';
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
      default:
        return MaterialPageRoute(
          builder: (_) => SplashScreen(authService: authService),
          settings: settings,
        );
    }
  }
}
