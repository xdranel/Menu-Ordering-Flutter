import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_ordering_flutter/core/constants.dart';
import 'package:menu_ordering_flutter/models/order_model.dart';
import 'package:menu_ordering_flutter/providers/cart_provider.dart';
import 'package:menu_ordering_flutter/providers/order_provider.dart';
import 'package:menu_ordering_flutter/widgets/order_status_badge.dart';
import 'package:provider/provider.dart';

const Color _trackingPrimary = Color(0xFF9E3636);
const Color _trackingAccent = Color(0xFF963333);
const Color _trackingBackground = Color(0xFFF8F3F3);

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, required this.orderNumber});

  final String orderNumber;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    final orderProvider = context.read<OrderProvider>();
    Future.microtask(orderProvider.startPolling);
  }

  @override
  void dispose() {
    context.read<OrderProvider>().stopPolling();
    super.dispose();
  }

  void _startOver() {
    context.read<OrderProvider>().reset();
    context.read<CartProvider>().clear();
    context.go('/menu');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        final order = orderProvider.currentOrder;

        if (order == null || order.orderNumber != widget.orderNumber) {
          return Scaffold(
            backgroundColor: _trackingBackground,
            appBar: AppBar(
              backgroundColor: _trackingPrimary,
              foregroundColor: Colors.white,
              title: const Text('Track Order'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: _trackingPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Order not found in local session',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _trackingAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.go('/menu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _trackingPrimary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Back to Menu'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final terminalStatus =
            order.status == OrderStatus.completed ||
            order.status == OrderStatus.cancelled;

        return Scaffold(
          backgroundColor: _trackingBackground,
          appBar: AppBar(
            backgroundColor: _trackingPrimary,
            foregroundColor: Colors.white,
            title: const Text('Track Order'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ${order.orderNumber}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _trackingAccent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Updated automatically every 5 seconds',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          OrderStatusBadge(status: order.status),
                          const SizedBox(width: 8),
                          _PaymentStatusBadge(status: order.paymentStatus),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _TrackingRow(
                        label: 'Customer',
                        value: order.customerName,
                      ),
                      const SizedBox(height: 8),
                      _TrackingRow(
                        label: 'Total',
                        value: formatIDR(order.totalWithTax),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Progress',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: _trackingAccent,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      for (final entry in _trackingSteps.entries) ...[
                        _TrackingStepTile(
                          title: entry.value,
                          step: entry.key,
                          currentStatus: order.status,
                          isLast: entry.key == _trackingSteps.keys.last,
                        ),
                      ],
                      if (order.status == OrderStatus.cancelled) ...[
                        const SizedBox(height: 8),
                        Text(
                          'This order was cancelled by the backend workflow.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: _trackingPrimary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: terminalStatus
                ? ElevatedButton(
                    onPressed: _startOver,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _trackingPrimary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      order.status == OrderStatus.completed
                          ? 'Start New Order'
                          : 'Back to Menu',
                    ),
                  )
                : OutlinedButton(
                    onPressed: () => context.push('/payment'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _trackingPrimary,
                      side: const BorderSide(color: _trackingPrimary),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Review Payment'),
                  ),
          ),
        );
      },
    );
  }
}

const Map<OrderStatus, String> _trackingSteps = {
  OrderStatus.pending: 'Order placed',
  OrderStatus.confirmed: 'Confirmed by cashier',
  OrderStatus.preparing: 'Prepared by kitchen',
  OrderStatus.ready: 'Ready to pick up',
  OrderStatus.completed: 'Completed',
};

class _TrackingStepTile extends StatelessWidget {
  const _TrackingStepTile({
    required this.title,
    required this.step,
    required this.currentStatus,
    required this.isLast,
  });

  final String title;
  final OrderStatus step;
  final OrderStatus currentStatus;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final currentIndex = _trackingSteps.keys.toList().indexOf(currentStatus);
    final stepIndex = _trackingSteps.keys.toList().indexOf(step);
    final reached = currentStatus == OrderStatus.cancelled
        ? step == OrderStatus.pending
        : currentIndex >= stepIndex;
    final active = step == currentStatus;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: reached ? _trackingPrimary : const Color(0xFFE7D5D5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: reached ? _trackingPrimary : const Color(0xFFD8C2C2),
                ),
              ),
              child: reached
                  ? const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 34,
                color: reached ? _trackingPrimary : const Color(0xFFE7D5D5),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: active ? _trackingAccent : Colors.black87,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  active
                      ? 'Current step'
                      : reached
                      ? 'Done'
                      : 'Waiting',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
                SizedBox(height: isLast ? 0 : 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackingRow extends StatelessWidget {
  const _TrackingRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: _trackingAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final style = switch (status) {
      PaymentStatus.pending => const (
        label: 'Payment Pending',
        background: Color(0xFFF6E9E9),
        foreground: Color(0xFF963333),
      ),
      PaymentStatus.paid => const (
        label: 'Paid',
        background: Color(0xFFDFF4E7),
        foreground: Color(0xFF19543A),
      ),
      PaymentStatus.failed => const (
        label: 'Payment Failed',
        background: Color(0xFFFDE2E2),
        foreground: Color(0xFF8F1D1D),
      ),
      PaymentStatus.refunded => const (
        label: 'Refunded',
        background: Color(0xFFFFF3DB),
        foreground: Color(0xFF996515),
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          style.label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: style.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
