import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';

class AdminReportsScreen extends StatefulWidget {
  final AuthService authService;

  const AdminReportsScreen({super.key, required this.authService});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

enum AdminReportPeriod {
  today,
  week,
  month,
  year,
  custom,
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  late Future<Map<String, dynamic>> _overviewFuture;
  late Future<List<Map<String, dynamic>>> _statusFuture;
  late Future<List<Map<String, dynamic>>> _dailySalesFuture;
  late Future<List<Map<String, dynamic>>> _topProductsFuture;
  late Future<List<Map<String, dynamic>>> _customerReportFuture;

  AdminReportPeriod _selectedPeriod = AdminReportPeriod.month;
  DateTimeRange? _customRange;

  static const Color primary = Color(0xFF6C4AB6);
  static const Color success = Color(0xFF2E9B68);
  static const Color background = Color(0xFFF7F7FA);

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  // String get _periodParam {
  //   switch (_selectedPeriod) {
  //     case AdminReportPeriod.today:
  //       return 'today';
  //     case AdminReportPeriod.week:
  //       return 'week';
  //     case AdminReportPeriod.month:
  //       return 'month';
  //     case AdminReportPeriod.year:
  //       return 'year';
  //     case AdminReportPeriod.custom:
  //       return 'custom';
  //   }
  // }

  String get _periodLabel {
    switch (_selectedPeriod) {
      case AdminReportPeriod.today:
        return 'Today';
      case AdminReportPeriod.week:
        return 'This Week';
      case AdminReportPeriod.month:
        return 'This Month';
      case AdminReportPeriod.year:
        return 'This Year';
      case AdminReportPeriod.custom:
        if (_customRange != null) {
          return '${_customRange!.start.day}/${_customRange!.start.month} - ${_customRange!.end.day}/${_customRange!.end.month}';
        }
        return 'Custom Range';
    }
  }

  void _loadReports() {
    setState(() {
      _overviewFuture = widget.authService.apiService.getAdminReportsOverview();
      _statusFuture = widget.authService.apiService.getAdminOrderStatusBreakdown();
      _dailySalesFuture = widget.authService.apiService.getAdminDailySales(
        days: _selectedPeriod == AdminReportPeriod.today ? 1 : _selectedPeriod == AdminReportPeriod.week ? 7 : _selectedPeriod == AdminReportPeriod.month ? 30 : 365,
      );
      _topProductsFuture = widget.authService.apiService.getAdminTopProducts(limit: 5);
      _customerReportFuture = widget.authService.apiService.getAdminCustomerReport();
    });
  }

  Future<void> _refresh() async {
    _loadReports();
    await Future.wait([
      _overviewFuture,
      _statusFuture,
      _dailySalesFuture,
      _topProductsFuture,
      _customerReportFuture,
    ]);
  }

  Future<void> _selectCustomRange() async {
    final now = DateTime.now();
    final initialDateRange = _customRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 29)),
          end: now,
        );

    final result = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );

    if (result == null) return;

    setState(() {
      _customRange = result;
      _selectedPeriod = AdminReportPeriod.custom;
      _loadReports();
    });
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
          'Platform Reports',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF17171C),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: RefreshIndicator(
              color: primary,
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                children: [
                  _buildOverviewSection(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Revenue Trend'),
                  const SizedBox(height: 12),
                  _buildRevenueChart(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Order Status'),
                  const SizedBox(height: 12),
                  _buildOrderStatusSection(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Top Products'),
                  const SizedBox(height: 12),
                  _buildTopProductsSection(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Top Customers'),
                  const SizedBox(height: 12),
                  _buildTopCustomersSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _periodChip(label: 'Today', period: AdminReportPeriod.today),
            const SizedBox(width: 8),
            _periodChip(label: '7 Days', period: AdminReportPeriod.week),
            const SizedBox(width: 8),
            _periodChip(label: '30 Days', period: AdminReportPeriod.month),
            const SizedBox(width: 8),
            _periodChip(label: 'Year', period: AdminReportPeriod.year),
            const SizedBox(width: 8),
            _periodChip(label: 'Custom', period: AdminReportPeriod.custom, icon: Icons.calendar_today_outlined),
          ],
        ),
      ),
    );
  }

  Widget _periodChip({required String label, required AdminReportPeriod period, IconData? icon}) {
    final selected = _selectedPeriod == period;
    return InkWell(
      onTap: () async {
        if (period == AdminReportPeriod.custom) {
          await _selectCustomRange();
          return;
        }
        setState(() {
          _selectedPeriod = period;
          _loadReports();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: selected ? Colors.white : Colors.grey.shade600),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
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

  Widget _buildOverviewSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _overviewFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
          return _buildOverviewSkeleton();
        }

        if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error);
        }

        final data = snapshot.data ?? {};
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFECEAF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _overviewMetric(Icons.people_outline_rounded, 'Total Users', '${data['totalUsers'] ?? 0}', Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _overviewMetric(Icons.store_outlined, 'Sellers', '${data['totalSellers'] ?? 0}', primary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _overviewMetric(Icons.person_outlined, 'Customers', '${data['totalCustomers'] ?? 0}', Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _overviewMetric(Icons.inventory_2_outlined, 'Products', '${data['totalProducts'] ?? 0}', Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _overviewMetric(Icons.shopping_bag_outlined, 'Orders', '${data['totalOrders'] ?? 0}', Colors.purple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _overviewMetric(Icons.pending_actions_rounded, 'Pending', '${data['pendingOrders'] ?? 0}', Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _overviewMetric(Icons.payments_outlined, 'Total Revenue', '${(data['totalRevenue'] ?? 0).toStringAsFixed(0)} FCFA', success),
            ],
          ),
        );
      },
    );
  }

  Widget _overviewMetric(IconData icon, String title, String value, Color color) {
    return Row(
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF202027),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF777780),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECEAF0)),
      ),
      child: Column(
        children: [
          Row(children: [Expanded(child: _skeleton(60)), const SizedBox(width: 12), Expanded(child: _skeleton(60))]),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: _skeleton(60)), const SizedBox(width: 12), Expanded(child: _skeleton(60))]),
          const SizedBox(height: 16),
          Row(children: [Expanded(child: _skeleton(60)), const SizedBox(width: 12), Expanded(child: _skeleton(60))]),
          const SizedBox(height: 16),
          _skeleton(40),
        ],
      ),
    );
  }

  Widget _buildOrderStatusSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _statusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
          return _buildStatusSkeleton();
        }

        if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error);
        }

        final statuses = snapshot.data ?? [];
        if (statuses.isEmpty) {
          return _buildEmptyCard('No order data', Icons.receipt_long_outlined);
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFECEAF0)),
          ),
          child: Column(
            children: statuses.map((status) {
              final color = _statusColor(status['_id'] ?? '');
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        status['_id'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${status['count'] ?? 0}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(status['totalRevenue'] ?? 0).toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStatusSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECEAF0)),
      ),
      child: Column(
        children: List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 12),
              Expanded(child: _skeleton(80)),
              const SizedBox(width: 12),
              _skeleton(40),
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dailySalesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
          return _buildChartSkeleton();
        }

        if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error);
        }

        final sales = snapshot.data ?? [];
        if (sales.isEmpty) {
          return _buildEmptyCard('No revenue data for this period', Icons.bar_chart_outlined);
        }

        final maxRevenue = sales.map((s) => s['totalRevenue'] ?? 0).reduce((a, b) => a > b ? a : b) * 1.1;
        final maxValue = maxRevenue > 0 ? maxRevenue : 1.0;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFECEAF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daily Revenue',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    _periodLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                child: sales.isEmpty
                    ? const Center(child: Text('No data'))
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: sales.take(15).map((sale) {
                          final barHeight = ((sale['totalRevenue'] ?? 0) / maxValue) * 125;
                          final date = sale['_id']?.toString() ?? '';
                          final displayDate = date.length >= 5 ? date.substring(date.length - 5) : date;

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    height: 30,
                                    child: (sale['totalRevenue'] ?? 0) > 0
                                        ? Text(
                                            '${((sale['totalRevenue'] ?? 0) / 1000).toStringAsFixed(0)}K',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          )
                                        : null,
                                  ),
                                  Container(
                                    width: 22,
                                    height: barHeight > 3 ? barHeight : 3,
                                    decoration: BoxDecoration(
                                      color: primary.withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    displayDate,
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECEAF0)),
      ),
      child: Column(
        children: [
          _skeleton(20),
          const SizedBox(height: 24),
          _skeleton(180),
        ],
      ),
    );
  }

  Widget _buildTopProductsSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _topProductsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
          return _buildProductsSkeleton();
        }

        if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error);
        }

        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return _buildEmptyCard('No products sold yet', Icons.inventory_2_outlined);
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFECEAF0)),
          ),
          child: Column(
            children: products.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] ?? 'Unknown',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${product['unitsSold'] ?? 0} sold',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${(product['revenue'] ?? 0).toStringAsFixed(0)} FCFA',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ],
                  ),
                  if (index != products.length - 1)
                    Divider(height: 20, color: Colors.grey.shade200),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildProductsSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECEAF0)),
      ),
      child: Column(
        children: List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              _skeleton(34),
              const SizedBox(width: 12),
              Expanded(child: _skeleton(60)),
              _skeleton(60),
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildTopCustomersSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _customerReportFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
          return _buildCustomersSkeleton();
        }

        if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error);
        }

        final customers = snapshot.data ?? [];
        if (customers.isEmpty) {
          return _buildEmptyCard('No customer data', Icons.people_outline_rounded);
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFECEAF0)),
          ),
          child: Column(
            children: customers.asMap().entries.map((entry) {
              final index = entry.key;
              final customer = entry.value;
              final initials = (customer['customerName'] ?? '?').toString().trim().isNotEmpty
                  ? (customer['customerName'] ?? '?').toString().trim()[0].toUpperCase()
                  : '?';

              return Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: primary.withValues(alpha: 0.10),
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer['customerName'] ?? 'Unknown',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${customer['totalOrders'] ?? 0} orders',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${(customer['totalSpent'] ?? 0).toStringAsFixed(0)} FCFA',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ],
                  ),
                  if (index != customers.length - 1)
                    Divider(height: 20, color: Colors.grey.shade200),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCustomersSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECEAF0)),
      ),
      child: Column(
        children: List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              _skeleton(40),
              const SizedBox(width: 12),
              Expanded(child: _skeleton(80)),
              _skeleton(80),
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildErrorCard(Object? error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, size: 36, color: Colors.red.shade400),
          const SizedBox(height: 12),
          Text(
            widget.authService.apiService.getErrorMessage(error),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECEAF0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _skeleton(double width) {
    return Container(
      width: width,
      height: 14,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'preparing':
      case 'ready for pickup':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
