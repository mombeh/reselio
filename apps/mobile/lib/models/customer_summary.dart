class CustomerSummary {
  final String id;
  final String customerName;
  final String phone;
  final int totalOrders;
  final double totalSpent;
  final double totalOutstandingBalance;
  final int deliveredOrders;

  CustomerSummary({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.totalOrders,
    required this.totalSpent,
    required this.totalOutstandingBalance,
    required this.deliveredOrders,
  });

  factory CustomerSummary.fromJson(Map<String, dynamic> json) {
    return CustomerSummary(
      id: json['_id'] ?? '',
      customerName: json['customerName'] ?? 'Unknown',
      phone: json['phone'] ?? '',
      totalOrders: (json['totalOrders'] is int)
          ? json['totalOrders'] as int
          : 0,
      totalSpent: (json['totalSpent'] is num)
          ? (json['totalSpent'] as num).toDouble()
          : 0.0,
      totalOutstandingBalance: (json['totalOutstandingBalance'] is num)
          ? (json['totalOutstandingBalance'] as num).toDouble()
          : 0.0,
      deliveredOrders: (json['deliveredOrders'] is int)
          ? json['deliveredOrders'] as int
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'phone': phone,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'totalOutstandingBalance': totalOutstandingBalance,
      'deliveredOrders': deliveredOrders,
    };
  }
}