import '../models/product.dart';

class ProductRepository {
  const ProductRepository();

  List<Product> get products => const [
    Product(
      id: 'avocado',
      name: 'Avocado',
      category: ProductCategory.produce,
      price: 1.80,
      unit: 'each',
      imagePath: 'assets/products/avocado.png',
      description:
          'Creamy, ripe avocado selected for toast, salads, and quick meals.',
      featured: true,
    ),
    Product(
      id: 'bananas',
      name: 'Bananas',
      category: ProductCategory.produce,
      price: 2.40,
      unit: '1 kg',
      imagePath: 'assets/products/bananas.png',
      description:
          'Naturally sweet bananas for breakfast, snacks, and smoothies.',
    ),
    Product(
      id: 'tomatoes',
      name: 'Vine tomatoes',
      category: ProductCategory.produce,
      price: 3.20,
      unit: '500 g',
      imagePath: 'assets/products/tomatoes.png',
      description:
          'Bright, juicy tomatoes with a balanced sweetness and fresh aroma.',
    ),
    Product(
      id: 'apples',
      name: 'Crisp apples',
      category: ProductCategory.produce,
      price: 3.60,
      unit: '1 kg',
      imagePath: 'assets/products/apples.png',
      description:
          'Firm, crisp apples that work equally well for snacking or baking.',
    ),
    Product(
      id: 'milk',
      name: 'Fresh milk',
      category: ProductCategory.dairy,
      price: 2.10,
      unit: '1 litre',
      imagePath: 'assets/products/milk.png',
      description:
          'Smooth whole milk for tea, cereal, baking, and everyday cooking.',
      featured: true,
    ),
    Product(
      id: 'yogurt',
      name: 'Natural yogurt',
      category: ProductCategory.dairy,
      price: 2.80,
      unit: '500 ml',
      imagePath: 'assets/products/yogurt.png',
      description:
          'Plain creamy yogurt with a clean taste and no added flavours.',
    ),
    Product(
      id: 'cheese',
      name: 'Golden cheese',
      category: ProductCategory.dairy,
      price: 5.90,
      unit: '250 g',
      imagePath: 'assets/products/cheese.png',
      description:
          'A mellow semi-hard cheese for sandwiches, pasta, or a snack board.',
    ),
    Product(
      id: 'bread',
      name: 'Rustic bread',
      category: ProductCategory.bakery,
      price: 3.40,
      unit: '1 loaf',
      imagePath: 'assets/products/bread.png',
      description:
          'A crusty artisan-style loaf with a soft, open crumb inside.',
      featured: true,
    ),
    Product(
      id: 'croissants',
      name: 'Butter croissants',
      category: ProductCategory.bakery,
      price: 4.50,
      unit: 'pack of 3',
      imagePath: 'assets/products/croissants.png',
      description:
          'Flaky, golden croissants with crisp layers and a buttery centre.',
    ),
    Product(
      id: 'rice',
      name: 'White rice',
      category: ProductCategory.pantry,
      price: 3.10,
      unit: '1 kg',
      imagePath: 'assets/products/rice.png',
      description:
          'Versatile long-grain white rice for simple, dependable meals.',
    ),
    Product(
      id: 'pasta',
      name: 'Penne pasta',
      category: ProductCategory.pantry,
      price: 2.70,
      unit: '500 g',
      imagePath: 'assets/products/pasta.png',
      description:
          'Golden penne that holds sauces well and cooks in a few minutes.',
    ),
    Product(
      id: 'coffee',
      name: 'Roasted coffee',
      category: ProductCategory.pantry,
      price: 7.80,
      unit: '250 g',
      imagePath: 'assets/products/coffee.png',
      description:
          'Fresh roasted beans with a rounded aroma and chocolate notes.',
      featured: true,
    ),
  ];
}
