import 'package:flutter/material.dart';

import 'package:mobile/models/daily_sale.dart';
import 'package:mobile/models/order.dart';
import 'package:mobile/models/top_product.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/router/app_router.dart';

class DashboardScreen extends StatefulWidget {
  final AuthService authService;

  const DashboardScreen({
    super.key,
    required this.authService,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _dashboardFuture;

  static const Color primary = Color(0xFF6C3FC5);
  static const Color background = Color(0xFFF9F7FC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF242029);
  static const Color textSecondary = Color(0xFF77727F);
  static const Color success = Color(0xFF2E9B68);
  static const Color warning = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<Map<String, dynamic>> _loadDashboard() async {
    final metrics =
        await widget.authService.apiService.getDashboardMetrics();

    final dailySales =
        await widget.authService.apiService.getDailySales(days: 7);

    final topProducts =
        await widget.authService.apiService.getTopProducts();

    final ordersResult =
        await widget.authService.apiService.getOrders(limit: 5);

    final customers =
        await widget.authService.apiService.getCustomers();

    final products =
        await widget.authService.apiService.getProducts();

    return {
      'metrics': metrics,
      'dailySales': dailySales,
      'topProducts': topProducts,
      'recentOrders': ordersResult['orders'] as List<Order>,
      'totalProducts': products.length,
      'totalCustomers': customers.length,
    };
  }

  void _refresh() {
    setState(() {
      _dashboardFuture = _loadDashboard();
    });
  }

  String _formatShortCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M FCFA';
    }

    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K FCFA';
    }

    return '${amount.toStringAsFixed(0)} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;
    final isSeller = user?.role == 'client';
    final userName =
        (isSeller && user?.businessName != null && user!.businessName!.trim().isNotEmpty)
            ? user.businessName!.trim()
            : (user?.name.trim().isNotEmpty == true ? user!.name.trim() : 'User');

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, ${userName.split(' ').first} 👋',
              style: const TextStyle(
                color: textPrimary,
                fontSize: 23,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              "Here's how your business is doing",
              style: TextStyle(
                color: textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: textPrimary,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.notifications,
                  arguments: {
                    'authService': widget.authService,
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primary,
        onRefresh: () async => _refresh(),
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

            final metrics = data['metrics'] as dynamic;

            final dailySales =
                (data['dailySales'] as List<dynamic>?)
                        ?.cast<DailySale>() ??
                    <DailySale>[];

            final topProducts =
                (data['topProducts'] as List<dynamic>?)
                        ?.cast<TopProduct>() ??
                    <TopProduct>[];

            final recentOrders =
                (data['recentOrders'] as List<dynamic>?)
                        ?.cast<Order>() ??
                    <Order>[];

            final totalProducts =
                data['totalProducts'] as int? ?? 0;

            final totalCustomers =
                data['totalCustomers'] as int? ?? 0;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRevenueCard(metrics),
                  const SizedBox(height: 16),
                  _buildMetricGrid(
                    metrics,
                    totalProducts,
                    totalCustomers,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    'Quick Actions',
                    null,
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                  const SizedBox(height: 26),
                  _buildSectionHeader(
                    'Revenue Overview',
                    'Last 7 days',
                  ),
                  const SizedBox(height: 12),
                  _buildChartSection(dailySales),
                  const SizedBox(height: 26),
                  _buildSectionHeader(
                    'Top Products',
                    'See all',
                  ),
                  const SizedBox(height: 12),
                  _buildTopProductsSection(topProducts),
                  const SizedBox(height: 26),
                  _buildSectionHeader(
                    'Recent Orders',
                    'See all',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.orderList,
                        arguments: {
                          'authService': widget.authService,
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildRecentOrdersSection(recentOrders),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRevenueCard(dynamic metrics) {
    final revenue = metrics?.totalRevenue ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7747D5),
            Color(0xFF5C32AF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Today's Revenue",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _formatShortCurrency(revenue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Sales overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(
    dynamic metrics,
    int totalProducts,
    int totalCustomers,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.65,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _metricCard(
          icon: Icons.receipt_long_rounded,
          title: 'Orders',
          value: '${metrics?.totalOrders ?? 0}',
          color: const Color(0xFF2589EF),
        ),
        _metricCard(
          icon: Icons.inventory_2_outlined,
          title: 'Products',
          value: '$totalProducts',
          color: const Color(0xFF0D9D8C),
        ),
        _metricCard(
          icon: Icons.people_outline_rounded,
          title: 'Customers',
          value: '$totalCustomers',
          color: const Color(0xFFF59E0B),
        ),
        _metricCard(
          icon: Icons.shopping_bag_outlined,
          title: 'Sales',
          value: '${metrics?.totalOrders ?? 0}',
          color: primary,
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
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
    return Row(
      children: [
        Expanded(
          child: _quickAction(
            icon: Icons.add_box_outlined,
            label: 'Add Product',
            color: primary,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.productList,
                arguments: {
                  'authService': widget.authService,
                },
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickAction(
            icon: Icons.add_shopping_cart_rounded,
            label: 'New Order',
            color: const Color(0xFF2589EF),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.createOrder,
                arguments: {
                  'authService': widget.authService,
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 21,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String? action, {
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: const TextStyle(
                color: primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChartSection(List<DailySale> dailySales) {
    if (dailySales.isEmpty) {
      return _emptyCard(
        icon: Icons.bar_chart_rounded,
        message: 'No sales data yet',
      );
    }

    final maxRevenue = dailySales
            .map((sale) => sale.totalRevenue)
            .reduce((a, b) => a > b ? a : b) *
        1.1;

    final maxValue = maxRevenue > 0 ? maxRevenue : 1.0;

    return Container(
      height: 190,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: dailySales.map((sale) {
          final barHeight =
              (sale.totalRevenue / maxValue) * 115;

          final displayDate = sale.date.length >= 10
              ? sale.date.substring(sale.date.length - 5)
              : sale.date;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 22,
                  height: barHeight > 5 ? barHeight : 5,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF8C5DE5),
                        Color(0xFF6439B9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  displayDate,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopProductsSection(
    List<TopProduct> topProducts,
  ) {
    if (topProducts.isEmpty) {
      return _emptyCard(
        icon: Icons.inventory_2_outlined,
        message: 'No products sold yet',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: topProducts.take(3).map((product) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9D8C)
                        .withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFF0D9D8C),
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.totalOrders} units sold',
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatShortCurrency(
                    product.totalRevenue,
                  ),
                  style: const TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentOrdersSection(
    List<Order> recentOrders,
  ) {
    if (recentOrders.isEmpty) {
      return _emptyCard(
        icon: Icons.receipt_long_outlined,
        message: 'No recent orders',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: recentOrders.map((order) {
          final statusColor =
              _statusColor(order.status);

          return Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.customerName,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatShortCurrency(order.total),
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            statusColor.withValues(alpha: 0.10),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _emptyCard({
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: textSecondary.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),
        const Icon(
          Icons.wifi_off_rounded,
          size: 52,
          color: textSecondary,
        ),
        const SizedBox(height: 18),
        Text(
          widget.authService.apiService
              .getErrorMessage(error),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: FilledButton.icon(
            onPressed: _refresh,
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

  Widget _buildLoadingSkeleton() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        _skeletonCard(155),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _skeletonCard(85)),
            const SizedBox(width: 12),
            Expanded(child: _skeletonCard(85)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _skeletonCard(85)),
            const SizedBox(width: 12),
            Expanded(child: _skeletonCard(85)),
          ],
        ),
        const SizedBox(height: 24),
        _skeletonCard(190),
        const SizedBox(height: 24),
        _skeletonCard(160),
        const SizedBox(height: 24),
        _skeletonCard(200),
      ],
    );
  }

  Widget _skeletonCard(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return warning;
      case 'Confirmed':
        return const Color(0xFF2589EF);
      case 'Preparing':
        return primary;
      case 'Ready for Pickup':
        return const Color(0xFF0D9D8C);
      case 'Delivered':
        return success;
      case 'Cancelled':
        return const Color(0xFFE5484D);
      default:
        return textSecondary;
    }
  }
}