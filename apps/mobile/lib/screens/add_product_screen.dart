import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/services/auth_service.dart';

class AddProductScreen extends StatefulWidget {
  final AuthService authService;
  final Product? product;

  const AddProductScreen({
    super.key,
    required this.authService,
    this.product,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _error;
  bool _isEditing = false;
  bool _isSubmitting = false;
  Uint8List? _pickedImageBytes;
  String? _pickedImageExtension;

  @override
  void initState() {
    super.initState();

    _isEditing = widget.product != null;

    if (_isEditing) {
      final product = widget.product!;

      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toString();
      _quantityController.text = product.quantity.toString();
      _categoryController.text = product.category;
      _imageUrlController.text = product.imageUrl ?? '';
    }

    _imageUrlController.addListener(_onImageUrlChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _onImageUrlChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      final extension = pickedFile.mimeType?.split('/').last ?? 'png';

      setState(() {
        _pickedImageBytes = bytes;
        _pickedImageExtension = extension;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  String? _getImageUrl() {
    if (_pickedImageBytes != null) {
      final base64 = base64Encode(_pickedImageBytes!);
      return 'data:image/$_pickedImageExtension;base64,$base64';
    }
    final url = _imageUrlController.text.trim();
    return url.isEmpty ? null : url;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _error = null;
      _isSubmitting = true;
    });

    try {
      final price = double.parse(_priceController.text.trim());
      final quantity = int.parse(_quantityController.text.trim());
      final imageUrl = _getImageUrl();

      if (_isEditing) {
        await widget.authService.apiService.updateProduct(
          id: widget.product!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price,
          quantity: quantity,
          category: _categoryController.text.trim(),
          imageUrl: imageUrl,
        );
      } else {
        await widget.authService.apiService.createProduct(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price,
          quantity: quantity,
          category: _categoryController.text.trim(),
          imageUrl: imageUrl,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Product updated successfully'
                : 'Product added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = widget.authService.apiService.getErrorMessage(e);
        _isSubmitting = false;
      });
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.deepPurple,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.deepPurple,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    final imageUrl = _getImageUrl();

    Widget preview;
    if (_pickedImageBytes != null) {
      preview = Image.memory(
        _pickedImageBytes!,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: 42,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unable to load image',
                    style: TextStyle(
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else {
      preview = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Product image preview',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: preview,
            ),
            if (_pickedImageBytes != null || (imageUrl != null && imageUrl.isNotEmpty))
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Tap to change',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit Product' : 'Add Product';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header
              Text(
                _isEditing
                    ? 'Update your product'
                    : 'Add a new product',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isEditing
                    ? 'Make changes to your product information below.'
                    : 'Enter the details of the product you want to add to your store.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // Error
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Product information
              _buildSectionTitle(
                title: 'Product Information',
                subtitle: 'Basic information about your product.',
                icon: Icons.inventory_2_outlined,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  label: 'Product Name',
                  icon: Icons.shopping_bag_outlined,
                  hint: 'e.g. Wireless Headphones',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                decoration: _inputDecoration(
                  label: 'Description',
                  icon: Icons.description_outlined,
                  hint: 'Describe your product...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _categoryController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  label: 'Category',
                  icon: Icons.category_outlined,
                  hint: 'e.g. Electronics',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              // Pricing and inventory
              _buildSectionTitle(
                title: 'Pricing & Inventory',
                subtitle: 'Set the selling price and available stock.',
                icon: Icons.payments_outlined,
              ),

              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputDecoration(
                        label: 'Price',
                        icon: Icons.attach_money_outlined,
                        hint: '0.00',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter price';
                        }

                        final price = double.tryParse(value.trim());

                        if (price == null || price < 0) {
                          return 'Invalid price';
                        }

                        if (price > 10000000) {
                          return 'Max 10,000,000';
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        label: 'Quantity',
                        icon: Icons.numbers_outlined,
                        hint: '0',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter quantity';
                        }

                        final quantity = int.tryParse(value.trim());

                        if (quantity == null || quantity < 0) {
                          return 'Invalid quantity';
                        }

                        if (quantity > 1000000) {
                          return 'Max 1,000,000';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Image
              _buildSectionTitle(
                title: 'Product Image',
                subtitle: 'Add an image URL to display your product.',
                icon: Icons.image_outlined,
              ),

              const SizedBox(height: 16),

              _buildImagePreview(),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_outlined),
                label: const Text('Upload Image'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _imageUrlController,
                keyboardType: TextInputType.url,
                decoration: _inputDecoration(
                  label: 'Image URL',
                  icon: Icons.link_outlined,
                  hint: 'https://...',
                ),
              ),

              const SizedBox(height: 28),

              // Submit
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isEditing
                                  ? Icons.save_outlined
                                  : Icons.add_circle_outline,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isEditing
                                  ? 'Update Product'
                                  : 'Add Product',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                _isEditing
                    ? 'Your changes will be saved to your store.'
                    : 'You can edit this product later from your product list.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}