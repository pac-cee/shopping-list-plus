import 'package:flutter/material.dart';

import '../../../core/widgets/product_image.dart';
import '../../../models/product.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.imagePath,
    required this.count,
    required this.onTap,
  });

  final ProductCategory category;
  final String imagePath;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ProductImage(path: imagePath, name: category.label),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xB817211F)],
                  stops: [0.42, 1],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 13,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count products',
                    style: const TextStyle(
                      color: Color(0xFFD8E1DE),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
