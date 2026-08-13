import 'package:flutter/material.dart';
import 'package:mobile/models/customer.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/services/auth_service.dart';

class CreateOrderScreen extends StatefulWidget {
  final AuthService authService;
  final List<Map<String, dynamic>>? initialItems;

  const CreateOrderScreen({
    super.key,
    required this.authService,
    this.initialItems,
  });

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  late Future<List<Customer>> _customersFuture;
  late Future<List<Product>> _productsFuture;

  Customer? _selectedCustomer;
  final List<OrderItemData> _items = [];

  final TextEditingController _advanceController =
      TextEditingController();

  String? _error;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _customersFuture =
        widget.authService.apiService.getCustomersForOrder();

    _productsFuture =
        widget.authService.apiService.getProducts();

    if (widget.initialItems != null) {
      for (final item in widget.initialItems!) {
        _items.add(
          OrderItemData(
            productId: item['productId'] as String,
            productName: item['productName'] as String,
            unitPrice: (item['unitPrice'] as num).toDouble(),
            quantity: item['quantity'] as int,
            productImageUrl: item['productImageUrl'] as String?,
          ),
        );
      }
    }

    _advanceController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _advanceController.dispose();
    super.dispose();
  }

  double get _subtotal =>
      _items.fold(0, (sum, item) => sum + item.total);

  double get _total => _subtotal;

  double get _advance =>
      double.tryParse(_advanceController.text.trim()) ?? 0;

  double get _balance => _total - _advance;

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} FCFA';
  }

  void _addItem(Product product) {
    final existing = _items.firstWhereOrNull(
      (item) => item.productId == product.id,
    );

    if (existing != null) {
      if (existing.quantity < product.quantity) {
        setState(() {
          existing.quantity++;
        });
      }
      return;
    }

    setState(() {
      _items.add(
        OrderItemData(
          productId: product.id,
          productName: product.name,
          unitPrice: product.price,
          quantity: 1,
          productImageUrl: product.imageUrl,
        ),
      );
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateQuantity(int index, int delta) {
    final newQty = _items[index].quantity + delta;

    if (newQty <= 0) {
      _removeItem(index);
      return;
    }

    setState(() {
      _items[index].quantity = newQty;
    });
  }

  Future<void> _submit() async {
    if (_selectedCustomer == null) {
      setState(() {
        _error = 'Please select a customer';
      });
      return;
    }

    if (_items.isEmpty) {
      setState(() {
        _error = 'Please add at least one product';
      });
      return;
    }

    if (_advance < 0 || _advance > _total) {
      setState(() {
        _error =
            'Advance paid cannot be greater than the order total.';
      });
      return;
    }

    final products = await _productsFuture;
    final productMap = {
      for (final product in products) product.id: product,
    };

    for (final item in _items) {
      final product = productMap[item.productId];

      if (product != null && item.quantity > product.quantity) {
        setState(() {
          _error =
              'Insufficient stock for ${item.productName}. '
              'Available: ${product.quantity}';
        });
        return;
      }
    }

    setState(() {
      _error = null;
      _isSubmitting = true;
    });

    try {
      final items = _items
          .map(
            (item) => {
              'productId': item.productId,
              'quantity': item.quantity,
            },
          )
          .toList();

      await widget.authService.apiService.createOrder(
        customerId: _selectedCustomer!.id,
        items: items,
        advancePaid: _advance,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order created successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error =
            widget.authService.apiService.getErrorMessage(e);
        _isSubmitting = false;
      });
    }
  }

  void _showCustomerPicker(List<Customer> customers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Customer',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: customers.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final customer = customers[index];

                    final selected =
                        _selectedCustomer?.id == customer.id;

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setState(() {
                          _selectedCustomer = customer;
                        });

                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.deepPurple.withValues(
                                  alpha: 0.08,
                                )
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? Colors.deepPurple
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  Colors.deepPurple.shade50,
                              child: const Icon(
                                Icons.person_outline,
                                color: Colors.deepPurple,
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    customer.phoneNumber,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.deepPurple,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Order',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Create a new customer order',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _items.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  16,
                ),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Create Order',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            )
          : null,

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (_error != null) ...[
            _buildErrorCard(),
            const SizedBox(height: 16),
          ],

          _buildCustomerSection(),

          const SizedBox(height: 24),

          _buildProductsSection(),

          if (_items.isNotEmpty) ...[
            const SizedBox(height: 28),
            _buildOrderItemsSection(),
            const SizedBox(height: 20),
            _buildPaymentSummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection() {
    return FutureBuilder<List<Customer>>(
      future: _customersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return _buildSectionCard(
            child: const SizedBox(
              height: 80,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildSectionCard(
            child: Column(
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 38,
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.authService.apiService
                      .getErrorMessage(snapshot.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _customersFuture = widget
                          .authService
                          .apiService
                          .getCustomersForOrder();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final customers = snapshot.data ?? [];

        if (customers.isEmpty) {
          return _buildSectionCard(
            child: const Column(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 42,
                  color: Colors.grey,
                ),
                SizedBox(height: 10),
                Text(
                  'No customers found',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showCustomerPicker(customers),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedCustomer != null
                        ? Colors.deepPurple.withValues(alpha: 0.4)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor:
                          Colors.deepPurple.shade50,
                      child: Icon(
                        _selectedCustomer == null
                            ? Icons.person_add_alt_1
                            : Icons.person,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _selectedCustomer == null
                          ? const Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select a customer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Choose who this order is for',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedCustomer!.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedCustomer!.phoneNumber,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductsSection() {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return _buildSectionCard(
            child: Column(
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 38,
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.authService.apiService
                      .getErrorMessage(snapshot.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _productsFuture = widget
                          .authService
                          .apiService
                          .getProducts();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return _buildSectionCard(
            child: const Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 42,
                  color: Colors.grey,
                ),
                SizedBox(height: 10),
                Text(
                  'No products available',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_items.length} selected',
                  style: TextStyle(
                    color: Colors.deepPurple.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _buildProductCard(products[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final inOrder = _items.any(
      (item) => item.productId == product.id,
    );

    final isOutOfStock = product.quantity <= 0;

    return SizedBox(
      width: 155,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: inOrder
                ? Colors.deepPurple
                : Colors.grey.shade200,
            width: inOrder ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isOutOfStock
              ? null
              : () => _addItem(product),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: product.imageUrl != null &&
                            product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatCurrency(product.price),
                  style: TextStyle(
                    color: Colors.deepPurple.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isOutOfStock
                            ? 'Out of stock'
                            : '${product.quantity} in stock',
                        style: TextStyle(
                          color: isOutOfStock
                              ? Colors.red
                              : Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Icon(
                      inOrder
                          ? Icons.check_circle
                          : isOutOfStock
                              ? Icons.block
                              : Icons.add_circle,
                      size: 20,
                      color: inOrder
                          ? Colors.green
                          : isOutOfStock
                              ? Colors.grey
                              : Colors.deepPurple,
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

  Widget _buildOrderItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Order',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          _items.length,
          (index) => _buildOrderItemCard(
            _items[index],
            index,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemCard(
    OrderItemData item,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.productImageUrl != null &&
                    item.productImageUrl!.isNotEmpty
                ? Image.network(
                    item.productImageUrl!,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) {
                      return Container(
                        width: 58,
                        height: 58,
                        color: Colors.grey.shade100,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                : Container(
                    width: 58,
                    height: 58,
                    color: Colors.grey.shade100,
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.grey,
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
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(item.unitPrice),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _quantityButton(
                        icon: Icons.remove,
                        onTap: () =>
                            _updateQuantity(index, -1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _quantityButton(
                        icon: Icons.add,
                        onTap: () =>
                            _updateQuantity(index, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => _removeItem(index),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
              Text(
                _formatCurrency(item.total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Icon(
          icon,
          size: 16,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade700,
            Colors.deepPurple.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          _summaryRow(
            'Subtotal',
            _formatCurrency(_subtotal),
          ),
          const SizedBox(height: 10),
          _summaryRow(
            'Total',
            _formatCurrency(_total),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _advanceController,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              labelText: 'Advance Paid',
              labelStyle: const TextStyle(
                color: Colors.white70,
              ),
              prefixIcon: const Icon(
                Icons.payments_outlined,
                color: Colors.white70,
              ),
              suffixText: 'FCFA',
              suffixStyle: const TextStyle(
                color: Colors.white70,
              ),
              filled: true,
              fillColor: Colors.white.withValues(
                alpha: 0.12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Balance Due',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatCurrency(_balance < 0 ? 0 : _balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: child,
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   // This second build method should not be present.
  //   throw UnimplementedError();
  // }
}

class OrderItemData {
  final String productId;
  final String productName;
  final double unitPrice;
  int quantity;
  final String? productImageUrl;

  OrderItemData({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.productImageUrl,
  });

  double get total => unitPrice * quantity;
}

extension FirstWhereOrNullExtension<E> on List<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}