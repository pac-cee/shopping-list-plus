import 'package:flutter/material.dart';

import '../../core/widgets/app_notice.dart';
import '../../models/product.dart';
import '../../state/shop_controller.dart';
import '../product/product_detail_screen.dart';
import '../shop/widgets/product_card.dart';

class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({
    super.key,
    required this.category,
    required this.controller,
  });

  final ProductCategory category;
  final ShopController controller;

  @override
  Widget build(BuildContext context) {
    final products = controller.products
        .where((product) => product.category == category)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(category.label)),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProductDetailScreen(
                  product: product,
                  controller: controller,
                  heroTag: 'product-${product.id}',
                ),
              ),
            ),
            onAdd: () async {
              try {
                await controller.addToCart(product);
                if (!context.mounted) return;
                showAppNotice(
                  context,
                  message: '${product.name} added to your cart',
                );
              } catch (_) {
                if (!context.mounted) return;
                showAppNotice(
                  context,
                  message: '${product.name} could not be added. Try again.',
                  tone: AppNoticeTone.error,
                );
              }
            },
          );
        },
      ),
    );
  }
}
