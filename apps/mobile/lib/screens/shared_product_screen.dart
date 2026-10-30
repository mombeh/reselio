import 'package:flutter/material.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/models/shared_product.dart';
import 'package:mobile/models/store.dart';
import 'package:mobile/screens/product_detail_screen.dart';
import 'package:mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/auth_service.dart';

class SharedProductScreen extends StatefulWidget {
  final String publicId;
  final ApiService? apiService;
  final AuthService? authService;

  const SharedProductScreen({
    super.key,
    required this.publicId,
    this.apiService,
    this.authService,
  });

  @override
  State<SharedProductScreen> createState() => _SharedProductScreenState();
}

class _SharedProductScreenState extends State<SharedProductScreen> {
  late Future<_StoreData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_StoreData> _load() async {
    final api = widget.apiService ??
        ApiService(await SharedPreferences.getInstance());
    final shared = await api.getPublicProduct(widget.publicId);
    final storeId = shared.storeId;
    Store? store;
    List<Product> products = [];
    if (storeId != null && storeId.isNotEmpty) {
      try {
        final storeJson = await api.getPublicStore(storeId);
        if (storeJson != null) {
          store = Store.fromJson({...storeJson, 'userId': storeId});
        }
      } catch (_) {}
      try {
        products = await api.getPublicProducts(storeId: storeId, available: true);
      } catch (_) {}
    }
    return _StoreData(shared: shared, store: store, products: products);
  }

  String _formatPrice(double? price) {
    if (price == null) return 'N/A';
    return '${price.toStringAsFixed(0)} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store')),
      body: FutureBuilder<_StoreData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Product not found or has been removed',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => setState(() => _future = _load()),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }
          final data = snapshot.data!;
          final store = data.store;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (store != null) ...[
                Text(store.name,
                    style: Theme.of(context).textTheme.headlineSmall),
                if (store.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(store.description),
                  ),
                const SizedBox(height: 8),
                if (store.address.isNotEmpty) Text('Address: ${store.address}'),
                if (store.phone.isNotEmpty) Text('Phone: ${store.phone}'),
                const SizedBox(height: 16),
              ],
              Text('Available Products',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (data.products.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No available products')),
                )
              else
                ...data.products.map((p) => Card(
                      child: ListTile(
                        leading: Image.network(
                          p.imageUrl ?? '',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.image_not_supported),
                        ),
                        title: Text(p.name),
                        subtitle: Text(_formatPrice(p.price)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
                                authService: widget.authService,
                                product: p,
                              ),
                            ),
                          );
                        },
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }
}

class _StoreData {
  final SharedProduct shared;
  final Store? store;
  final List<Product> products;
  _StoreData({required this.shared, this.store, required this.products});
}
