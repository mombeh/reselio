class Product {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String category;
  final String? imageUrl;
  final String? publicId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? storeName;
  final String? storeAddress;
  final String? storePhone;
  final String? storeLogo;

  Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.category,
    this.imageUrl,
    this.publicId,
    this.createdAt,
    this.updatedAt,
    this.storeName,
    this.storeAddress,
    this.storePhone,
    this.storeLogo,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      storeId: json['storeId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : 0.0,
      quantity: (json['quantity'] is int)
          ? json['quantity'] as int
          : 0,
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'],
      publicId: json['publicId'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      storeName: json['storeName'],
      storeAddress: json['storeAddress'],
      storePhone: json['storePhone'],
      storeLogo: json['storeLogo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'category': category,
      'imageUrl': imageUrl,
      'publicId': publicId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'storeName': storeName,
      'storeAddress': storeAddress,
      'storePhone': storePhone,
      'storeLogo': storeLogo,
    };
  }
}