import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../state/shop_controller.dart';
import 'category_products_screen.dart';
import 'widgets/category_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key, required this.controller});

  final ShopController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categories',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Browse a smaller aisle at a time.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 22),
            Expanded(
              child: GridView.builder(
                itemCount: ProductCategory.values.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final category = ProductCategory.values[index];
                  final products = controller.products
                      .where((product) => product.category == category)
                      .toList();
                  return CategoryCard(
                    category: category,
                    imagePath: products.first.imagePath,
                    count: products.length,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CategoryProductsScreen(
                          category: category,
                          controller: controller,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
