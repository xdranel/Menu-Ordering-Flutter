import 'package:menu_ordering_flutter/models/menu_model.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;
  String notes;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
    this.notes = '',
  });

  double get subtotal => menuItem.getCurrentPrice() * quantity;
}
