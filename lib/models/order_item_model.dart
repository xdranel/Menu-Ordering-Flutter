class OrderItem {
  final int menuItemId;
  final String menuItemName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String notes;

  const OrderItem({
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      menuItemId: json['menuItemId'] as int,
      menuItemName: json['menuItemName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      notes: json['notes'] as String? ?? '',
    );
  }
}
