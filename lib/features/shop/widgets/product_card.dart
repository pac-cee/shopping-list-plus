import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/product.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool pressed = false;

  void add() {
    setState(() => pressed = true);
    widget.onAdd();
    Future<void>.delayed(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => pressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'product-${widget.product.id}',
                child: ProductImage(
                  path: widget.product.imagePath,
                  name: widget.product.name,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.product.unit,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      AnimatedScale(
                        scale: pressed ? 0.86 : 1,
                        duration: const Duration(milliseconds: 120),
                        child: IconButton.filled(
                          onPressed: add,
                          tooltip: 'Add ${widget.product.name} to cart',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.add, size: 20),
                        ),
                      ),
                    ],
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
