enum ProductCategory {
  produce('Fresh produce'),
  dairy('Dairy'),
  bakery('Bakery'),
  pantry('Pantry');

  const ProductCategory(this.label);

  final String label;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imagePath,
    required this.unit,
    this.featured = false,
  });

  final String id;
  final String name;
  final ProductCategory category;
  final double price;
  final String description;
  final String imagePath;
  final String unit;
  final bool featured;
}
