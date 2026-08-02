import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
import 'customer_home.dart';
import 'client_home.dart';
import 'admin_home.dart';

class RoleSelectionScreen extends StatelessWidget {
  final AuthService authService;

  const RoleSelectionScreen({super.key, required this.authService});

  Future<void> _selectRole(BuildContext context, String role) async {
    try {
      await authService.updateRole(role);

      if (!context.mounted) return;

      if (role == 'customer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CustomerHome(authService: authService),
          ),
        );
      } else if (role == 'client') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClientHome(authService: authService),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminHome(authService: authService),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select role: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Role')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose how you want to use Reselio',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              _RoleCard(
                title: 'Customer',
                subtitle: 'Browse and purchase products',
                icon: Icons.shopping_bag_outlined,
                color: Colors.blue,
                onTap: () => _selectRole(context, 'customer'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: 'Client',
                subtitle: 'Manage orders and customers',
                icon: Icons.business_outlined,
                color: Colors.green,
                onTap: () => _selectRole(context, 'client'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: 'Admin',
                subtitle: 'Full system access and management',
                icon: Icons.admin_panel_settings_outlined,
                color: Colors.deepPurple,
                onTap: () => _selectRole(context, 'admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
