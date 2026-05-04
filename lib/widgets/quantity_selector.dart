import 'package:flutter/material.dart';

const Color _quantityPrimary = Color(0xFF9E3636);
const Color _quantityAccent = Color(0xFF963333);

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F6),
        border: Border.all(color: _quantityPrimary.withValues(alpha: 0.16)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(icon: Icons.remove_rounded, onPressed: onDecrease),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: _quantityAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _QuantityButton(icon: Icons.add_rounded, onPressed: onIncrease),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, color: _quantityPrimary, size: 18),
      ),
    );
  }
}
