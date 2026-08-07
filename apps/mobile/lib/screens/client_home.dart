import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/router/app_router.dart';
import 'package:mobile/widgets/notification_icon_badge.dart';

class ClientHome extends StatelessWidget {
  final AuthService authService;

  const ClientHome({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Dashboard'),
        actions: [
          NotificationIconBadge(authService: authService),
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
              leading: const Icon(Icons.dashboard_outlined, color: Colors.deepPurple),
              title: const Text('Dashboard'),
              subtitle: const Text('Sales overview and metrics'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.dashboard,
                  arguments: {'authService': authService},
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_outlined, color: Colors.deepOrange),
              title: const Text('Notifications'),
              subtitle: const Text('View your notifications'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.notifications,
                  arguments: {'authService': authService},
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart_outlined, color: Colors.red),
              title: const Text('Reports'),
              subtitle: const Text('Detailed analytics and charts'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.reports,
                  arguments: {'authService': authService},
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.blue),
              title: const Text('My Orders'),
              subtitle: const Text('Manage and track orders'),
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
              leading: const Icon(Icons.analytics_outlined, color: Colors.deepPurple),
              title: const Text('Analytics'),
              subtitle: const Text('Sales and performance insights'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analytics feature coming soon')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
