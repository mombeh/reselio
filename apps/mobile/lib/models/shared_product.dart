class SharedProduct {
  final String? name;
  final String? description;
  final double? price;
  final String? imageUrl;
  final String? storeName;
  final String? storeId;
  final int? quantity;
  final String? availability;

  SharedProduct({
    this.name,
    this.description,
    this.price,
    this.imageUrl,
    this.storeName,
    this.storeId,
    this.quantity,
    this.availability,
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
      storeId: json['storeId'],
      quantity: json['quantity'] is int ? json['quantity'] as int : null,
      availability: json['availability'],
    );
  }
}