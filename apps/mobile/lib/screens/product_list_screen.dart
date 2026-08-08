import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/router/app_router.dart';
import 'package:mobile/models/product.dart';

const int lowStockThreshold = 5;

class ProductListScreen extends StatefulWidget {
  final AuthService authService;

  const ProductListScreen({super.key, required this.authService});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _productsFuture = widget.authService.apiService.getProducts(
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      category: _selectedCategory,
    );
  }

  void _refresh() {
    setState(() {
      _loadProducts();
    });
  }

  void _applyFilter(String? category) {
    setState(() {
      _selectedCategory = category;
      _loadProducts();
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _loadProducts();
    });
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.authService.apiService.deleteProduct(product.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} deleted'),
            backgroundColor: Colors.red,
          ),
        );
        _refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        bottom: AppBar(
          toolbarHeight: 80,
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 8,
                    children: [
                      _buildCategoryChip('All', null),
                      _buildCategoryChip('Electronics', 'Electronics'),
                      _buildCategoryChip('Clothing', 'Clothing'),
                      _buildCategoryChip('Shoes', 'Shoes'),
                      _buildCategoryChip('Accessories', 'Accessories'),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<Product>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final products = snapshot.data ?? [];

            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty || _selectedCategory != null
                          ? 'No matching products'
                          : 'No products yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty || _selectedCategory != null)
                      ...[
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filter',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    if (_searchQuery.isEmpty && _selectedCategory == null)
                      ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Tap the + button to add your first product',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  child: ListTile(
                    leading: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.image_not_supported,
                              size: 50,
                            ),
                          )
                        : const Icon(Icons.image_outlined, size: 50),
                    title: Row(
                      children: [
                        Expanded(child: Text(product.name)),
                        _buildAvailabilityBadge(product.quantity),
                      ],
                    ),
                    subtitle: Text(
                      '${product.category} • \$${product.price.toStringAsFixed(2)} • Qty: ${product.quantity}',
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.productDetail,
                        arguments: {
                          'authService': widget.authService,
                          'product': product,
                        },
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.addProduct,
                              arguments: {
                                'authService': widget.authService,
                                'product': product,
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteProduct(product),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRouter.addProduct,
            arguments: {'authService': widget.authService},
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(label, style: TextStyle(
        color: isSelected ? Colors.white : Colors.deepPurple,
        fontSize: 12,
      )),
      selected: isSelected,
      onSelected: (_) => _applyFilter(category),
      selectedColor: Colors.deepPurple,
      backgroundColor: Colors.deepPurple.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildAvailabilityBadge(int quantity) {
    Color color;
    String label;

    if (quantity == 0) {
      color = Colors.red;
      label = 'Out of Stock';
    } else if (quantity <= lowStockThreshold) {
      color = Colors.orange;
      label = 'Low Stock';
    } else {
      color = Colors.green;
      label = 'In Stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
