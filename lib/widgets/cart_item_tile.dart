import 'package:flutter/material.dart';
import 'package:menu_ordering_flutter/models/cart_item_model.dart';
import 'package:menu_ordering_flutter/providers/cart_provider.dart';
import 'package:menu_ordering_flutter/widgets/price_display.dart';
import 'package:menu_ordering_flutter/widgets/quantity_selector.dart';
import 'package:provider/provider.dart';

const Color _cartTilePrimary = Color(0xFF9E3636);

class CartItemTile extends StatelessWidget {
  const CartItemTile({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final menuItem = item.menuItem;

    return Dismissible(
      key: ValueKey(menuItem.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: _cartTilePrimary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => cart.removeItem(menuItem.id),
      child: Card(
        color: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fastfood_rounded,
                      color: Color.fromARGB(255, 56, 56, 56),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menuItem.name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          menuItem.categoryName,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => cart.removeItem(menuItem.id),
                    icon: const Icon(Icons.close_rounded),
                    color: const Color.fromRGBO(150, 51, 51, 1),
                    tooltip: 'Remove',
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: PriceDisplay(
                      price: item.subtotal,
                      alignment: CrossAxisAlignment.start,
                      highlight: true,
                    ),
                  ),
                  QuantitySelector(
                    quantity: item.quantity,
                    onDecrease: () =>
                        cart.updateQuantity(menuItem.id, item.quantity - 1),
                    onIncrease: () =>
                        cart.updateQuantity(menuItem.id, item.quantity + 1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
