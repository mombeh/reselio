import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/router/app_router.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final authService = widget.authService;
    if (authService == null) return;

    final isLoggedIn = await authService.loadUser();
    if (!mounted) return;

    if (isLoggedIn) {
      final user = authService.currentUser;
      final hasRole = user != null && user.role != null && user.role!.isNotEmpty;
      if (!mounted) return;

      if (!hasRole) {
        Navigator.pushReplacementNamed(
          context,
          AppRouter.roleSelection,
          arguments: {'authService': authService},
        );
        return;
      }

      final role = user!.role!;
      if (!mounted) return;

      if (role == 'customer') {
        Navigator.pushReplacementNamed(
          context,
          AppRouter.customerHome,
          arguments: {'authService': authService},
        );
      } else if (role == 'client') {
        Navigator.pushReplacementNamed(
          context,
          AppRouter.clientHome,
          arguments: {'authService': authService},
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          AppRouter.adminHome,
          arguments: {'authService': authService},
        );
      }
    } else {
      Navigator.pushReplacementNamed(
        context,
        AppRouter.welcome,
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
