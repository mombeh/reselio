import 'package:flutter/material.dart';
import 'package:mobile/models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
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
          Card(
            child: ListTile(
              leading: const Icon(Icons.spellcheck_outlined, color: Colors.deepPurple),
              title: const Text('Name'),
              subtitle: Text(product.name),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined, color: Colors.blue),
              title: const Text('Description'),
              subtitle: Text(product.description),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.attach_money_outlined, color: Colors.green),
              title: const Text('Price'),
              subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.numbers_outlined, color: Colors.orange),
              title: const Text('Quantity'),
              subtitle: Text('${product.quantity} in stock'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.category_outlined, color: Colors.purple),
              title: const Text('Category'),
              subtitle: Text(product.category),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
              title: const Text('Created'),
              subtitle: Text(
                product.createdAt != null
                    ? '${product.createdAt!.day}/${product.createdAt!.month}/${product.createdAt!.year}'
                    : 'N/A',
              ),
            ),
          ),
        ],
      ),
    );
  }
}