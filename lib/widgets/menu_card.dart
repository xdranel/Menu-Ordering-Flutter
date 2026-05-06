import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:menu_ordering_flutter/core/constants.dart';
import 'package:menu_ordering_flutter/models/menu_model.dart';
import 'package:menu_ordering_flutter/providers/cart_provider.dart';
import 'package:menu_ordering_flutter/widgets/price_display.dart';
import 'package:provider/provider.dart';

const Color _menuPrimary = Color(0xFF9E3636);

class MenuCard extends StatelessWidget {
  const MenuCard({super.key, required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.20),
                  ),
                  child: _MenuImage(imageUrl: item.imageUrl),
                ),
                if (item.isPromo)
                  const Positioned(
                    left: 10,
                    top: 10,
                    child: _StatusPill(
                      label: 'Promo',
                      backgroundColor: _menuPrimary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: _StatusPill(
                    label: item.available ? 'Ready' : 'Sold Out',
                    backgroundColor: item.available
                        ? const Color(0xFFE7F6ED)
                        : const Color(0xFFF9E0E0),
                    foregroundColor: item.available
                        ? const Color.fromARGB(255, 26, 94, 58)
                        : _menuPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description?.trim().isNotEmpty == true
                      ? item.description!
                      : item.categoryName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: PriceDisplay(
                        price: item.getCurrentPrice(),
                        originalPrice: item.isPromo ? item.price : null,
                        highlight: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: item.available
                            ? () => _addToCart(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _menuPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: const Size(0, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(Icons.add_rounded, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context) {
    context.read<CartProvider>().addItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _MenuImage extends StatelessWidget {
  const _MenuImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolveImageUrl(imageUrl);

    if (resolvedUrl == null) {
      return const Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          size: 42,
          color: _menuPrimary,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: resolvedUrl,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => const Center(
        child: Icon(Icons.broken_image_outlined, size: 42, color: _menuPrimary),
      ),
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  String? _resolveImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return null;
    }

    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }

    final normalizedBase = kBaseUrl.endsWith('/')
        ? kBaseUrl.substring(0, kBaseUrl.length - 1)
        : kBaseUrl;
    final normalizedPath = rawUrl.startsWith('/') ? rawUrl : '/$rawUrl';
    return '$normalizedBase$normalizedPath';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
