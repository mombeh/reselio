import 'package:flutter/material.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/router/app_router.dart';
import 'package:mobile/services/auth_service.dart';

class CustomerProductListScreen extends StatefulWidget {
  final AuthService authService;

  const CustomerProductListScreen({
    super.key,
    required this.authService,
  });

  @override
  State<CustomerProductListScreen> createState() => _CustomerProductListScreenState();
}

class _CustomerProductListScreenState extends State<CustomerProductListScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  late Future<List<Product>> _productsFuture;
  final Set<String> _favoriteProductIds = {};

  final List<Map<String, String?>> _categories = [
    {'label': 'All', 'value': null},
    {'label': 'Electronics', 'value': 'Electronics'},
    {'label': 'Clothing', 'value': 'Clothing'},
    {'label': 'Shoes', 'value': 'Shoes'},
    {'label': 'Accessories', 'value': 'Accessories'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadFavorites();
  }

  void _loadProducts() {
    _productsFuture = widget.authService.apiService.getPublicProducts(
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      category: _selectedCategory,
    );
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await widget.authService.apiService.getFavorites();
      if (mounted) {
        setState(() {
          _favoriteProductIds.clear();
          _favoriteProductIds.addAll(
            favorites.map((f) => f['productId'] as String),
          );
        });
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _toggleFavorite(String productId) async {
    final isFavorite = _favoriteProductIds.contains(productId);
    try {
      if (isFavorite) {
        await widget.authService.apiService.removeFavorite(productId);
        setState(() {
          _favoriteProductIds.remove(productId);
        });
      } else {
        await widget.authService.apiService.addFavorite(productId);
        setState(() {
          _favoriteProductIds.add(productId);
        });
      }
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

  void _refresh() {
    setState(() {
      _loadProducts();
    });
    _loadFavorites();
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

  void _openProductDetails(Product product) {
    Navigator.pushNamed(
      context,
      AppRouter.productDetail,
      arguments: {
        'authService': widget.authService,
        'product': product,
      },
    );
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
              'Browse Products',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17171C),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Discover items from sellers',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF777780),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF3D315F),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF6C4AB6),
        onRefresh: () async {
          _refresh();
        },
        child: FutureBuilder<List<Product>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error);
            }

            final products = snapshot.data ?? [];

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                _buildSearchField(),
                const SizedBox(height: 18),
                _buildCategoryFilters(),
                const SizedBox(height: 24),
                _buildSectionHeader(products.length),
                const SizedBox(height: 12),
                if (products.isEmpty)
                  _buildEmptyState()
                else
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.72,
                    children: products
                        .map(
                          (product) => _buildProductCard(product),
                        )
                        .toList(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: const TextStyle(
            color: Color(0xFF9A9AA3),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF777780),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _onSearchChanged('');
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
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
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final value = category['value'];
          final label = category['label']!;
          final isSelected = _selectedCategory == value;

          return GestureDetector(
            onTap: () => _applyFilter(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6C4AB6)
                    : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6C4AB6)
                      : const Color(0xFFE5E2EB),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF55515F),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Available Products',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF202027),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE8F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count ${count == 1 ? 'item' : 'items'}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6C4AB6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    final availability = _availabilityInfo(product.quantity);
    final isFavorite = _favoriteProductIds.contains(product.id);

    return GestureDetector(
      onTap: () => _openProductDetails(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFECEAF0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  _buildProductImage(product),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF202027),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (product.storeName != null && product.storeName!.isNotEmpty)
                    Text(
                      product.storeName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF888892),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(product.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6C4AB6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildAvailabilityBadge(
                        availability['label']!,
                        availability['color'] as Color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Qty: ${product.quantity}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF777780),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDF5),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: product.imageUrl != null && product.imageUrl!.isNotEmpty
          ? Image.network(
              product.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace? stackTrace,
              ) {
                return _buildImagePlaceholder();
              },
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 34,
        color: Color(0xFF9A8CAF),
      ),
    );
  }

  Widget _buildAvailabilityBadge(
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _availabilityInfo(int quantity) {
    if (quantity == 0) {
      return {
        'label': 'Out of Stock',
        'color': Colors.red,
      };
    }

    if (quantity <= 5) {
      return {
        'label': 'Low Stock',
        'color': Colors.orange,
      };
    }

    return {
      'label': 'In Stock',
      'color': Colors.green,
    };
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M FCFA';
    }

    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K FCFA';
    }

    return '${amount.toStringAsFixed(0)} FCFA';
  }

  Widget _buildEmptyState() {
    final hasFilter =
        _searchQuery.isNotEmpty || _selectedCategory != null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 80,
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE8F7),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 44,
              color: Color(0xFF6C4AB6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            hasFilter ? 'No products found' : 'No products available',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF27252D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilter
                ? 'Try adjusting your search or category filter.'
                : 'Check back later for new products.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF85838C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 100,
      ),
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.wifi_off_rounded,
            size: 38,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Unable to load products',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF27252D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.authService.apiService.getErrorMessage(error),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Color(0xFF85838C),
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: FilledButton.icon(
            onPressed: _refresh,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6C4AB6),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'Try Again',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        _buildSkeleton(
          height: 54,
          radius: 16,
        ),
        const SizedBox(height: 18),
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == 2 ? 0 : 8,
                ),
                child: _buildSkeleton(
                  height: 38,
                  radius: 20,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSkeleton(
          height: 24,
          width: 150,
          radius: 8,
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.72,
          children: List.generate(
            4,
            (index) => _buildSkeleton(
              height: 220,
              radius: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton({
    required double height,
    double? width,
    double radius = 12,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE9E7EC),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
