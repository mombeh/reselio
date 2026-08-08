import 'package:flutter/material.dart';
import 'package:mobile/models/customer.dart';
import 'package:mobile/models/order.dart';
import 'package:mobile/services/auth_service.dart';

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
    _ordersFuture = widget.authService?.apiService.getOrdersByCustomer(widget.customer.id) ??
        Future.value({'orders': [], 'total': 0, 'totalPages': 0});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.customer.fullName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  widget.customer.fullName.isNotEmpty
                      ? widget.customer.fullName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                widget.customer.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: widget.customer.email != null && widget.customer.email!.isNotEmpty
                  ? Text(widget.customer.email!)
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_outlined, color: Colors.green),
              title: const Text('Phone'),
              subtitle: Text(widget.customer.phoneNumber),
            ),
          ),
          if (widget.customer.email != null && widget.customer.email!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email_outlined, color: Colors.blue),
                title: const Text('Email'),
                subtitle: Text(widget.customer.email!),
              ),
            ),
          ],
          if (widget.customer.address != null && widget.customer.address!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on_outlined, color: Colors.red),
                title: const Text('Address'),
                subtitle: Text(widget.customer.address!),
              ),
            ),
          ],
          if (widget.customer.notes != null && widget.customer.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.notes_outlined, color: Colors.orange),
                title: const Text('Notes'),
                subtitle: Text(widget.customer.notes!),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
              title: const Text('Added'),
              subtitle: Text(
                widget.customer.createdAt != null
                    ? '${widget.customer.createdAt!.day}/${widget.customer.createdAt!.month}/${widget.customer.createdAt!.year}'
                    : 'N/A',
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Purchase History',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          FutureBuilder<Map<String, dynamic>>(
            future: _ordersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading orders: ${snapshot.error}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                );
              }

              final orders = snapshot.data?['orders'] as List<Order>? ?? [];
              final totalOrders = snapshot.data?['total'] as int? ?? 0;

              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No purchase history',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalOrders orders total',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final statusColor = _getStatusColor(order.status);
                      final statusIcon = _getStatusIcon(order.status);

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withValues(alpha: 0.15),
                            child: Icon(statusIcon, color: statusColor, size: 20),
                          ),
                          title: Text(order.orderNumber),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${order.total.toStringAsFixed(2)} FCFA',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(order.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: statusColor, width: 1),
                            ),
                            child: Text(
                              order.status,
                              style: TextStyle(
                                fontSize: 10,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
