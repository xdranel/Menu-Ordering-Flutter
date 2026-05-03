import 'package:flutter/material.dart';
import 'package:menu_ordering_flutter/models/order_model.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status);

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

  _StatusStyle _styleFor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const _StatusStyle(
          label: 'Pending',
          background: Color(0xFFF6E9E9),
          foreground: Color(0xFF963333),
        );
      case OrderStatus.confirmed:
        return const _StatusStyle(
          label: 'Confirmed',
          background: Color(0xFFFFF3DB),
          foreground: Color(0xFF996515),
        );
      case OrderStatus.preparing:
        return const _StatusStyle(
          label: 'Preparing',
          background: Color(0xFFFFE5E5),
          foreground: Color(0xFF9E3636),
        );
      case OrderStatus.ready:
        return const _StatusStyle(
          label: 'Ready',
          background: Color(0xFFE8F6EE),
          foreground: Color(0xFF206243),
        );
      case OrderStatus.completed:
        return const _StatusStyle(
          label: 'Completed',
          background: Color(0xFFDFF4E7),
          foreground: Color(0xFF19543A),
        );
      case OrderStatus.cancelled:
        return const _StatusStyle(
          label: 'Cancelled',
          background: Color(0xFFFDE2E2),
          foreground: Color(0xFF8F1D1D),
        );
    }
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}
