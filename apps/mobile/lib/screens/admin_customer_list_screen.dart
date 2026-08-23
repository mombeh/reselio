import 'package:flutter/material.dart';
import 'package:mobile/models/customer.dart';
import 'package:mobile/router/app_router.dart';
import 'package:mobile/services/auth_service.dart';

class AdminCustomerListScreen extends StatefulWidget {
  final AuthService authService;

  const AdminCustomerListScreen({super.key, required this.authService});

  @override
  State<AdminCustomerListScreen> createState() => _AdminCustomerListScreenState();
}

class _AdminCustomerListScreenState extends State<AdminCustomerListScreen> {
  late Future<List<Customer>> _customersFuture;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _loadCustomers();
  }

  void _loadCustomers() {
    setState(() {
      _customersFuture = widget.authService.apiService.getAdminCustomers();
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _customersFuture = widget.authService.apiService.getAdminCustomers();
    });
    await _customersFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F7FA),
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17171C),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Manage customer accounts',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF777780),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 12),
                _buildStatusFilter(),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Customer>>(
              future: _customersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error);
                }

                final customers = snapshot.data ?? [];
                final displayCustomers = _filter(customers);

                if (displayCustomers.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    children: [
                      Text(
                        '${displayCustomers.length} ${displayCustomers.length == 1 ? 'customer' : 'customers'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF777780),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...displayCustomers.map((customer) {
                        return _CustomerCard(
                          customer: customer,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.adminCustomerDetail,
                              arguments: {
                                'authService': widget.authService,
                                'customerId': customer.id,
                              },
                            );
                          },
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Customer> _filter(List<Customer> customers) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty && _selectedStatus == null) {
      return customers;
    }

    return customers.where((customer) {
      final matchesSearch = query.isEmpty ||
          customer.fullName.toLowerCase().contains(query) ||
          customer.phoneNumber.contains(query) ||
          (customer.email != null && customer.email!.toLowerCase().contains(query));

      final matchesStatus = _selectedStatus == null ||
          (_selectedStatus == 'Active' && customer.isActive) ||
          (_selectedStatus == 'Suspended' && !customer.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEAF0)),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search customers...',
          hintStyle: const TextStyle(
            color: Color(0xFF888892),
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF888892),
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFF888892),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      {'label': 'All', 'value': null},
      {'label': 'Active', 'value': 'Active'},
      {'label': 'Suspended', 'value': 'Suspended'},
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final value = status['value'];
          final label = status['label'] as String;
          final isSelected = _selectedStatus == value;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6C4AB6) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? const Color(0xFF6C4AB6) : const Color(0xFFE5E2EB),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF55515F),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: List.generate(5, (index) => _CustomerSkeleton()),
    );
  }

  Widget _buildErrorState(Object? error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),
        Icon(
          Icons.wifi_off_rounded,
          size: 52,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 18),
        Text(
          widget.authService.apiService.getErrorMessage(error),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
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
              backgroundColor: const Color(0xFF6C4AB6),
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

  Widget _buildEmptyState() {
    final hasSearch = _searchController.text.trim().isNotEmpty ||
        _selectedStatus != null;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),
        Icon(
          Icons.people_outline_rounded,
          size: 52,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 18),
        Text(
          hasSearch ? 'No customers found' : 'No customers yet',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF777780),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasSearch
              ? 'Try adjusting your search or filters'
              : 'Customers will appear here when they register',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;

  const _CustomerCard({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = customer.isActive ? Colors.green : Colors.red;
    final statusLabel = customer.isActive ? 'Active' : 'Suspended';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFECEAF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4FD),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                color: const Color(0xFF2589EF),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.fullName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF202027),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customer.phoneNumber,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerSkeleton extends StatelessWidget {
  const _CustomerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
