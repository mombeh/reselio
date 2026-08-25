import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/router/app_router.dart';

class AdminHome extends StatefulWidget {
  final AuthService authService;

  const AdminHome({super.key, required this.authService});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  late Future<Map<String, dynamic>> _dashboardFuture;
  static const Color primary = Color(0xFF6C4AB6);
  static const Color background = Color(0xFFF7F7FA);

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    setState(() {
      _dashboardFuture = widget.authService.apiService.getAdminDashboard();
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _dashboardFuture = widget.authService.apiService.getAdminDashboard();
    });
    await _dashboardFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF17171C),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: primary,
        onRefresh: _refresh,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.data == null) {
              return _buildLoadingSkeleton();
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error);
            }

            final data = snapshot.data ?? {};
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              children: [
                _buildMetricGrid(data),
                const SizedBox(height: 24),
                _buildSectionHeader('Platform Overview'),
                const SizedBox(height: 12),
                _buildOverviewCard(data),
                const SizedBox(height: 24),
                _buildSectionHeader('Quick Actions'),
                const SizedBox(height: 12),
                _buildQuickActions(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricGrid(Map<String, dynamic> data) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _metricCard(
          title: 'Total Sellers',
          value: '${data['totalSellers'] ?? 0}',
          icon: Icons.store_outlined,
          color: primary,
        ),
        _metricCard(
          title: 'Total Customers',
          value: '${data['totalCustomers'] ?? 0}',
          icon: Icons.people_outline_rounded,
          color: const Color(0xFF2589EF),
        ),
        _metricCard(
          title: 'Total Products',
          value: '${data['totalProducts'] ?? 0}',
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF2E9B68),
        ),
        _metricCard(
          title: 'Total Orders',
          value: '${data['totalOrders'] ?? 0}',
          icon: Icons.shopping_bag_outlined,
          color: const Color(0xFFF59E0B),
        ),
        _metricCard(
          title: 'Pending Orders',
          value: '${data['pendingOrders'] ?? 0}',
          icon: Icons.pending_actions_rounded,
          color: Colors.orange,
        ),
        _metricCard(
          title: 'Active Users',
          value: '${data['activeUsers'] ?? 0}',
          icon: Icons.person_outlined,
          color: const Color(0xFF0D9D8C),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECEAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF202027),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF777780),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF202027),
      ),
    );
  }

  Widget _buildOverviewCard(Map<String, dynamic> data) {
    final totalRevenue = data['totalRevenue'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECEAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2E9B68).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: Color(0xFF2E9B68),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Revenue',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${totalRevenue.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF202027),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _quickActionCard(
          title: 'Sellers',
          subtitle: 'Manage sellers',
          icon: Icons.store_outlined,
          color: primary,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.sellerList,
              arguments: {'authService': widget.authService},
            );
          },
        ),
        _quickActionCard(
          title: 'Products',
          subtitle: 'View products',
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF2E9B68),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.adminProductList,
              arguments: {'authService': widget.authService},
            );
          },
        ),
        _quickActionCard(
          title: 'Orders',
          subtitle: 'View orders',
          icon: Icons.receipt_long_outlined,
          color: const Color(0xFFF59E0B),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.adminOrderList,
              arguments: {'authService': widget.authService},
            );
          },
        ),
        _quickActionCard(
          title: 'Customers',
          subtitle: 'View customers',
          icon: Icons.people_outline_rounded,
          color: const Color(0xFF2589EF),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.adminCustomerList,
              arguments: {'authService': widget.authService},
            );
          },
        ),
        _quickActionCard(
          title: 'Reports',
          subtitle: 'Platform analytics',
          icon: Icons.bar_chart_rounded,
          color: const Color(0xFF6C4AB6),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.adminReports,
              arguments: {'authService': widget.authService},
            );
          },
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFECEAF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF202027),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF777780),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(child: _skeletonCard(100)),
            const SizedBox(width: 12),
            Expanded(child: _skeletonCard(100)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _skeletonCard(100)),
            const SizedBox(width: 12),
            Expanded(child: _skeletonCard(100)),
          ],
        ),
        const SizedBox(height: 24),
        _skeletonCard(80),
      ],
    );
  }

  Widget _skeletonCard(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),
        Icon(
          Icons.wifi_off_rounded,
          size: 52,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 18),
        Text(
          error.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: FilledButton.icon(
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
