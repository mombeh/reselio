import 'package:flutter/material.dart';
import 'package:mobile/models/daily_sale.dart';
import 'package:mobile/models/order.dart';
import 'package:mobile/models/top_product.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/router/app_router.dart';

class DashboardScreen extends StatefulWidget {
  final AuthService authService;

  const DashboardScreen({super.key, required this.authService});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<Map<String, dynamic>> _loadDashboard() async {
    final metrics = await widget.authService.apiService.getDashboardMetrics();
    final dailySales = await widget.authService.apiService.getDailySales(days: 7);
    final topProducts = await widget.authService.apiService.getTopProducts();
    final ordersResult = await widget.authService.apiService.getOrders(limit: 5);
    final customers = await widget.authService.apiService.getCustomers();
    final products = await widget.authService.apiService.getProducts();

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
    setState(() => _dashboardFuture = _loadDashboard());
  }

  String _formatShortCurrency(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M FCFA';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K FCFA';
    return '${amount.toStringAsFixed(0)} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.authService.currentUser?.name ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $userName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Today's Overview",
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade100,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.profile,
                arguments: {'authService': widget.authService},
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.data == null) {
              return _buildLoadingSkeleton();
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final data = snapshot.data ?? {};
            final metrics = data['metrics'] as dynamic;
            final dailySales = (data['dailySales'] as List<dynamic>?)?.cast<DailySale>() ?? <DailySale>[];
            final topProducts = (data['topProducts'] as List<dynamic>?)?.cast<TopProduct>() ?? <TopProduct>[];
            final recentOrders = (data['recentOrders'] as List<dynamic>?)?.cast<Order>() ?? <Order>[];
            final totalProducts = data['totalProducts'] as int? ?? 0;
            final totalCustomers = data['totalCustomers'] as int? ?? 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(metrics, totalProducts, totalCustomers),
                  const SizedBox(height: 24),
                  _buildChartSection(dailySales),
                  const SizedBox(height: 24),
                  _buildTopProductsSection(topProducts),
                  const SizedBox(height: 24),
                  _buildRecentOrdersSection(recentOrders),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _skeletonCard(120)),
            const SizedBox(width: 12),
            Expanded(child: _skeletonCard(120)),
            const SizedBox(width: 12),
            Expanded(child: _skeletonCard(120)),
            const SizedBox(width: 12),
            Expanded(child: _skeletonCard(120)),
          ],
        ),
        const SizedBox(height: 24),
        _skeletonCard(200),
        const SizedBox(height: 24),
        _skeletonCard(150),
        const SizedBox(height: 16),
        _skeletonCard(100),
      ],
    );
  }

  Widget _skeletonCard(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildSummaryCards(dynamic metrics, int totalProducts, int totalCustomers) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _summaryCard(
          Icons.attach_money,
          'Revenue',
          _formatShortCurrency(metrics?.totalRevenue ?? 0.0),
          Colors.deepPurple,
        ),
        _summaryCard(
          Icons.receipt_long,
          'Orders',
          '${metrics?.totalOrders ?? 0}',
          Colors.blue,
        ),
        _summaryCard(
          Icons.inventory_2,
          'Products',
          '$totalProducts',
          Colors.teal,
        ),
        _summaryCard(
          Icons.people,
          'Customers',
          '$totalCustomers',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _summaryCard(IconData icon, String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(List<DailySale> dailySales) {
    if (dailySales.isEmpty) {
      return _emptyChartCard();
    }

    final maxRevenue = dailySales
            .map((s) => s.totalRevenue)
            .reduce((a, b) => a > b ? a : b) *
        1.1;

    final maxValue = maxRevenue > 0 ? maxRevenue : 1.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue (Last 7 Days)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: dailySales.asMap().entries.map((entry) {
                  final sale = entry.value;
                  final barHeight = (sale.totalRevenue / maxValue) * 120;
                  final displayDate = sale.date.length >= 10
                      ? sale.date.substring(sale.date.length - 5)
                      : sale.date;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 30,
                          height: barHeight > 0 ? barHeight : 2,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayDate,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyChartCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue (Last 7 Days)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'No sales data yet',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsSection(List<TopProduct> topProducts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (topProducts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No products sold yet',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topProducts.length,
                itemBuilder: (context, index) {
                  final product = topProducts[index];
                  return ListTile(
                    leading: const Icon(Icons.inventory_2_outlined, color: Colors.teal),
                    title: Text(product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${product.totalOrders} unit${product.totalOrders > 1 ? 's' : ''} sold',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        Text(
                          _formatShortCurrency(product.totalRevenue),
                          style: TextStyle(fontSize: 12, color: Colors.deepPurple.shade700),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersSection(List<Order> recentOrders) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (recentOrders.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No recent orders',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentOrders.length,
                itemBuilder: (context, index) {
                  final order = recentOrders[index];
                  return ListTile(
                    title: Text(order.orderNumber),
                    subtitle: Text(order.customerName),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatShortCurrency(order.total),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _statusColor(order.status).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              color: _statusColor(order.status),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Waiting for Supplier':
        return Colors.blue;
      case 'Supplier Shipped':
        return Colors.cyan;
      case 'Received':
        return Colors.teal;
      case 'Sent to Customer':
        return Colors.deepPurple;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}