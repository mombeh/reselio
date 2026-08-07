class TopProduct {
  final String name;
  final int totalOrders;
  final double totalRevenue;
  final double totalProfit;

  TopProduct({
    required this.name,
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalProfit,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      name: json['_id'] ?? json['name'] ?? 'Unknown',
      totalOrders: (json['totalOrders'] is int)
          ? json['totalOrders'] as int
          : 0,
      totalRevenue: (json['totalRevenue'] is num)
          ? (json['totalRevenue'] as num).toDouble()
          : 0.0,
      totalProfit: (json['totalProfit'] is num)
          ? (json['totalProfit'] as num).toDouble()
          : 0.0,
    );
  }
}