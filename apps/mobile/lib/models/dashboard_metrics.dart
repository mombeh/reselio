class DashboardMetrics {
  final int totalOrders;
  final double totalRevenue;
  final double totalProfit;
  final int pendingDeliveries;
  final double outstandingBalances;
  final int totalProducts;
  final int totalCustomers;

  DashboardMetrics({
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalProfit,
    required this.pendingDeliveries,
    required this.outstandingBalances,
    required this.totalProducts,
    required this.totalCustomers,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalOrders: (json['totalOrders'] is int)
          ? json['totalOrders'] as int
          : 0,
      totalRevenue: (json['totalRevenue'] is num)
          ? (json['totalRevenue'] as num).toDouble()
          : 0.0,
      totalProfit: (json['totalProfit'] is num)
          ? (json['totalProfit'] as num).toDouble()
          : 0.0,
      pendingDeliveries: (json['pendingDeliveries'] is int)
          ? json['pendingDeliveries'] as int
          : 0,
      outstandingBalances: (json['outstandingBalances'] is num)
          ? (json['outstandingBalances'] as num).toDouble()
          : 0.0,
      totalProducts: (json['totalProducts'] is int)
          ? json['totalProducts'] as int
          : 0,
      totalCustomers: (json['totalCustomers'] is int)
          ? json['totalCustomers'] as int
          : 0,
    );
  }
}