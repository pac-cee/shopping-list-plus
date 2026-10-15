import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/product.dart';

class FeaturedProductCard extends StatefulWidget {
  const FeaturedProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  State<FeaturedProductCard> createState() => _FeaturedProductCardState();
}

class _FeaturedProductCardState extends State<FeaturedProductCard> {
  double rotateX = 0;
  double rotateY = 0;

  void updateTilt(DragUpdateDetails details) {
    if (MediaQuery.disableAnimationsOf(context)) return;
    setState(() {
      rotateY = (rotateY + details.delta.dx * 0.002).clamp(-0.05, 0.05);
      rotateX = (rotateX - details.delta.dy * 0.002).clamp(-0.04, 0.04);
    });
  }

  void resetTilt([DragEndDetails? _]) {
    setState(() {
      rotateX = 0;
      rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: updateTilt,
      onPanEnd: resetTilt,
      onPanCancel: resetTilt,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(rotateX)
          ..rotateY(rotateY),
        child: Material(
          color: AppTheme.ink,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: SizedBox(
              height: 190,
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'THIS WEEK',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: const Color(0xFF9ED7C9),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            widget.product.name,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${widget.product.unit}  •  \$${widget.product.price.toStringAsFixed(2)}',
                            style: const TextStyle(color: Color(0xFFC8D0CE)),
                          ),
                          const SizedBox(height: 14),
                          FilledButton.tonalIcon(
                            onPressed: widget.onAdd,
                            icon: const Icon(Icons.add_shopping_cart, size: 18),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Transform.rotate(
                      angle: math.pi / 36,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                        child: Hero(
                          tag: 'featured-${widget.product.id}',
                          child: ProductImage(
                            path: widget.product.imagePath,
                            name: widget.product.name,
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
