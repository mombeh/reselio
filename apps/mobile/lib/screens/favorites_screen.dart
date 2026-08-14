import 'package:flutter/material.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/router/app_router.dart';
import 'package:mobile/services/auth_service.dart';

class FavoritesScreen extends StatefulWidget {
  final AuthService authService;

  const FavoritesScreen({
    super.key,
    required this.authService,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Map<String, dynamic>>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoritesFuture = widget.authService.apiService.getFavorites();
    });
  }

  Future<void> _removeFavorite(String productId) async {
    try {
      await widget.authService.apiService.removeFavorite(productId);
      _loadFavorites();
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
              'Favorites',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17171C),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Your saved products',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF777780),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error);
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return _buildEmptyState();
          }

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: favorites.map((favorite) {
              final product = Product.fromJson(
                (favorite['product'] as Map<String, dynamic>? ?? {}),
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFavoriteCard(favorite['productId'] as String, product),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(String productId, Product product) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _openProductDetails(product),
            child: _buildProductImage(product),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: () => _openProductDetails(product),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF202027),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888892),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    _formatCurrency(product.price),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6C4AB6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.quantity} in stock',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF777780),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removeFavorite(productId),
            icon: const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            tooltip: 'Remove from favorites',
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDF5),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: product.imageUrl != null && product.imageUrl!.isNotEmpty
          ? Image.network(
              product.imageUrl!,
              fit: BoxFit.cover,
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
    return Center(
      child: Padding(
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
                Icons.favorite_border,
                size: 44,
                color: Color(0xFF6C4AB6),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No favorites yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF27252D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start browsing and tap the heart icon to save products.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
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
          'Unable to load favorites',
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
            onPressed: _loadFavorites,
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
        _buildSkeleton(height: 114, radius: 20),
        const SizedBox(height: 12),
        _buildSkeleton(height: 114, radius: 20),
        const SizedBox(height: 12),
        _buildSkeleton(height: 114, radius: 20),
      ],
    );
  }

  Widget _buildSkeleton({
    required double height,
    double radius = 12,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE9E7EC),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
