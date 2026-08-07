import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/services/auth_service.dart';

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
      _cachedShareUrl = await widget.authService!.apiService.getProductShareUrl(widget.product.id);
    } catch (_) {
      _cachedShareUrl = null;
    }
    if (mounted) setState(() => _isFetchingShareUrl = false);
  }

  String? _getShareUrl() {
    if (_cachedShareUrl != null) return _cachedShareUrl;
    if (widget.shareUrl != null) return widget.shareUrl;
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
        const SnackBar(content: Text('No share link available')),
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
        const SnackBar(content: Text('No share link available')),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  bool get _canShare =>
      widget.authService != null || widget.shareUrl != null || widget.product.publicId != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          if (_canShare) ...[
            if (_isFetchingShareUrl)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              )
            else ...[
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: _share,
              ),
              IconButton(
                icon: const Icon(Icons.link_outlined),
                onPressed: _copyLink,
              ),
            ],
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty)
            Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.product.imageUrl!,
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
          if (widget.product.imageUrl == null || widget.product.imageUrl!.isEmpty)
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
              subtitle: Text(widget.product.name),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined, color: Colors.blue),
              title: const Text('Description'),
              subtitle: Text(widget.product.description),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.attach_money_outlined, color: Colors.green),
              title: const Text('Price'),
              subtitle: Text('\$${widget.product.price.toStringAsFixed(2)}'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.numbers_outlined, color: Colors.orange),
              title: const Text('Quantity'),
              subtitle: Text('${widget.product.quantity} in stock'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.category_outlined, color: Colors.purple),
              title: const Text('Category'),
              subtitle: Text(widget.product.category),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
              title: const Text('Created'),
              subtitle: Text(
                widget.product.createdAt != null
                    ? '${widget.product.createdAt!.day}/${widget.product.createdAt!.month}/${widget.product.createdAt!.year}'
                    : 'N/A',
              ),
            ),
          ),
        ],
      ),
    );
  }
}