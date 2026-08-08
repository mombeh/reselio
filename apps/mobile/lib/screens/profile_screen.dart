import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/router/app_router.dart';
import 'package:mobile/widgets/edit_profile_dialog.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService authService;

  const ProfileScreen({super.key, required this.authService});

  Future<void> _logout(BuildContext context) async {
    await authService.logout();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRouter.login,
      arguments: {'authService': authService},
    );
  }

  Future<void> _editProfile(BuildContext context) async {
    final user = authService.currentUser;
    await showDialog(
      context: context,
      builder: (context) => EditProfileDialog(user: user, authService: authService),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editProfile(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepPurple.shade100,
            child: Text(
              user?.name.isNotEmpty == true
                  ? user!.name[0].toUpperCase()
                  : '?',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'User',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(
              user?.role ?? 'customer',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.deepPurple,
          ),
          if (user != null && user.businessName != null && user.businessName!.isNotEmpty)
            ...[
              const SizedBox(height: 8),
              Text(
                'Store: ${user.businessName!}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ],
          const SizedBox(height: 32),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Name'),
              subtitle: Text(user?.name ?? ''),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(user?.email ?? ''),
            ),
          ),
          if (user != null) ...[
            if (user.businessName != null && user.businessName!.isNotEmpty)
              ...[
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.store_outlined),
                    title: const Text('Store Name'),
                    subtitle: Text(user.businessName!),
                  ),
                ),
              ],
            if (user.phone != null && user.phone!.isNotEmpty)
              ...[
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: const Text('Phone'),
                    subtitle: Text(user.phone!),
                  ),
                ),
              ],
          ],
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Role'),
              subtitle: Text(_capitalize(user?.role ?? 'customer')),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
