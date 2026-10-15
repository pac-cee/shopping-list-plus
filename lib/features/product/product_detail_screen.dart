import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/product_image.dart';
import '../../core/widgets/quantity_stepper.dart';
import '../../core/widgets/app_notice.dart';
import '../../models/product.dart';
import '../../state/shop_controller.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.controller,
    required this.heroTag,
  });

  final Product product;
  final ShopController controller;
  final String heroTag;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  bool added = false;

  void showMessage(
    String message, {
    AppNoticeTone tone = AppNoticeTone.success,
  }) {
    showAppNotice(context, message: message, tone: tone);
  }

  Future<void> addToCart() async {
    try {
      await widget.controller.addToCart(widget.product, quantity: quantity);
      if (!mounted) return;
      setState(() => added = true);
      showMessage('${widget.product.name} added to cart');
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (mounted) setState(() => added = false);
    } catch (_) {
      if (!mounted) return;
      showMessage(
        '${widget.product.name} could not be added. Try again.',
        tone: AppNoticeTone.error,
      );
    }
  }

  Future<void> addToList() async {
    try {
      final result = await widget.controller.addShoppingItem(
        widget.product.name,
      );
      if (!mounted) return;
      final item = result.item;
      switch (result.status) {
        case AddShoppingItemStatus.added:
          showMessage('${widget.product.name} added to My List');
        case AddShoppingItemStatus.quantityIncreased:
          showMessage(
            '${item!.name} is already on the list: now ×${item.quantity}',
            tone: AppNoticeTone.info,
          );
        case AddShoppingItemStatus.invalid:
          showMessage(
            'Enter an item name to add it.',
            tone: AppNoticeTone.error,
          );
      }
    } catch (_) {
      if (!mounted) return;
      showMessage(
        '${widget.product.name} could not be added to your list. Try again.',
        tone: AppNoticeTone.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.category.label)),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.05,
                      child: Hero(
                        tag: widget.heroTag,
                        child: ProductImage(
                          path: widget.product.imagePath,
                          name: widget.product.name,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.product.category.label.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: AppTheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.product.unit,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.product.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        Text(
                          'Quantity',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        QuantityStepper(
                          quantity: quantity,
                          onDecrease: quantity > 1
                              ? () => setState(() => quantity--)
                              : null,
                          onIncrease: () => setState(() {
                            quantity = (quantity + 1).clamp(1, 99);
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: addToList,
                        icon: const Icon(Icons.playlist_add),
                        label: const Text('Add to shopping list'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: addToCart,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          added ? Icons.check : Icons.shopping_bag_outlined,
                          key: ValueKey(added),
                        ),
                      ),
                      label: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(
                          added
                              ? 'Added to cart'
                              : 'Add $quantity · \$${(widget.product.price * quantity).toStringAsFixed(2)}',
                          key: ValueKey(added),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
