import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/router/app_router.dart';

class AdminHome extends StatelessWidget {
  final AuthService authService;

  const AdminHome({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.profile,
                arguments: {'authService': authService},
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.people_alt_outlined, color: Colors.deepPurple),
              title: const Text('User Management'),
              subtitle: const Text('Manage all users'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User management coming soon')),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.store_outlined, color: Colors.orange),
              title: const Text('My Store'),
              subtitle: const Text('View and manage your store'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.myStore,
                  arguments: {'authService': authService},
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_2_outlined, color: Colors.teal),
              title: const Text('Products'),
              subtitle: const Text('Manage your products'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.productList,
                  arguments: {'authService': authService},
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.people_outline, color: Colors.green),
              title: const Text('Customers'),
              subtitle: const Text('View and manage customers'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.customerList,
                  arguments: {'authService': authService},
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.blue),
              title: const Text('Orders'),
              subtitle: const Text('Manage orders'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.orderList,
                  arguments: {'authService': authService},
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.business_outlined, color: Colors.blue),
              title: const Text('All Orders'),
              subtitle: const Text('View all platform orders'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.orderList,
                  arguments: {'authService': authService},
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.grey),
              title: const Text('System Settings'),
              subtitle: const Text('Configure platform settings'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
