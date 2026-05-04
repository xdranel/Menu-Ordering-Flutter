import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_ordering_flutter/core/constants.dart';
import 'package:menu_ordering_flutter/providers/cart_provider.dart';
import 'package:menu_ordering_flutter/providers/menu_provider.dart';
import 'package:menu_ordering_flutter/widgets/cart_badge.dart';
import 'package:menu_ordering_flutter/widgets/category_tab_bar.dart';
import 'package:menu_ordering_flutter/widgets/menu_card.dart';
import 'package:provider/provider.dart';

const Color _menuScreenPrimary = Color(0xFF9E3636);
const Color _menuScreenAccent = Color(0xFF963333);
const Color _menuScreenBackground = Color(0xFFF8F3F3);

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    final menuProvider = context.read<MenuProvider>();
    Future.microtask(() => menuProvider.loadAll());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _menuScreenBackground,
      appBar: AppBar(
        backgroundColor: _menuScreenPrimary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ChopChop'),
            Text(
              'Pick your menu and build the order',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: const [CartBadge(), SizedBox(width: 4)],
      ),
      body: Consumer<MenuProvider>(
        builder: (context, menu, _) {
          if (menu.isLoading && menu.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (menu.error != null && menu.categories.isEmpty) {
            return _buildError(context, menu);
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Explore the current available menu.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.black54),
                            ),
                          ),
                          if (menu.isLoading)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                    if (menu.categories.isNotEmpty)
                      CategoryTabBar(
                        categories: menu.categories,
                        selectedId: menu.selectedCategoryId,
                        onSelect: menu.selectCategory,
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: menu.retry,
                  color: _menuScreenPrimary,
                  child: menu.filteredItems.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 140),
                            _EmptyMenuState(),
                          ],
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.68,
                              ),
                          itemCount: menu.filteredItems.length,
                          itemBuilder: (_, i) =>
                              MenuCard(item: menu.filteredItems[i]),
                        ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isEmpty) {
            return const SizedBox.shrink();
          }

          return SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _menuScreenAccent,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: _menuScreenAccent.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${cart.totalQuantity} item${cart.totalQuantity == 1 ? '' : 's'} in cart',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatIDR(cart.totalWithTax),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => context.push('/cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _menuScreenPrimary,
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                      child: const Text('View Cart'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, MenuProvider menu) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: _menuScreenPrimary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load the menu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _menuScreenAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              menu.error ?? '',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: menu.retry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _menuScreenPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMenuState extends StatelessWidget {
  const _EmptyMenuState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Icon(
            Icons.no_food_rounded,
            size: 60,
            color: _menuScreenPrimary,
          ),
          const SizedBox(height: 14),
          Text(
            'No menu is available in this category yet.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _menuScreenAccent,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
