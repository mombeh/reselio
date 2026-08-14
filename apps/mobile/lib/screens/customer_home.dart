import 'package:flutter/material.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/router/app_router.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/widgets/notification_icon_badge.dart';

class CustomerHome extends StatelessWidget {
  final AuthService authService;

  const CustomerHome({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        actions: [
          NotificationIconBadge(authService: authService),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.profile,
                arguments: {'authService': authService},
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF6C4AB6),
        onRefresh: () async {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerHome(authService: authService),
              ),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ProductSection(authService: authService),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.search, color: Colors.green),
                title: const Text('Browse Products'),
                subtitle: const Text('Explore all available products'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.customerProductList,
                    arguments: {'authService': authService},
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text('Favorites'),
                subtitle: const Text('View your saved products'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.favorites,
                    arguments: {'authService': authService},
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.shopping_bag, color: Colors.blue),
                title: const Text('My Products'),
                subtitle: const Text('Products you have purchased'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.myProducts,
                    arguments: {'authService': authService},
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.notifications_outlined, color: Colors.deepOrange),
                title: const Text('Notifications'),
                subtitle: const Text('View your notifications'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.notifications,
                    arguments: {'authService': authService},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSection extends StatefulWidget {
  final AuthService authService;

  const _ProductSection({required this.authService});

  @override
  State<_ProductSection> createState() => __ProductSectionState();
}

class __ProductSectionState extends State<_ProductSection> {
  final Set<String> _favoriteProductIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: widget.authService.apiService.getPublicProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _ProductLoadingState();
        }

        if (snapshot.hasError) {
          return _ProductErrorState(
            error: snapshot.error,
            onRetry: () {
              if (context.mounted) {
                (context as Element).markNeedsBuild();
              }
            },
            errorMessage: widget.authService.apiService.getErrorMessage(snapshot.error),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return _ProductEmptyState();
        }

        return _ProductGrid(
          products: products,
          authService: widget.authService,
          favoriteProductIds: _favoriteProductIds,
          onFavoriteToggle: _toggleFavorite,
        );
      },
    );
  }
}

class _ProductLoadingState extends StatelessWidget {
  const _ProductLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF202027),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => Container(
              width: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFE9E7EC),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductErrorState extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;
  final String errorMessage;

  const _ProductErrorState({
    required this.error,
    required this.onRetry,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF202027),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  errorMessage,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductEmptyState extends StatelessWidget {
  const _ProductEmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF202027),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE8F7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: Color(0xFF6C4AB6)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No products available yet. Check back later!',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<Product> products;
  final AuthService authService;
  final Set<String> favoriteProductIds;
  final ValueChanged<String> onFavoriteToggle;

  const _ProductGrid({
    required this.products,
    required this.authService,
    required this.favoriteProductIds,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF202027),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              final isFavorite = favoriteProductIds.contains(product.id);
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.productDetail,
                    arguments: {
                      'authService': authService,
                      'product': product,
                    },
                  );
                },
                child: Container(
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFECEAF0),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildProductImage(product),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF202027),
                                  ),
                                ),
                                if (product.storeName != null &&
                                    product.storeName!.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    product.storeName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF888892),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  _formatCurrency(product.price),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF6C4AB6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => onFavoriteToggle(product.id),
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
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(Product product) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDF5),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
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
        size: 28,
        color: Color(0xFF9A8CAF),
      ),
    );
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
}
