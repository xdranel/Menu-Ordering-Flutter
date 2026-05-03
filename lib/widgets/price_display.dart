import 'package:flutter/material.dart';
import 'package:menu_ordering_flutter/core/constants.dart';

const Color _pricePrimary = Color(0xFF9E3636);
const Color _priceAccent = Color(0xFF963333);

class PriceDisplay extends StatelessWidget {
  const PriceDisplay({
    super.key,
    required this.price,
    this.originalPrice,
    this.alignment = CrossAxisAlignment.start,
    this.highlight = false,
  });

  final double price;
  final double? originalPrice;
  final CrossAxisAlignment alignment;
  final bool highlight;

  bool get _showPromo => originalPrice != null && originalPrice! > price;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priceColor = highlight ? _pricePrimary : _priceAccent;

    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showPromo)
          Text(
            formatIDR(originalPrice!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black45,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text(
          formatIDR(price),
          style: theme.textTheme.titleMedium?.copyWith(
            color: priceColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
