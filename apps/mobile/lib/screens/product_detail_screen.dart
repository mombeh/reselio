import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/router/app_router.dart';

class ProductDetailScreen extends StatefulWidget {
  final AuthService? authService;
  final Product product;
  final String? shareUrl;

  const ProductDetailScreen({
    super.key,
    this.authService,
    required this.product,
    this.shareUrl,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _cachedShareUrl;
  bool _isFetchingShareUrl = false;
  int _selectedQuantity = 1;
  bool _isFavorite = false;

  Future<void> _ensureShareUrl() async {
    if (_cachedShareUrl != null) return;

    if (widget.shareUrl != null) {
      _cachedShareUrl = widget.shareUrl;
      return;
    }

    if (widget.authService == null) return;
    if (widget.product.id.isEmpty) return;

    setState(() => _isFetchingShareUrl = true);

    try {
      _cachedShareUrl = await widget.authService!.apiService
          .getProductShareUrl(widget.product.id);
    } catch (_) {
      _cachedShareUrl = null;
    }

    if (mounted) {
      setState(() => _isFetchingShareUrl = false);
    }
  }

  String? _getShareUrl() {
    if (_cachedShareUrl != null) return _cachedShareUrl;

    if (widget.shareUrl != null) {
      return widget.shareUrl;
    }

    if (widget.product.publicId != null) {
      return 'https://example.com/p/${widget.product.publicId}';
    }

    return null;
  }

  Future<void> _share() async {
    await _ensureShareUrl();

    final url = _getShareUrl();

    if (!mounted) return;

    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No share link available'),
        ),
      );
      return;
    }

    await Share.share(url);
  }

  Future<void> _copyLink() async {
    await _ensureShareUrl();

    final url = _getShareUrl();

    if (!mounted) return;

    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No share link available'),
        ),
      );
      return;
    }

    await Clipboard.setData(
      ClipboardData(text: url),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
      ),
    );
  }

  bool get _canShare =>
      widget.authService != null ||
      widget.shareUrl != null ||
      widget.product.publicId != null;

  bool get _isCustomer =>
      widget.authService?.currentUser?.role == 'customer';

  bool get _isSellerOrAdmin =>
      widget.authService != null &&
      (widget.authService!.currentUser?.role == 'client' ||
          widget.authService!.currentUser?.role == 'admin');

  void _incrementQuantity() {
    if (_selectedQuantity < widget.product.quantity) {
      setState(() {
        _selectedQuantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_selectedQuantity > 1) {
      setState(() {
        _selectedQuantity--;
      });
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _prepareOrder() async {
    if (_selectedQuantity > widget.product.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected quantity exceeds available stock'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await Navigator.pushNamed(
      context,
      AppRouter.createOrder,
      arguments: {
        'authService': widget.authService!,
        'initialItems': [
          {
            'productId': widget.product.id,
            'productName': widget.product.name,
            'unitPrice': widget.product.price,
            'quantity': _selectedQuantity,
            'productImageUrl': widget.product.imageUrl,
          },
        ],
      },
    );
  }

  Color get _stockColor {
    if (widget.product.quantity == 0) {
      return Colors.red;
    }

    if (widget.product.quantity <= 5) {
      return Colors.orange;
    }

    return Colors.green;
  }

  String get _stockLabel {
    if (widget.product.quantity == 0) {
      return 'Out of Stock';
    }

    if (widget.product.quantity <= 5) {
      return 'Low Stock';
    }

    return 'In Stock';
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          if (_canShare)
            if (_isFetchingShareUrl)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            else ...[
              IconButton(
                tooltip: 'Share product',
                icon: const Icon(Icons.share_outlined),
                onPressed: _share,
              ),
              IconButton(
                tooltip: 'Copy link',
                icon: const Icon(Icons.link_outlined),
                onPressed: _copyLink,
              ),
            ],
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // Product image
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: product.imageUrl != null &&
                      product.imageUrl!.isNotEmpty
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                    ),
            ),

             const SizedBox(height: 20),

             // Name + stock
             Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Expanded(
                   child: Text(
                     product.name,
                     style: const TextStyle(
                       fontSize: 24,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ),
                 const SizedBox(width: 12),
                 _buildStockBadge(),
               ],
             ),

             const SizedBox(height: 8),

             // Category
             Row(
               children: [
                 Icon(
                   Icons.category_outlined,
                   size: 18,
                   color: Colors.grey.shade600,
                 ),
                 const SizedBox(width: 6),
                 Text(
                   product.category,
                   style: TextStyle(
                     fontSize: 14,
                     color: Colors.grey.shade600,
                   ),
                 ),
               ],
             ),

             const SizedBox(height: 20),

             // Price
             Container(
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: Colors.deepPurple.shade50,
                 borderRadius: BorderRadius.circular(16),
               ),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   const Text(
                     'Selling Price',
                     style: TextStyle(
                       fontSize: 15,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                   Text(
                     '${product.price.toStringAsFixed(0)} FCFA',
                     style: const TextStyle(
                       fontSize: 26,
                       fontWeight: FontWeight.bold,
                       color: Colors.deepPurple,
                     ),
                   ),
                 ],
               ),
             ),

             if (product.storeName != null &&
                 product.storeName!.isNotEmpty) ...[
               const SizedBox(height: 12),
               _buildSection(
                 title: 'Seller Information',
                 icon: Icons.store_outlined,
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     _buildInfoRow(
                       'Store',
                       product.storeName!,
                     ),
                     if (product.storePhone != null &&
                         product.storePhone!.isNotEmpty) ...[
                       const Divider(height: 24),
                       _buildInfoRow(
                         'Phone',
                         product.storePhone!,
                       ),
                     ],
                     if (product.storeAddress != null &&
                         product.storeAddress!.isNotEmpty) ...[
                       const Divider(height: 24),
                       _buildInfoRow(
                         'Address',
                         product.storeAddress!,
                       ),
                     ],
                   ],
                 ),
               ),
             ],

            const SizedBox(height: 20),

            // Description
            _buildSection(
              title: 'Description',
              icon: Icons.description_outlined,
              child: Text(
                product.description.isNotEmpty
                    ? product.description
                    : 'No description available.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Inventory information
            _buildSection(
              title: 'Inventory',
              icon: Icons.inventory_2_outlined,
              child: Column(
                children: [
                  _buildInfoRow(
                    'Current Stock',
                    '${product.quantity} units',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Availability',
                    _stockLabel,
                    valueColor: _stockColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Product information
            _buildSection(
              title: 'Product Information',
              icon: Icons.info_outline,
              child: Column(
                children: [
                  _buildInfoRow(
                    'Category',
                    product.category,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Created',
                    product.createdAt != null
                        ? '${product.createdAt!.day}/'
                            '${product.createdAt!.month}/'
                            '${product.createdAt!.year}'
                        : 'N/A',
                  ),
                ],
              ),
            ),

             const SizedBox(height: 24),

             if (_isCustomer)
               Column(
                 children: [
                   Row(
                     children: [
                       Expanded(
                         child: _buildQuantitySelector(),
                       ),
                       const SizedBox(width: 12),
                       IconButton(
                         onPressed: _toggleFavorite,
                         icon: Icon(
                           _isFavorite
                               ? Icons.favorite
                               : Icons.favorite_border,
                           color: _isFavorite
                               ? Colors.red
                               : Colors.grey,
                         ),
                         tooltip: 'Favorite',
                       ),
                     ],
                   ),
                   const SizedBox(height: 12),
                   SizedBox(
                     width: double.infinity,
                     height: 56,
                     child: ElevatedButton.icon(
                       onPressed: widget.product.quantity > 0
                           ? _prepareOrder
                           : null,
                       icon: const Icon(Icons.shopping_bag_outlined),
                       label: Text(
                         widget.product.quantity > 0
                             ? 'Prepare Order'
                             : 'Out of Stock',
                       ),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.deepPurple,
                         foregroundColor: Colors.white,
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(18),
                         ),
                         elevation: 0,
                       ),
                     ),
                   ),
                 ],
               )
             else if (_isSellerOrAdmin)
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton.icon(
                   onPressed: () async {
                     await Navigator.pushNamed(
                       context,
                       AppRouter.addProduct,
                       arguments: {
                         'authService': widget.authService,
                         'product': product,
                       },
                     );

                     if (!mounted) return;

                     setState(() {});
                   },
                   icon: const Icon(Icons.edit_outlined),
                   label: const Text(
                     'Edit Product',
                     style: TextStyle(fontSize: 16),
                   ),
                   style: ElevatedButton.styleFrom(
                     padding: const EdgeInsets.symmetric(vertical: 16),
                   ),
                 ),
               ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _decrementQuantity,
            icon: const Icon(Icons.remove_circle_outline),
            color: Colors.deepPurple,
          ),
          Text(
            '$_selectedQuantity',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: _incrementQuantity,
            icon: const Icon(Icons.add_circle_outline),
            color: _selectedQuantity >= widget.product.quantity
                ? Colors.grey
                : Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildStockBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _stockColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _stockColor,
        ),
      ),
      child: Text(
        _stockLabel,
        style: TextStyle(
          color: _stockColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Colors.deepPurple,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}