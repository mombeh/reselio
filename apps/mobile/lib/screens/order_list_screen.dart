import 'package:flutter/material.dart';
import 'package:mobile/models/order.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/router/app_router.dart';

class OrderListScreen extends StatefulWidget {
  final AuthService authService;

  const OrderListScreen({super.key, required this.authService});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late Future<Map<String, dynamic>> _ordersFuture;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '';
  int _currentPage = 1;

  final List<String> _statuses = [
    '',
    'Pending',
    'Waiting for Supplier',
    'Supplier Shipped',
    'Received',
    'Sent to Customer',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
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

  Future<Map<String, dynamic>> _loadOrders() {
    setState(() {
      _ordersFuture = widget.authService.apiService.getOrders(
        status: _selectedStatus.isEmpty ? null : _selectedStatus,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        page: _currentPage,
        limit: 10,
      );
    });
    return _ordersFuture;
  }

  Future<void> _refresh() async {
    _currentPage = 1;
    await _loadOrders();
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.createOrder,
                arguments: {'authService': widget.authService},
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search order #...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedStatus,
                  hint: const Text('Status'),
                  items: _statuses
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.isEmpty ? 'All' : status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                      _currentPage = 1;
                      _loadOrders();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<Map<String, dynamic>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                final result = snapshot.data ?? {};
                final orders = result['orders'] as List<Order>? ?? [];


                  if (orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.receipt_long_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty || _selectedStatus.isNotEmpty
                                ? 'No orders found'
                                : 'No orders yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap + to create your first order',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        child: ListTile(
                          title: Text(order.orderNumber),
                          subtitle: Text(
                            '${order.customerName} • \$${order.total.toStringAsFixed(2)}',
                          ),
                          trailing: Chip(
                            label: Text(
                              order.status,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            backgroundColor: _statusColor(order.status),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.orderDetail,
                              arguments: {
                                'authService': widget.authService,
                                'order': order,
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRouter.createOrder,
            arguments: {'authService': widget.authService},
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}