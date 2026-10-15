import 'package:flutter/material.dart';

import '../../../models/product.dart';

class CategoryChipList extends StatelessWidget {
  const CategoryChipList({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ProductCategory? selected;
  final ValueChanged<ProductCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          const SizedBox(width: 8),
          for (final category in ProductCategory.values) ...[
            ChoiceChip(
              label: Text(category.label),
              selected: selected == category,
              onSelected: (_) => onSelected(category),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
