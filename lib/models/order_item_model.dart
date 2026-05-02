class OrderItem {
  final int menuItemId;
  final String menuItemName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const OrderItem({
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final menu = json['menu'] as Map<String, dynamic>?;
    return OrderItem(
      menuItemId: menu != null ? (menu['id'] as num).toInt() : 0,
      menuItemName: menu != null ? menu['name'] as String : '',
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}
