import 'package:menu_ordering_flutter/core/constants.dart';
import 'package:menu_ordering_flutter/models/order_item_model.dart';

enum OrderStatus { pending, processing, ready, completed, cancelled }

enum PaymentStatus { unpaid, paid, refunded }

class Order {
  final String orderNumber;
  final String customerName;
  final String tableNumber;
  final String? notes;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double total; // pre-tax — always use totalWithTax for display
  final List<OrderItem> items;
  final DateTime createdAt;

  const Order({
    required this.orderNumber,
    required this.customerName,
    required this.tableNumber,
    this.notes,
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
      customerName: json['customerName'] as String,
      tableNumber: json['tableNumber'] as String,
      notes: json['notes'] as String?,
      status: _parseOrderStatus(json['status'] as String?),
      paymentStatus: _parsePaymentStatus(json['paymentStatus'] as String?),
      total: (json['total'] as num).toDouble(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
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
      orElse: () => PaymentStatus.unpaid,
    );
  }
}
