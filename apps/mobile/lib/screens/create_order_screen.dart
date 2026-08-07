import 'package:flutter/material.dart';
import 'package:mobile/models/customer.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/services/auth_service.dart';

class CreateOrderScreen extends StatefulWidget {
  final AuthService authService;

  const CreateOrderScreen({super.key, required this.authService});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  late Future<List<Customer>> _customersFuture;
  late Future<List<Product>> _productsFuture;
  Customer? _selectedCustomer;
  final List<OrderItemData> _items = [];
  final TextEditingController _advanceController = TextEditingController();
  String? _error;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _customersFuture = widget.authService.apiService.getCustomersForOrder();
    _productsFuture = widget.authService.apiService.getProducts();
  }

  @override
  void dispose() {
    _advanceController.dispose();
    super.dispose();
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);
  double get _total => _subtotal;
  double get _advance => double.tryParse(_advanceController.text.trim()) ?? 0;
  double get _balance => _total - _advance;

  void _addItem(Product product) {
    final existing = _items.firstWhereOrNull((item) => item.productId == product.id);
    if (existing != null) {
      setState(() => existing.quantity++);
    } else {
      setState(() {
        _items.add(OrderItemData(
          productId: product.id,
          productName: product.name,
          unitPrice: product.price,
          quantity: 1,
          productImageUrl: product.imageUrl,
        ));
      });
    }
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  void _updateQuantity(int index, int delta) {
    final newQty = _items[index].quantity + delta;
    if (newQty > 0) {
      setState(() => _items[index].quantity = newQty);
    }
  }

  Future<void> _submit() async {
    if (_selectedCustomer == null) {
      setState(() => _error = 'Please select a customer');
      return;
    }
    if (_items.isEmpty) {
      setState(() => _error = 'Please add at least one product');
      return;
    }

    setState(() {
      _error = null;
      _isSubmitting = true;
    });

    try {
      final items = _items
          .map((item) => {
                'productId': item.productId,
                'quantity': item.quantity,
              })
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
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Order'),
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            TextButton(
              onPressed: _submit,
              child: const Text('Create'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          const SizedBox(height: 16),
          FutureBuilder<List<Customer>>(
            future: _customersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final customers = snapshot.data ?? [];
              return DropdownButtonFormField<Customer>(
                initialValue: _selectedCustomer,
                decoration: const InputDecoration(
                  labelText: 'Customer',
                  prefixIcon: Icon(Icons.person_outlined),
                  border: OutlineInputBorder(),
                ),
                items: customers
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text('${c.fullName} (${c.phoneNumber})'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCustomer = value);
                },
                validator: (value) => value == null ? 'Select a customer' : null,
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Product>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final products = snapshot.data ?? [];
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: products.map((product) {
                  final inOrder = _items.any((item) => item.productId == product.id);
                  return ActionChip(
                    label: Text(product.name),
                    avatar: Icon(
                      inOrder ? Icons.check_circle : Icons.add_circle_outline,
                      size: 18,
                    ),
                    backgroundColor: inOrder ? Colors.green.shade100 : null,
                    onPressed: () => _addItem(product),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          if (_items.isNotEmpty) ...[
            const Text(
              'Order Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(_items.length, (index) {
              final item = _items[index];
              return Card(
                child: ListTile(
                  leading: item.productImageUrl != null && item.productImageUrl!.isNotEmpty
                      ? Image.network(
                          item.productImageUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported, size: 40),
                        )
                      : const Icon(Icons.image_outlined, size: 40),
                  title: Text(item.productName),
                  subtitle: Text('\$${item.unitPrice.toStringAsFixed(2)} each'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _updateQuantity(index, -1),
                      ),
                      Text(
                        '${item.quantity}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _updateQuantity(index, 1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _removeItem(index),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                        Text('\$${_subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _advanceController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Advance Paid',
                        prefixIcon: Icon(Icons.payments_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Balance:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('\$${_balance.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _balance > 0 ? Colors.orange : Colors.green,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
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