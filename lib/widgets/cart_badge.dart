import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_ordering_flutter/providers/cart_provider.dart';
import 'package:provider/provider.dart';

const Color _cartPrimary = Color(0xFF9E3636);

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final count = cart.totalQuantity;

        return IconButton(
          onPressed: () => context.push('/cart'),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_bag_outlined),
              if (count > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: _cartPrimary, width: 1.2),
                    ),
                    child: Text(
                      '$count',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _cartPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
