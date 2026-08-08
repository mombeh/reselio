import 'package:flutter/material.dart';
import 'package:mobile/models/customer_summary.dart';
import 'package:mobile/models/daily_sale.dart';
import 'package:mobile/models/dashboard_metrics.dart';
import 'package:mobile/models/order.dart';
import 'package:mobile/models/top_product.dart';
import 'package:mobile/services/auth_service.dart';

class ReportsScreen extends StatefulWidget {
  final AuthService authService;

  const ReportsScreen({super.key, required this.authService});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

enum ReportPeriod { today, week, month, custom }

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<Map<String, dynamic>> _reportFuture;
  ReportPeriod _selectedPeriod = ReportPeriod.week;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _reportFuture = _loadReport();
  }

  String _formatShortCurrency(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M FCFA';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K FCFA';
    return '${amount.toStringAsFixed(0)} FCFA';
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} FCFA';
  }

  int get _daysForPeriod {
    switch (_selectedPeriod) {
      case ReportPeriod.today:
        return 1;
      case ReportPeriod.week:
        return 7;
      case ReportPeriod.month:
        return 30;
      case ReportPeriod.custom:
        if (_customRange != null) {
          return _customRange!.duration.inDays;
        }
        return 7;
    }
  }

  Future<void> _selectCustomRange() async {
    final now = DateTime.now();
    final initialDateRange = _customRange ?? DateTimeRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );

    final result = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );

    if (result != null) {
      setState(() => _customRange = result);
      _refresh();
    }
  }

  Future<Map<String, dynamic>> _loadReport() async {
    final days = _daysForPeriod;
    final metrics = await widget.authService.apiService.getDashboardMetrics();
    final dailySales = await widget.authService.apiService.getDailySales(days: days);
    final topProducts = await widget.authService.apiService.getTopProducts();
    final topCustomers = await widget.authService.apiService.getTopCustomers(limit: 5);
    final ordersResult = await widget.authService.apiService.getOrders(limit: 5);

    return {
      'metrics': metrics,
      'dailySales': dailySales,
      'topProducts': topProducts,
      'topCustomers': topCustomers,
      'recentOrders': ordersResult['orders'] as List<Order>,
    };
  }

  void _refresh() {
    setState(() => _reportFuture = _loadReport());
  }

  String get _periodLabel {
    switch (_selectedPeriod) {
      case ReportPeriod.today:
        return 'Today';
      case ReportPeriod.week:
        return 'This Week';
      case ReportPeriod.month:
        return 'This Month';
      case ReportPeriod.custom:
        if (_customRange != null) {
          return '${_customRange!.start.day}/${_customRange!.start.month} - ${_customRange!.end.day}/${_customRange!.end.month}';
        }
        return 'Custom Range';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _reportFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      snapshot.data == null) {
                    return _buildLoadingSkeleton();
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data ?? {};
                  final metrics = data['metrics'] as DashboardMetrics;
                  final dailySales = (data['dailySales'] as List<dynamic>?)?.cast<DailySale>() ?? <DailySale>[];
                  final topProducts = (data['topProducts'] as List<dynamic>?)?.cast<TopProduct>() ?? <TopProduct>[];
                  final topCustomers = (data['topCustomers'] as List<dynamic>?)?.cast<CustomerSummary>() ?? <CustomerSummary>[];
                  final recentOrders = (data['recentOrders'] as List<dynamic>?)?.cast<Order>() ?? <Order>[];

                  if (dailySales.isEmpty && recentOrders.isEmpty) {
                    return _buildEmptyState();
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(metrics),
                        const SizedBox(height: 24),
                        _buildRevenueChart(dailySales),
                        const SizedBox(height: 24),
                        _buildTopProducts(topProducts),
                        const SizedBox(height: 24),
                        _buildTopCustomers(topCustomers),
                        const SizedBox(height: 24),
                        _buildRecentOrders(recentOrders),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<ReportPeriod>(
              segments: const [
                ButtonSegment(value: ReportPeriod.today, label: Text('Today')),
                ButtonSegment(value: ReportPeriod.week, label: Text('Week')),
                ButtonSegment(value: ReportPeriod.month, label: Text('Month')),
                ButtonSegment(value: ReportPeriod.custom, label: Text('Custom')),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (Set<ReportPeriod> newValue) {
                final newSelection = newValue.first;
                if (newSelection == _selectedPeriod &&
                    newSelection == ReportPeriod.custom) {
                  _selectCustomRange();
                }
                setState(() => _selectedPeriod = newSelection);
                _refresh();
              },
            ),
          ),
          if (_selectedPeriod == ReportPeriod.custom)
            IconButton(
              icon: const Icon(Icons.calendar_today_outlined, size: 20),
              onPressed: _selectCustomRange,
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _skeletonCard(100)),
            const SizedBox(width: 12),
            Expanded(child: _skeletonCard(100)),
          ],
        ),
        const SizedBox(height: 24),
        _skeletonCard(180),
        const SizedBox(height: 24),
        _skeletonCard(200),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bar_chart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No data yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create orders to see reports',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(DashboardMetrics metrics) {
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
          _formatShortCurrency(metrics.totalRevenue),
          Colors.deepPurple,
        ),
        _summaryCard(
          Icons.receipt_long,
          'Orders',
          '${metrics.totalOrders}',
          Colors.blue,
        ),
        _summaryCard(
          Icons.account_balance_wallet,
          'Balance',
          _formatShortCurrency(metrics.outstandingBalances),
          Colors.orange,
        ),
        _summaryCard(
          Icons.local_shipping,
          'Pending',
          '${metrics.pendingDeliveries}',
          Colors.red,
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

  Widget _buildRevenueChart(List<DailySale> dailySales) {
    if (dailySales.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Revenue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'No revenue data for this period',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      );
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
              'Revenue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _periodLabel,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: dailySales.asMap().entries.map((entry) {
                  final sale = entry.value;
                  final barHeight = (sale.totalRevenue / maxValue) * 120;
                  final displayDate = sale.date.length >= 5
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
                          child: BarLabel(
                            amount: sale.totalRevenue > 0
                                ? _formatShortCurrency(sale.totalRevenue)
                                : '',
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

  Widget _buildTopProducts(List<TopProduct> topProducts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Best Selling Products',
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
                    subtitle: Text('${product.totalOrders} sold'),
                    trailing: Text(
                      _formatCurrency(product.totalRevenue),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCustomers(List<CustomerSummary> topCustomers) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Customers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (topCustomers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No customer data',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topCustomers.length,
                itemBuilder: (context, index) {
                  final customer = topCustomers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        customer.customerName.isNotEmpty
                            ? customer.customerName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(customer.customerName),
                    subtitle: Text(
                      '${customer.phone}\n${customer.totalOrders} orders',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                    ),
                    trailing: Text(
                      _formatShortCurrency(customer.totalSpent),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(List<Order> recentOrders) {
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
      case 'Confirmed':
        return Colors.lightBlue;
      case 'Preparing':
        return Colors.purple;
      case 'Ready for Pickup':
        return Colors.teal;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class BarLabel extends StatelessWidget {
  final String amount;

  const BarLabel({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    if (amount.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.topCenter,
      child: Text(
        amount,
        style: TextStyle(
          fontSize: 8,
          color: Colors.deepPurple.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}