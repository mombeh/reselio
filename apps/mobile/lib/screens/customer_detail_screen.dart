import 'package:flutter/material.dart';
import 'package:mobile/models/customer.dart';
import 'package:mobile/models/order.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/router/app_router.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;
  final AuthService? authService;

  const CustomerDetailScreen({
    super.key,
    required this.customer,
    this.authService,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late Future<Map<String, dynamic>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _ordersFuture =
        widget.authService?.apiService.getOrdersByCustomer(widget.customer.id) ??
            Future.value({
              'orders': <Order>[],
              'total': 0,
              'totalPages': 0,
            });
  }

  void _refreshOrders() {
    setState(() {
      _loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final theme = Theme.of(context);

    final initials = customer.fullName.trim().isNotEmpty
        ? customer.fullName.trim()[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customer Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (widget.authService != null)
            IconButton(
              tooltip: 'Edit customer',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  AppRouter.addCustomer,
                  arguments: {
                    'authService': widget.authService,
                    'customer': widget.customer,
                  },
                );

                if (!mounted) return;

                _refreshOrders();
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshOrders();
          await _ordersFuture;
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            // --------------------------------------------------------
            // CUSTOMER HEADER
            // --------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    customer.fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    customer.phoneNumber,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  if (customer.email != null &&
                      customer.email!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      customer.email!,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Quick actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildQuickAction(
                        icon: Icons.phone_outlined,
                        label: 'Call',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Calling functionality will be connected later.',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildQuickAction(
                        icon: Icons.message_outlined,
                        label: 'Message',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Messaging functionality will be connected later.',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------------
            // CUSTOMER INFORMATION
            // --------------------------------------------------------
            const Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.phone_outlined,
              iconColor: Colors.green,
              title: 'Phone Number',
              value: customer.phoneNumber,
            ),

            if (customer.email != null && customer.email!.isNotEmpty)
              _buildInfoCard(
                icon: Icons.email_outlined,
                iconColor: Colors.blue,
                title: 'Email',
                value: customer.email!,
              ),

            if (customer.address != null && customer.address!.isNotEmpty)
              _buildInfoCard(
                icon: Icons.location_on_outlined,
                iconColor: Colors.red,
                title: 'Address',
                value: customer.address!,
              ),

            if (customer.notes != null && customer.notes!.isNotEmpty)
              _buildInfoCard(
                icon: Icons.notes_outlined,
                iconColor: Colors.orange,
                title: 'Notes',
                value: customer.notes!,
              ),

            _buildInfoCard(
              icon: Icons.calendar_today_outlined,
              iconColor: Colors.grey,
              title: 'Customer Since',
              value: customer.createdAt != null
                  ? '${customer.createdAt!.day}/${customer.createdAt!.month}/${customer.createdAt!.year}'
                  : 'N/A',
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------------
            // PURCHASE HISTORY HEADER
            // --------------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Purchase History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                FutureBuilder<Map<String, dynamic>>(
                  future: _ordersFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final total = snapshot.data?['total'] as int? ?? 0;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$total ${total == 1 ? 'order' : 'orders'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------------
            // PURCHASE HISTORY
            // --------------------------------------------------------
            FutureBuilder<Map<String, dynamic>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.red.shade100,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 42,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.authService != null
                              ? widget.authService!.apiService
                                  .getErrorMessage(snapshot.error)
                              : 'Unable to load purchase history',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: _refreshOrders,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final orders =
                    snapshot.data?['orders'] as List<Order>? ?? [];

                if (orders.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 54,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No purchase history',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Orders placed by this customer will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: orders.map((order) {
                    final statusColor = _getStatusColor(order.status);
                    final statusIcon = _getStatusIcon(order.status);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.025),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Status icon
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              statusIcon,
                              color: statusColor,
                              size: 22,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Order information
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.orderNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${order.total.toStringAsFixed(2)} FCFA',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _formatDate(order.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Status
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.status,
                              style: TextStyle(
                                fontSize: 10,
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  // QUICK ACTION
  // --------------------------------------------------------------
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  // INFORMATION CARD
  // --------------------------------------------------------------
  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------
  // ORDER STATUS COLOR
  // --------------------------------------------------------------
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;

      case 'Cancelled':
        return Colors.red;

      case 'Pending':
        return Colors.orange;

      case 'Confirmed':
      case 'Preparing':
      case 'Ready for Pickup':
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  // --------------------------------------------------------------
  // ORDER STATUS ICON
  // --------------------------------------------------------------
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Delivered':
        return Icons.check_circle;

      case 'Cancelled':
        return Icons.cancel;

      case 'Pending':
        return Icons.access_time;

      case 'Ready for Pickup':
        return Icons.local_shipping;

      case 'Preparing':
        return Icons.pending_outlined;

      case 'Confirmed':
        return Icons.verified_outlined;

      default:
        return Icons.shopping_bag;
    }
  }

  // --------------------------------------------------------------
  // DATE FORMAT
  // --------------------------------------------------------------
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    return '${date.day}/${date.month}/${date.year}';
  }
}