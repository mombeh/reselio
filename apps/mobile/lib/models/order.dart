import 'order_item.dart';

class Order {
  final String id;
  final String storeId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String orderNumber;
  final String status;
  final double subtotal;
  final double total;
  final double advancePaid;
  final double balance;
  final double profit;
  final List<OrderItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.storeId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.orderNumber,
    required this.status,
    required this.subtotal,
    required this.total,
    required this.advancePaid,
    required this.balance,
    required this.profit,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final customer = json['customerId'] is Map
        ? json['customerId'] as Map<String, dynamic>
        : (json['customer'] is Map
            ? json['customer'] as Map<String, dynamic>
            : {});
    final itemsList = json['orderItems'] != null
        ? (json['orderItems'] as List).map((item) => OrderItem.fromJson(item)).toList()
        : <OrderItem>[];

    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      storeId: json['storeId'] ?? '',
      customerId: customer['_id'] ?? json['customerId'] ?? '',
      customerName: customer['fullName'] ?? json['customerName'] ?? 'Unknown',
      customerPhone: customer['phoneNumber'] ?? json['customerPhone'] ?? '',
      customerEmail: customer['email'],
      orderNumber: json['orderNumber'] ?? '',
      status: json['status'] ?? 'Pending',
      subtotal: (json['subtotal'] is num)
          ? (json['subtotal'] as num).toDouble()
          : 0.0,
      total: (json['total'] is num)
          ? (json['total'] as num).toDouble()
          : 0.0,
      advancePaid: (json['advancePaid'] is num)
          ? (json['advancePaid'] as num).toDouble()
          : 0.0,
      balance: (json['balance'] is num)
          ? (json['balance'] as num).toDouble()
          : 0.0,
      profit: (json['profit'] is num)
          ? (json['profit'] as num).toDouble()
          : 0.0,
      items: itemsList,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'orderNumber': orderNumber,
      'status': status,
      'subtotal': subtotal,
      'total': total,
      'advancePaid': advancePaid,
      'balance': balance,
      'profit': profit,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}