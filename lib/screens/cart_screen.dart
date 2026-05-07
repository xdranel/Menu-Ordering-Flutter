import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_ordering_flutter/core/constants.dart';
import 'package:menu_ordering_flutter/providers/cart_provider.dart';
import 'package:menu_ordering_flutter/providers/order_provider.dart';
import 'package:menu_ordering_flutter/widgets/cart_item_tile.dart';
import 'package:provider/provider.dart';

const Color _cartScreenPrimary = Color(0xFF9E3636);
const Color _cartScreenAccent = Color(0xFF963333);

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _customerNameController = TextEditingController();
  final _tableNumberController = TextEditingController();
  final _orderNotesController = TextEditingController();

  @override
  void dispose() {
    _customerNameController.dispose();
    _tableNumberController.dispose();
    _orderNotesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final customerName = _customerNameController.text.trim();

    if (customerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer name is required')),
      );
      return;
    }

    if (cart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    final items = List.of(cart.items);
    await orderProvider.placeOrder(customerName: customerName, items: items);

    if (!mounted) {
      return;
    }

    if (orderProvider.error != null || orderProvider.currentOrder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orderProvider.error ?? 'Failed to place order')),
      );
      return;
    }

    final orderNumber = orderProvider.currentOrder!.orderNumber;
    cart.clear();
    context.push('/order-confirmation/$orderNumber');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, OrderProvider>(
      builder: (context, cart, order, _) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 240, 240, 240),
          appBar: AppBar(
            backgroundColor: _cartScreenPrimary,
            foregroundColor: Colors.white,
            title: const Text('Your Cart'),
          ),
          body: SafeArea(
            child: cart.isEmpty
                ? _EmptyCartState(onBrowseMenu: () => context.pop())
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nama Pemesan',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: const Color.fromARGB(
                                            255,
                                            0,
                                            0,
                                            0,
                                          ),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                  TextField(
                                    controller: _customerNameController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: const InputDecoration(
                                      labelText: 'Masukkan nama Anda',
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'We will ensure the customer name is keep confidential and only used for order identification purposes.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Ringkasan Pesanan',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: _cartScreenAccent,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            for (final item in cart.items) ...[
                              CartItemTile(item: item),
                              const SizedBox(height: 14),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _SummaryRow(
                              label: 'Subtotal:',
                              value: formatIDR(cart.subtotal),
                            ),
                            const SizedBox(height: 8),
                            _SummaryRow(
                              label: 'Pajak (10%):',
                              value: formatIDR(
                                cart.totalWithTax - cart.subtotal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _SummaryRow(
                              label: 'Total Pembayaran:',
                              value: formatIDR(cart.totalWithTax),
                              emphasize: true,
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton(
                              onPressed: order.isLoading ? null : _placeOrder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(
                                  69,
                                  160,
                                  73,
                                  1,
                                ),
                                foregroundColor: Colors.white,
                              ),
                              child: order.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Bayar Sekarang'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState({required this.onBrowseMenu});

  final VoidCallback onBrowseMenu;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: _cartScreenPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is still empty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _cartScreenAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some menu items first, then come back here to place the order.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onBrowseMenu,
              style: ElevatedButton.styleFrom(
                backgroundColor: _cartScreenPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Browse Menu'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: emphasize ? _cartScreenPrimary : Colors.black87,
      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
    );

    return Row(
      children: [
        Expanded(child: Text(label, style: textStyle)),
        Text(value, style: textStyle),
      ],
    );
  }
}
