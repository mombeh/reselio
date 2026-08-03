import 'package:flutter/material.dart';
import 'package:mobile/router/app_router.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      initialRoute: AppRouter.root,
      onGenerateRoute: (settings) {
        return AppRouter.onGenerateRoute(settings, authService);
      },
    );
  }
}
