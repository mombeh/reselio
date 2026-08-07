class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final String? productImageUrl;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.productImageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['productId'] is Map ? json['productId'] as Map<String, dynamic> : {};
    return OrderItem(
      id: json['_id'] ?? json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      productId: product['_id'] ?? json['productId'] ?? '',
      productName: product['name'] ?? json['productName'] ?? 'Unknown Product',
      unitPrice: (json['unitPrice'] is num)
          ? (json['unitPrice'] as num).toDouble()
          : 0.0,
      quantity: (json['quantity'] is int)
          ? json['quantity'] as int
          : 0,
      totalPrice: (json['totalPrice'] is num)
          ? (json['totalPrice'] as num).toDouble()
          : 0.0,
      productImageUrl: product['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'productImageUrl': productImageUrl,
    };
  }
}