import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mobile/models/shared_product.dart';
import 'package:mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedProductScreen extends StatefulWidget {
  final String publicId;
  final ApiService? apiService;

  const SharedProductScreen({
    super.key,
    required this.publicId,
    this.apiService,
  });

  @override
  State<SharedProductScreen> createState() => _SharedProductScreenState();
}

class _SharedProductScreenState extends State<SharedProductScreen> {
  late Future<SharedProduct> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _fetchProduct();
  }

  Future<SharedProduct> _fetchProduct() async {
    final apiService = widget.apiService ??
        ApiService(await SharedPreferences.getInstance());
    return apiService.getPublicProduct(widget.publicId);
  }

  String _formatPrice(double? price) {
    if (price == null) return 'N/A';
    return '${price.toStringAsFixed(0)} FCFA';
  }

  void _shareProduct(SharedProduct product) {
    final url = 'https://example.com/p/${widget.publicId}';
    Share.share('$url\n\n${product.name ?? 'Check out this product!'} - ${_formatPrice(product.price)}');
  }

  void _copyLink() {
    final url = 'https://example.com/p/${widget.publicId}';
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () async {
              final product = await _productFuture;
              _shareProduct(product);
            },
          ),
          IconButton(
            icon: const Icon(Icons.link_outlined),
            onPressed: _copyLink,
          ),
        ],
      ),
      body: FutureBuilder<SharedProduct>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Product not found or has been removed',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => setState(() => _productFuture = _fetchProduct()),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final product = snapshot.data!;

          if (product.availability == 'Out of Stock') {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 60,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'This product is currently out of stock',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                Card(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox(
                        height: 200,
                        child: Center(child: Icon(Icons.broken_image, size: 60)),
                      ),
                    ),
                  ),
                ),
              if (product.imageUrl == null || product.imageUrl!.isEmpty)
                Card(
                  child: SizedBox(
                    height: 200,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (product.storeName != null && product.storeName!.isNotEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.store_outlined, color: Colors.deepPurple),
                    title: const Text('Store'),
                    subtitle: Text(product.storeName!),
                  ),
                ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.spellcheck_outlined, color: Colors.deepPurple),
                  title: const Text('Name'),
                  subtitle: Text(product.name ?? 'Unknown Product'),
                ),
              ),
              const SizedBox(height: 8),
              if (product.price != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.attach_money_outlined, color: Colors.green),
                    title: const Text('Price'),
                    subtitle: Text(_formatPrice(product.price)),
                  ),
                ),
              if (product.description != null && product.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined, color: Colors.blue),
                    title: const Text('Description'),
                    subtitle: Text(product.description!),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contact seller feature coming soon'),
                    ),
                  );
                },
                icon: const Icon(Icons.message_outlined),
                label: const Text('Contact Seller'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}