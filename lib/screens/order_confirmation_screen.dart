import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_ordering_flutter/core/constants.dart';
import 'package:menu_ordering_flutter/providers/order_provider.dart';
import 'package:provider/provider.dart';

const Color _confirmationPrimary = Color(0xFF9E3636);
const Color _confirmationAccent = Color(0xFF963333);
const Color _confirmationBackground = Color(0xFFF8F3F3);

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key, required this.orderNumber});

  final String orderNumber;

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>().currentOrder;

    return Scaffold(
      backgroundColor: _confirmationBackground,
      appBar: AppBar(
        backgroundColor: _confirmationPrimary,
        foregroundColor: Colors.white,
        title: const Text('Order Confirmed'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: _confirmationPrimary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: _confirmationPrimary,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your order has been placed',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _confirmationAccent,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keep this order number for payment and tracking.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _InfoTile(label: 'Order number', value: orderNumber),
                  if (order != null) ...[
                    const SizedBox(height: 12),
                    _InfoTile(label: 'Customer', value: order.customerName),
                    const SizedBox(height: 12),
                    _InfoTile(
                      label: 'Items',
                      value: '${order.items.length} menu item(s)',
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      label: 'Total to pay',
                      value: formatIDR(order.totalWithTax),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.push('/payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _confirmationPrimary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Pay Now'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () =>
                        context.push('/order-tracking/$orderNumber'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _confirmationPrimary,
                      side: const BorderSide(color: _confirmationPrimary),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Track Order'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F1F1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _confirmationAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
