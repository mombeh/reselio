import 'package:flutter/material.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/customer_home.dart';
import 'screens/client_home.dart';
import 'screens/admin_home.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final apiService = ApiService(prefs);
  final authService = AuthService(apiService);

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService? authService;

  const MyApp({super.key, this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reselio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        final args = (settings.arguments as Map<String, dynamic>?) ?? {};
        final authService = args['authService'] as AuthService?;

        Widget Function(BuildContext) builder;
        switch (settings.name) {
          case '/welcome':
            builder = (_) => WelcomeScreen(authService: authService!);
            break;
          case '/login':
            builder = (_) => LoginScreen(authService: authService!);
            break;
          case '/register':
            builder = (_) => RegisterScreen(authService: authService!);
            break;
          case '/role-selection':
            builder = (_) => RoleSelectionScreen(authService: authService!);
            break;
          case '/customer-home':
            builder = (_) => CustomerHome(authService: authService!);
            break;
          case '/client-home':
            builder = (_) => ClientHome(authService: authService!);
            break;
          case '/admin-home':
            builder = (_) => AdminHome(authService: authService!);
            break;
          case '/profile':
            builder = (_) => ProfileScreen(authService: authService!);
            break;
          default:
            builder = (_) => SplashScreen(authService: authService);
        }

        return MaterialPageRoute(builder: builder);
      },
      home: SplashScreen(authService: authService),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final AuthService? authService;

  const SplashScreen({super.key, this.authService});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authService = widget.authService;
    if (authService == null) return;

    final isLoggedIn = await authService.loadUser();
    if (!mounted) return;

    if (isLoggedIn) {
      final hasSelectedRole = await authService.hasSelectedRole;
      if (!mounted) return;

      if (!hasSelectedRole) {
        Navigator.pushReplacementNamed(
          context,
          '/role-selection',
          arguments: {'authService': authService},
        );
        return;
      }

      final role = authService.currentUser?.role ?? 'customer';
      if (!mounted) return;

      if (role == 'customer') {
        Navigator.pushReplacementNamed(
          context,
          '/customer-home',
          arguments: {'authService': authService},
        );
      } else if (role == 'client') {
        Navigator.pushReplacementNamed(
          context,
          '/client-home',
          arguments: {'authService': authService},
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/admin-home',
          arguments: {'authService': authService},
        );
      }
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/welcome',
        arguments: {'authService': authService},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_center, size: 80, color: Colors.deepPurple),
            SizedBox(height: 24),
            Text(
              'Reselio',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
