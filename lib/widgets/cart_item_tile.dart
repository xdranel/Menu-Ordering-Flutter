import 'package:flutter/material.dart';
import 'package:menu_ordering_flutter/models/cart_item_model.dart';
import 'package:menu_ordering_flutter/providers/cart_provider.dart';
import 'package:menu_ordering_flutter/widgets/price_display.dart';
import 'package:menu_ordering_flutter/widgets/quantity_selector.dart';
import 'package:provider/provider.dart';

const Color _cartTilePrimary = Color(0xFF9E3636);
const Color _cartTileAccent = Color(0xFF963333);

class CartItemTile extends StatefulWidget {
  const CartItemTile({super.key, required this.item});

  final CartItem item;

  @override
  State<CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<CartItemTile> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.item.notes);
  }

  @override
  void didUpdateWidget(covariant CartItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.notes != widget.item.notes &&
        _notesController.text != widget.item.notes) {
      _notesController.text = widget.item.notes;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final menuItem = widget.item.menuItem;

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
        elevation: 0.8,
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
                      color: _cartTilePrimary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.fastfood_rounded,
                      color: _cartTilePrimary,
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
                                color: _cartTileAccent,
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
                    color: _cartTilePrimary,
                    tooltip: 'Remove',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                onChanged: (value) => cart.updateNotes(menuItem.id, value),
                decoration: const InputDecoration(
                  labelText: 'Item note',
                  hintText: 'No chili, extra ice, etc.',
                ),
                minLines: 1,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PriceDisplay(
                      price: widget.item.subtotal,
                      alignment: CrossAxisAlignment.start,
                      highlight: true,
                    ),
                  ),
                  QuantitySelector(
                    quantity: widget.item.quantity,
                    onDecrease: () => cart.updateQuantity(
                      menuItem.id,
                      widget.item.quantity - 1,
                    ),
                    onIncrease: () => cart.updateQuantity(
                      menuItem.id,
                      widget.item.quantity + 1,
                    ),
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
