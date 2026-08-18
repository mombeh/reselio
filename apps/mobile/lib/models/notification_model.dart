import 'package:flutter/material.dart';

enum NotificationType {
  orderCreated,
  orderConfirmed,
  orderPreparing,
  orderDelivered,
  orderCancelled,
  lowStock,
}

extension NotificationTypeExtension on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.orderCreated:
        return 'ORDER_CREATED';
      case NotificationType.orderConfirmed:
        return 'ORDER_CONFIRMED';
      case NotificationType.orderPreparing:
        return 'ORDER_PREPARING';
      case NotificationType.orderDelivered:
        return 'ORDER_DELIVERED';
      case NotificationType.orderCancelled:
        return 'ORDER_CANCELLED';
      case NotificationType.lowStock:
        return 'LOW_STOCK';
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.orderCreated:
        return Colors.blue;
      case NotificationType.orderConfirmed:
        return Colors.orange;
      case NotificationType.orderPreparing:
        return Colors.purple;
      case NotificationType.orderDelivered:
        return Colors.green;
      case NotificationType.orderCancelled:
        return Colors.red;
      case NotificationType.lowStock:
        return Colors.orange;
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.orderCreated:
        return Icons.shopping_bag_outlined;
      case NotificationType.orderConfirmed:
        return Icons.check_circle_outline;
      case NotificationType.orderPreparing:
        return Icons.inventory_2_outlined;
      case NotificationType.orderDelivered:
        return Icons.local_shipping_outlined;
      case NotificationType.orderCancelled:
        return Icons.cancel_outlined;
      case NotificationType.lowStock:
        return Icons.warning_amber_outlined;
    }
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final String? referenceId;
  final String? referenceType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    this.referenceId,
    this.referenceType,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: _parseType(json['type'] as String?),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      referenceId: json['referenceId'] as String?,
      referenceType: json['referenceType'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'ORDER_CREATED':
        return NotificationType.orderCreated;
      case 'ORDER_CONFIRMED':
        return NotificationType.orderConfirmed;
      case 'ORDER_PREPARING':
        return NotificationType.orderPreparing;
      case 'ORDER_DELIVERED':
        return NotificationType.orderDelivered;
      case 'ORDER_CANCELLED':
        return NotificationType.orderCancelled;
      case 'LOW_STOCK':
        return NotificationType.lowStock;
      default:
        return NotificationType.orderCreated;
    }
  }

  String get timeAgo {
    final created = createdAt;
    if (created == null) return '';
    final now = DateTime.now();
    final difference = now.difference(created);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${created.day}/${created.month}/${created.year}';
    }
  }
}
