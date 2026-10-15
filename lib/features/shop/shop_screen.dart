import 'package:flutter/material.dart';

import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_notice.dart';
import '../../models/product.dart';
import '../../state/shop_controller.dart';
import '../product/product_detail_screen.dart';
import 'widgets/category_chip_list.dart';
import 'widgets/featured_product_card.dart';
import 'widgets/product_card.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, required this.controller});

  final ShopController controller;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final searchController = TextEditingController();
  ProductCategory? selectedCategory;
  String query = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Product> get visibleProducts {
    return widget.controller.products.where((product) {
      final matchesCategory =
          selectedCategory == null || product.category == selectedCategory;
      final matchesSearch = product.name.toLowerCase().contains(
        query.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void openProduct(Product product, {bool featured = false}) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (context, animation, secondaryAnimation) {
          return ProductDetailScreen(
            product: product,
            controller: widget.controller,
            heroTag: featured
                ? 'featured-${product.id}'
                : 'product-${product.id}',
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  Future<void> add(Product product) async {
    try {
      await widget.controller.addToCart(product);
      if (!mounted) return;
      showAppNotice(context, message: '${product.name} added to your cart');
    } catch (_) {
      if (!mounted) return;
      showAppNotice(
        context,
        message: '${product.name} could not be added. Try again.',
        tone: AppNoticeTone.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final featured = widget.controller.products.firstWhere(
      (product) => product.featured,
    );
    final products = visibleProducts;
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BASKET',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  letterSpacing: 2.2,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Good food, simply.',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton.outlined(
                      onPressed: () {
                        showAppNotice(
                          context,
                          message: 'Basket works offline and saves your list on this device.',
                          tone: AppNoticeTone.info,
                        );
                      },
                      tooltip: 'About Basket',
                      icon: const Icon(Icons.info_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: searchController,
                  onChanged: (value) => setState(() => query = value.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search groceries…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() => query = '');
                            },
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                if (query.isEmpty && selectedCategory == null) ...[
                  FeaturedProductCard(
                    product: featured,
                    onTap: () => openProduct(featured, featured: true),
                    onAdd: () => add(featured),
                  ),
                  const SizedBox(height: 22),
                ],
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: CategoryChipList(
              selected: selectedCategory,
              onSelected: (value) => setState(() => selectedCategory = value),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedCategory?.label ?? 'All groceries',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    '${products.length} items',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          if (products.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmptyState(
                icon: Icons.search_off,
                title: 'No groceries found',
                message: 'Try another search or category.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverGrid.builder(
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.sizeOf(context).width > 700
                      ? 4
                      : 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => openProduct(product),
                    onAdd: () => add(product),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
