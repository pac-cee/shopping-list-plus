enum ShoppingCategory {
  food('Food'),
  drinks('Drinks'),
  home('Home');

  const ShoppingCategory(this.label);

  final String label;

  static ShoppingCategory fromDatabase(String? value) {
    return ShoppingCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => ShoppingCategory.food,
    );
  }
}

class ShoppingItem {
  ShoppingItem({
    required this.id,
    required this.name,
    this.bought = false,
    this.quantity = 1,
    this.note = '',
    this.category = ShoppingCategory.food,
  });

  final int id;
  String name;
  bool bought;
  int quantity;
  String note;
  ShoppingCategory category;

  factory ShoppingItem.fromMap(Map<String, Object?> map) {
    return ShoppingItem(
      id: map['id']! as int,
      name: map['name']! as String,
      bought: (map['bought']! as int) == 1,
      quantity: map['quantity']! as int,
      note: (map['note'] as String?) ?? '',
      category: ShoppingCategory.fromDatabase(map['category'] as String?),
    );
  }
}
