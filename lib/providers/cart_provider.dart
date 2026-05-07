import 'package:flutter/material.dart';
import 'package:menu_ordering_flutter/core/constants.dart';
import 'package:menu_ordering_flutter/models/cart_item_model.dart';
import 'package:menu_ordering_flutter/models/menu_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get totalWithTax => subtotal * (1 + kTaxRate);

  // Cash payment amount rounded up to nearest IDR 1,000.
  int get roundedCashTotal => roundCashAmount(subtotal);

  void addItem(MenuItem menuItem, {int quantity = 1}) {
    final index = _items.indexWhere((i) => i.menuItem.id == menuItem.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(menuItem: menuItem, quantity: quantity));
    }
    notifyListeners();
  }

  void removeItem(int menuItemId) {
    _items.removeWhere((i) => i.menuItem.id == menuItemId);
    notifyListeners();
  }

  void updateQuantity(int menuItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(menuItemId);
      return;
    }
    final index = _items.indexWhere((i) => i.menuItem.id == menuItemId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
