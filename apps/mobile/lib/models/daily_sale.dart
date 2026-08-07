class DailySale {
  final String date;
  final int totalOrders;
  final double totalRevenue;
  final double totalProfit;

  DailySale({
    required this.date,
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalProfit,
  });

  factory DailySale.fromJson(Map<String, dynamic> json) {
    return DailySale(
      date: json['_id'] ?? json['date'] ?? '',
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