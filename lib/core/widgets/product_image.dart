import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.path,
    required this.name,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String path;
  final String name;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      path,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      semanticLabel: name,
      errorBuilder: (context, error, stackTrace) {
        return ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(child: Icon(Icons.image_not_supported_outlined)),
        );
      },
    );
    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
