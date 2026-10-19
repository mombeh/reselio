import 'package:flutter/material.dart';

import 'package:mobile/models/order.dart';
import 'package:mobile/router/app_router.dart';
import 'package:mobile/services/auth_service.dart';

class AdminOrderListScreen extends StatefulWidget {
  final AuthService authService;

  const AdminOrderListScreen({
    super.key,
    required this.authService,
  });

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  late Future<Map<String, dynamic>> _ordersFuture;

  final TextEditingController _searchController =
      TextEditingController();

  String _selectedStatus = '';
  int _currentPage = 1;

  final List<String> _statuses = [
    '',
    'Pending',
    'Confirmed',
    'Preparing',
    'Ready for Pickup',
    'Delivered',
    'Cancelled',
  ];

  static const Color primary = Color(0xFF6C4AB6);
  static const Color background = Color(0xFFF9F7FC);
  static const Color textPrimary = Color(0xFF242029);
  static const Color textSecondary = Color(0xFF77727F);

  @override
  void initState() {
    super.initState();

    _ordersFuture = _fetchOrders();

    _searchController.addListener(() {
      _currentPage = 1;
      _loadOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchOrders() {
    return widget.authService.apiService.getAdminOrders(
      status: _selectedStatus.isEmpty ? null : _selectedStatus,
      search: _searchController.text.isEmpty
          ? null
          : _searchController.text,
      page: _currentPage,
      limit: 10,
    );
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = _fetchOrders();
    });
  }

  Future<void> _refresh() async {
    _currentPage = 1;

    setState(() {
      _ordersFuture = _fetchOrders();
    });

    await _ordersFuture;
  }

  void _selectStatus(String status) {
    if (_selectedStatus == status) return;

    setState(() {
      _selectedStatus = status;
      _currentPage = 1;
      _ordersFuture = _fetchOrders();
    });
  }

  void _openOrder(Order order) {
    Navigator.pushNamed(
      context,
      AppRouter.orderDetail,
      arguments: {
        'authService': widget.authService,
        'order': order,
      },
    ).then((result) {
      if (result == true) {
        _refresh();
      }
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFF59E0B);

      case 'Confirmed':
        return const Color(0xFF3B82F6);

      case 'Preparing':
        return const Color(0xFF8B5CF6);

      case 'Ready for Pickup':
        return const Color(0xFF0D9488);

      case 'Delivered':
        return const Color(0xFF16A34A);

      case 'Cancelled':
        return const Color(0xFFDC2626);

      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.schedule_rounded;

      case 'Confirmed':
        return Icons.check_circle_outline_rounded;

      case 'Preparing':
        return Icons.inventory_2_outlined;

      case 'Ready for Pickup':
        return Icons.local_shipping_outlined;

      case 'Delivered':
        return Icons.done_all_rounded;

      case 'Cancelled':
        return Icons.cancel_outlined;

      default:
        return Icons.receipt_long_outlined;
    }
  }

  String _formatAmount(double amount) {
    return '${amount.toStringAsFixed(0)} FCFA';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Orders',
              style: TextStyle(
                color: textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Manage orders across all sellers',
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: const [],
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          _buildStatusFilters(),
          const SizedBox(height: 8),
          Expanded(
            child: _buildOrders(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search by order number...',
            hintStyle: const TextStyle(
              color: textSecondary,
              fontSize: 13,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: textSecondary,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: textSecondary,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilters() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _statuses.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = _statuses[index];
          final isSelected = _selectedStatus == status;

          return GestureDetector(
            onTap: () => _selectStatus(status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected ? primary : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? primary
                      : Colors.grey.shade200,
                ),
              ),
              child: Text(
                status.isEmpty ? 'All Orders' : status,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : textSecondary,
                  fontSize: 11,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrders() {
    return RefreshIndicator(
      color: primary,
      onRefresh: _refresh,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
                  ConnectionState.waiting &&
              snapshot.data == null) {
            return _buildLoading();
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error);
          }

          final result = snapshot.data ?? {};

          final orders =
              result['orders'] as List<Order>? ?? [];

          if (orders.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              110,
            ),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(orders[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _statusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openOrder(order),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: primary,
                        size: 22,
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
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(
                      order.status,
                      statusColor,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  height: 1,
                  color: Colors.grey.shade100,
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _orderInfo(
                        icon: Icons.payments_outlined,
                        label: 'Total',
                        value: _formatAmount(order.total),
                      ),
                    ),
                    Expanded(
                      child: _orderInfo(
                        icon: Icons.person_outline_rounded,
                        label: 'Customer',
                        value: order.customerName,
                      ),
                    ),
                    Expanded(
                      child: _orderInfo(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: _formatDate(order.createdAt),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: textSecondary,
                      size: 22,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    String status,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _statusIcon(status),
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: textSecondary,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final hasFilters = _searchController.text.isNotEmpty ||
        _selectedStatus.isNotEmpty;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.22,
        ),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.receipt_long_outlined,
            size: 42,
            color: primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          hasFilters
              ? 'No orders found'
              : 'No orders found',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasFilters
              ? 'Try changing your search or status filter.'
              : 'No orders have been placed yet.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildError(Object? error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.20,
        ),
        const Icon(
          Icons.wifi_off_rounded,
          size: 52,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        const Text(
          'Unable to load orders',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.authService.apiService.getErrorMessage(error),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: _loadOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: 5,
      itemBuilder: (_, _) {
        return Container(
          height: 145,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _SkeletonBox(
                      width: 46,
                      height: 46,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          _SkeletonBox(
                            width: double.infinity,
                            height: 13,
                          ),
                          SizedBox(height: 8),
                          _SkeletonBox(
                            width: 120,
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 22),
                _SkeletonBox(
                  width: double.infinity,
                  height: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonBox({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
