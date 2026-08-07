class SharedProduct {
  final String? name;
  final String? description;
  final double? price;
  final String? imageUrl;
  final String? storeName;
  final bool available;

  SharedProduct({
    this.name,
    this.description,
    this.price,
    this.imageUrl,
    this.storeName,
    required this.available,
  });

  factory SharedProduct.fromJson(Map<String, dynamic> json) {
    return SharedProduct(
      name: json['name'],
      description: json['description'],
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : null,
      imageUrl: json['imageUrl'],
      storeName: json['storeName'],
      available: json['available'] ?? false,
    );
  }
}