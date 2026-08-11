import 'package:flutter/material.dart';
import 'package:mobile/models/customer_summary.dart';
import 'package:mobile/models/daily_sale.dart';
import 'package:mobile/models/dashboard_metrics.dart';
import 'package:mobile/models/order.dart';
import 'package:mobile/models/top_product.dart';
import 'package:mobile/services/auth_service.dart';

class ReportsScreen extends StatefulWidget {
  final AuthService authService;

  const ReportsScreen({
    super.key,
    required this.authService,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

enum ReportPeriod {
  today,
  week,
  month,
  custom,
}

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
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M FCFA';
    }

    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K FCFA';
    }

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
          return _customRange!.end
                  .difference(_customRange!.start)
                  .inDays +
              1;
        }

        return 7;
    }
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
          return '${_customRange!.start.day}/${_customRange!.start.month} - '
              '${_customRange!.end.day}/${_customRange!.end.month}';
        }

        return 'Custom Range';
    }
  }

  Future<Map<String, dynamic>> _loadReport() async {
    final days = _daysForPeriod;

    final metrics =
        await widget.authService.apiService.getDashboardMetrics();

    final dailySales =
        await widget.authService.apiService.getDailySales(days: days);

    final topProducts =
        await widget.authService.apiService.getTopProducts();

    final topCustomers =
        await widget.authService.apiService.getTopCustomers(limit: 5);

    final ordersResult =
        await widget.authService.apiService.getOrders(limit: 5);

    return {
      'metrics': metrics,
      'dailySales': dailySales,
      'topProducts': topProducts,
      'topCustomers': topCustomers,
      'recentOrders': ordersResult['orders'] as List<Order>,
    };
  }

  void _refresh() {
    setState(() {
      _reportFuture = _loadReport();
    });
  }

  Future<void> _selectCustomRange() async {
    final now = DateTime.now();

    final initialDateRange = _customRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 6)),
          end: now,
        );

    final result = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (result == null) return;

    setState(() {
      _customRange = result;
      _selectedPeriod = ReportPeriod.custom;
      _reportFuture = _loadReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _refresh();
                await _reportFuture;
              },
              child: FutureBuilder<Map<String, dynamic>>(
                future: _reportFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                          ConnectionState.waiting &&
                      snapshot.data == null) {
                    return _buildLoadingState();
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error);
                  }

                  final data = snapshot.data ?? {};

                  final metrics =
                      data['metrics'] as DashboardMetrics;

                  final dailySales =
                      (data['dailySales'] as List<dynamic>?)
                              ?.cast<DailySale>() ??
                          <DailySale>[];

                  final topProducts =
                      (data['topProducts'] as List<dynamic>?)
                              ?.cast<TopProduct>() ??
                          <TopProduct>[];

                  final topCustomers =
                      (data['topCustomers'] as List<dynamic>?)
                              ?.cast<CustomerSummary>() ??
                          <CustomerSummary>[];

                  final recentOrders =
                      (data['recentOrders'] as List<dynamic>?)
                              ?.cast<Order>() ??
                          <Order>[];

                  if (dailySales.isEmpty &&
                      recentOrders.isEmpty &&
                      topProducts.isEmpty &&
                      topCustomers.isEmpty) {
                    return _buildEmptyState();
                  }

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      20,
                      16,
                      32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPeriodHeading(),
                        const SizedBox(height: 16),

                        _buildSummaryCards(metrics),

                        const SizedBox(height: 28),

                        _buildSectionHeader(
                          title: 'Revenue Overview',
                          subtitle: _periodLabel,
                          icon: Icons.trending_up_rounded,
                        ),

                        const SizedBox(height: 12),

                        _buildRevenueChart(dailySales),

                        const SizedBox(height: 28),

                        _buildSectionHeader(
                          title: 'Best Selling Products',
                          subtitle: 'Your top performing products',
                          icon: Icons.inventory_2_outlined,
                        ),

                        const SizedBox(height: 12),

                        _buildTopProducts(topProducts),

                        const SizedBox(height: 28),

                        _buildSectionHeader(
                          title: 'Top Customers',
                          subtitle: 'Customers generating the most sales',
                          icon: Icons.people_outline_rounded,
                        ),

                        const SizedBox(height: 12),

                        _buildTopCustomers(topCustomers),

                        const SizedBox(height: 28),

                        _buildSectionHeader(
                          title: 'Recent Orders',
                          subtitle: 'Your latest transactions',
                          icon: Icons.receipt_long_outlined,
                        ),

                        const SizedBox(height: 12),

                        _buildRecentOrders(recentOrders),
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

  Widget _buildPeriodSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _periodChip(
              label: 'Today',
              period: ReportPeriod.today,
            ),
            const SizedBox(width: 8),
            _periodChip(
              label: 'This Week',
              period: ReportPeriod.week,
            ),
            const SizedBox(width: 8),
            _periodChip(
              label: 'This Month',
              period: ReportPeriod.month,
            ),
            const SizedBox(width: 8),
            _periodChip(
              label: 'Custom',
              period: ReportPeriod.custom,
              icon: Icons.calendar_today_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodChip({
    required String label,
    required ReportPeriod period,
    IconData? icon,
  }) {
    final selected = _selectedPeriod == period;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () async {
        if (period == ReportPeriod.custom) {
          await _selectCustomRange();
          return;
        }

        setState(() {
          _selectedPeriod = period;
          _reportFuture = _loadReport();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodHeading() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track how your business is performing',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _periodLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primaryContainer,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(DashboardMetrics metrics) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _summaryCard(
          icon: Icons.payments_outlined,
          title: 'Revenue',
          value: _formatShortCurrency(metrics.totalRevenue),
          color: Colors.deepPurple,
        ),
        _summaryCard(
          icon: Icons.receipt_long_outlined,
          title: 'Orders',
          value: '${metrics.totalOrders}',
          color: Colors.blue,
        ),
        _summaryCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Balance',
          value: _formatShortCurrency(
            metrics.outstandingBalances,
          ),
          color: Colors.orange,
        ),
        _summaryCard(
          icon: Icons.local_shipping_outlined,
          title: 'Pending',
          value: '${metrics.pendingDeliveries}',
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(List<DailySale> dailySales) {
    if (dailySales.isEmpty) {
      return _emptyCard(
        icon: Icons.bar_chart_outlined,
        message: 'No revenue data for this period',
      );
    }

    final maxRevenue = dailySales
            .map((sale) => sale.totalRevenue)
            .reduce((a, b) => a > b ? a : b) *
        1.1;

    final maxValue = maxRevenue > 0 ? maxRevenue : 1.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
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
              Icon(
                Icons.insights_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dailySales.map((sale) {
                final barHeight =
                    (sale.totalRevenue / maxValue) * 125;

                final displayDate = sale.date.length >= 5
                    ? sale.date.substring(
                        sale.date.length - 5,
                      )
                    : sale.date;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 30,
                          child: sale.totalRevenue > 0
                              ? Text(
                                  _formatShortCurrency(
                                    sale.totalRevenue,
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                )
                              : null,
                        ),
                        Container(
                          width: 22,
                          height: barHeight > 3
                              ? barHeight
                              : 3,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.75),
                            borderRadius:
                                BorderRadius.circular(6),
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
  }

  Widget _buildTopProducts(List<TopProduct> topProducts) {
    if (topProducts.isEmpty) {
      return _emptyCard(
        icon: Icons.inventory_2_outlined,
        message: 'No products sold yet',
      );
    }

    return _contentCard(
      child: Column(
        children: topProducts.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;

          return Column(
            children: [
              _productRow(
                rank: index + 1,
                product: product,
              ),
              if (index != topProducts.length - 1)
                Divider(
                  height: 20,
                  color: Colors.grey.shade200,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _productRow({
    required int rank,
    required TopProduct product,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$rank',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
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
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${product.totalOrders} sold',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatCurrency(product.totalRevenue),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildTopCustomers(
    List<CustomerSummary> topCustomers,
  ) {
    if (topCustomers.isEmpty) {
      return _emptyCard(
        icon: Icons.people_outline_rounded,
        message: 'No customer data',
      );
    }

    return _contentCard(
      child: Column(
        children: topCustomers.asMap().entries.map((entry) {
          final index = entry.key;
          final customer = entry.value;

          final initials =
              customer.customerName.trim().isNotEmpty
                  ? customer.customerName
                      .trim()[0]
                      .toUpperCase()
                  : '?';

          return Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${customer.totalOrders} orders • ${customer.phone}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatShortCurrency(
                      customer.totalSpent,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (index != topCustomers.length - 1)
                Divider(
                  height: 22,
                  color: Colors.grey.shade200,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentOrders(List<Order> recentOrders) {
    if (recentOrders.isEmpty) {
      return _emptyCard(
        icon: Icons.receipt_long_outlined,
        message: 'No recent orders',
      );
    }

    return _contentCard(
      child: Column(
        children: recentOrders.asMap().entries.map((entry) {
          final index = entry.key;
          final order = entry.value;

          final statusColor =
              _statusColor(order.status);

          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color:
                          statusColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: statusColor,
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
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          order.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatShortCurrency(order.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (index != recentOrders.length - 1)
                Divider(
                  height: 22,
                  color: Colors.grey.shade200,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _contentCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _emptyCard({
    required IconData icon,
    required String message,
  }) {
    return _contentCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 44,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _skeletonCard(120),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _skeletonCard(120),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _skeletonCard(120),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _skeletonCard(120),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _skeletonCard(230),
        const SizedBox(height: 24),
        _skeletonCard(220),
        const SizedBox(height: 24),
        _skeletonCard(220),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart_rounded,
                size: 42,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No data yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create some orders and start selling to see your business reports here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 38,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Unable to load reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.authService.apiService
                  .getErrorMessage(error),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
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