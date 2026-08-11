import 'package:flutter/material.dart';
import 'package:mobile/models/customer.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/router/app_router.dart';

class CustomerListScreen extends StatefulWidget {
  final AuthService authService;

  const CustomerListScreen({
    super.key,
    required this.authService,
  });

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  late Future<List> _customersFuture;

  final TextEditingController _searchController =
      TextEditingController();

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    _customersFuture =
        widget.authService.apiService.getCustomers();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List _filter(List customers) {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return customers;
    }

    return customers.where((customer) {
      return customer.fullName
              .toLowerCase()
              .contains(query) ||
          customer.phoneNumber.contains(query) ||
          (customer.email != null &&
              customer.email!.toLowerCase().contains(query));
    }).toList();
  }

  void _refresh() {
    setState(() {
      _customersFuture =
          widget.authService.apiService.getCustomers();
    });
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
          'Are you sure you want to delete "${customer.fullName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await widget.authService.apiService
          .deleteCustomer(customer.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${customer.fullName} deleted'),
          backgroundColor: Colors.red,
        ),
      );

      _refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.authService.apiService.getErrorMessage(e),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openCustomer(Customer customer) {
    Navigator.pushNamed(
      context,
      AppRouter.customerDetail,
      arguments: {
        'authService': widget.authService,
        'customer': customer,
      },
    ).then((result) {
      if (result == true) {
        _refresh();
      }
    });
  }

  void _editCustomer(Customer customer) {
    Navigator.pushNamed(
      context,
      AppRouter.addCustomer,
      arguments: {
        'authService': widget.authService,
        'customer': customer,
      },
    ).then((result) {
      if (result == true) {
        _refresh();
      }
    });
  }

  void _addCustomer() {
    Navigator.pushNamed(
      context,
      AppRouter.addCustomer,
      arguments: {
        'authService': widget.authService,
      },
    ).then((result) {
      if (result == true) {
        _refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search customers...',
                  border: InputBorder.none,
                ),
              )
            : const Text('Customers'),
        actions: [
          IconButton(
            tooltip: _isSearching
                ? 'Close search'
                : 'Search customers',
            icon: Icon(
              _isSearching
                  ? Icons.close
                  : Icons.search,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;

                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refresh();
        },
        child: FutureBuilder<List>(
          future: _customersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error);
            }

            final customers = snapshot.data ?? [];
            final displayCustomers = _filter(customers);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(
                  totalCustomers: customers.length,
                  visibleCustomers: displayCustomers.length,
                ),

                Expanded(
                  child: displayCustomers.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            4,
                            16,
                            100,
                          ),
                          itemCount: displayCustomers.length,
                          itemBuilder: (context, index) {
                            final customer =
                                displayCustomers[index];

                            return _buildCustomerCard(
                              customer,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCustomer,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Customer'),
      ),
    );
  }

  Widget _buildHeader({
    required int totalCustomers,
    required int visibleCustomers,
  }) {
    final isFiltering =
        _searchController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Customers',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isFiltering
                      ? '$visibleCustomers customers found'
                      : '$totalCustomers customers',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.people_outline,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    final initial = customer.fullName.isNotEmpty
        ? customer.fullName[0].toUpperCase()
        : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openCustomer(customer),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.blue.shade50,
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 15,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            customer.phoneNumber,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (customer.email != null &&
                        customer.email!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 15,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              customer.email!,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _editCustomer(customer);
                  } else if (value == 'delete') {
                    _deleteCustomer(customer);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(
                        Icons.edit_outlined,
                      ),
                      title: Text('Edit'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      title: Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch =
        _searchController.text.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch
                    ? Icons.search_off_outlined
                    : Icons.people_outline,
                size: 48,
                color: Colors.blue.shade400,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              hasSearch
                  ? 'No customers found'
                  : 'No customers yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              hasSearch
                  ? 'Try searching with a different name or phone number.'
                  : 'Add your first customer to start managing your orders.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),

            if (!hasSearch) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _addCustomer,
                icon: const Icon(
                  Icons.person_add_outlined,
                ),
                label: const Text('Add Customer'),
              ),
            ],
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
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load customers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.authService.apiService
                  .getErrorMessage(error),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}