import 'package:menu_ordering_flutter/core/constants.dart';
import 'package:menu_ordering_flutter/models/order_item_model.dart';

enum OrderStatus { pending, confirmed, preparing, ready, completed, cancelled }

enum PaymentStatus { pending, paid, failed, refunded }

class Order {
  final String orderNumber;
  final String customerName;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double total; // pre-tax — always use totalWithTax for display
  final List<OrderItem> items;
  final DateTime createdAt;

  const Order({
    required this.orderNumber,
    required this.customerName,
    required this.status,
    required this.paymentStatus,
    required this.total,
    required this.items,
    required this.createdAt,
  });

  double get totalWithTax => total * (1 + kTaxRate);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderNumber: json['orderNumber'] as String,
      customerName: json['customerName'] as String? ?? '',
      status: _parseOrderStatus(json['status'] as String?),
      paymentStatus: _parsePaymentStatus(json['paymentStatus'] as String?),
      total: (json['total'] as num).toDouble(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  // Spring Boot serializes LocalDateTime as [year,month,day,h,m,s,nano] array
  // when write-dates-as-timestamps is enabled (the default). Handle both forms.
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    if (value is List && value.isNotEmpty) {
      return DateTime(
        (value[0] as num).toInt(),
        value.length > 1 ? (value[1] as num).toInt() : 1,
        value.length > 2 ? (value[2] as num).toInt() : 1,
        value.length > 3 ? (value[3] as num).toInt() : 0,
        value.length > 4 ? (value[4] as num).toInt() : 0,
        value.length > 5 ? (value[5] as num).toInt() : 0,
      );
    }
    return DateTime.now();
  }

  static OrderStatus _parseOrderStatus(String? value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => OrderStatus.pending,
    );
  }

  static PaymentStatus _parsePaymentStatus(String? value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}
