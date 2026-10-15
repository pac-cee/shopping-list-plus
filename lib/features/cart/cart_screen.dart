import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_notice.dart';
import '../../core/widgets/product_image.dart';
import '../../core/widgets/quantity_stepper.dart';
import '../../models/cart_item.dart';
import '../../state/shop_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.controller,
    required this.onBrowse,
  });

  final ShopController controller;
  final VoidCallback onBrowse;

  Future<void> confirmCheckout(BuildContext context) async {
    final itemCount = controller.cartCount;
    final total = controller.cartTotal;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: const Text('Place Your Order?'),
        content: Text(
          '$itemCount ${itemCount == 1 ? 'item' : 'items'} · '
          '\$${total.toStringAsFixed(2)}\n\n'
          'Review your items before placing the order. Your cart will be cleared after confirmation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Place Order'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await controller.completeCheckout();
      if (!context.mounted) return;
      showAppNotice(
        context,
        message: 'Order placed. Your saved cart is now clear.',
      );
    } catch (_) {
      if (!context.mounted) return;
      showAppNotice(
        context,
        message: 'The order could not be completed. Your cart is unchanged.',
        tone: AppNoticeTone.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = controller.cartItems;
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your cart',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.cartCount} ${controller.cartCount == 1 ? 'item' : 'items'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? AppEmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Your cart is empty',
                    message: 'Browse groceries and add something you like.',
                    action: FilledButton(
                      onPressed: onBrowse,
                      child: const Text('Browse groceries'),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _CartItemTile(
                      item: items[index],
                      controller: controller,
                    ),
                  ),
          ),
          if (items.isNotEmpty)
            DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          Text(
                            '\$${controller.cartTotal.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: AppTheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => confirmCheckout(context),
                          icon: const Icon(Icons.lock_outline_rounded),
                          label: const Text('Review Order'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item, required this.controller});

  final CartItem item;
  final ShopController controller;

  Future<void> changeQuantity(BuildContext context, int change) async {
    try {
      await controller.changeCartQuantity(item.product, change);
    } catch (_) {
      if (!context.mounted) return;
      showAppNotice(
        context,
        message: '${item.product.name} could not be updated. Try again.',
        tone: AppNoticeTone.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 72,
              child: ProductImage(
                path: item.product.imagePath,
                name: item.product.name,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '\$${item.total.toStringAsFixed(2)} · ${item.product.unit}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            QuantityStepper(
              quantity: item.quantity,
              onDecrease: () => changeQuantity(context, -1),
              onIncrease: () => changeQuantity(context, 1),
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}
