import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/app_database.dart';
import '../data/product_repository.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/shopping_item.dart';

enum AddShoppingItemStatus { added, quantityIncreased, invalid }

class AddShoppingItemResult {
  const AddShoppingItemResult(this.status, {this.item});

  final AddShoppingItemStatus status;
  final ShoppingItem? item;
}

class ShopController extends ChangeNotifier {
  ShopController({required this.database, required this.repository});

  final AppDatabase database;
  final ProductRepository repository;

  List<ShoppingItem> shoppingItems = [];
  Map<String, int> _cart = {};
  bool isLoading = true;
  String? loadError;

  List<Product> get products => repository.products;

  List<CartItem> get cartItems => [
    for (final product in products)
      if ((_cart[product.id] ?? 0) > 0)
        CartItem(product: product, quantity: _cart[product.id]!),
  ];

  int get cartCount => _cart.values.fold(0, (sum, value) => sum + value);

  double get cartTotal => cartItems.fold(0, (sum, item) => sum + item.total);

  int get itemsLeft => shoppingItems.where((item) => !item.bought).length;

  List<ShoppingItem> get sortedShoppingItems {
    return [...shoppingItems]..sort((first, second) {
      if (first.bought == second.bought) return 0;
      return first.bought ? 1 : -1;
    });
  }

  Future<void> initialize() async {
    try {
      final results = await Future.wait([
        database.loadShoppingItems(),
        database.loadCart(),
      ]);
      shoppingItems = results[0] as List<ShoppingItem>;
      _cart = results[1] as Map<String, int>;
    } catch (_) {
      loadError = 'Basket could not open your saved data.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  int quantityFor(Product product) => _cart[product.id] ?? 0;

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final previousQuantity = quantityFor(product);
    final newQuantity = (previousQuantity + quantity).clamp(1, 99);
    _cart[product.id] = newQuantity;
    notifyListeners();
    try {
      await database.saveCartQuantity(product.id, newQuantity);
    } catch (_) {
      if (previousQuantity == 0) {
        _cart.remove(product.id);
      } else {
        _cart[product.id] = previousQuantity;
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> changeCartQuantity(Product product, int change) async {
    final previousQuantity = quantityFor(product);
    final newQuantity = (previousQuantity + change).clamp(0, 99);
    if (newQuantity == 0) {
      _cart.remove(product.id);
    } else {
      _cart[product.id] = newQuantity;
    }
    notifyListeners();
    try {
      await database.saveCartQuantity(product.id, newQuantity);
    } catch (_) {
      if (previousQuantity == 0) {
        _cart.remove(product.id);
      } else {
        _cart[product.id] = previousQuantity;
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> completeCheckout() async {
    if (_cart.isEmpty) return;
    final previousCart = Map<String, int>.from(_cart);
    _cart = {};
    notifyListeners();
    try {
      await database.clearCart();
    } catch (_) {
      _cart = previousCart;
      notifyListeners();
      rethrow;
    }
  }

  Future<AddShoppingItemResult> addShoppingItem(String value) async {
    final name = value.trim();
    if (name.isEmpty) {
      return const AddShoppingItemResult(AddShoppingItemStatus.invalid);
    }
    final matches = shoppingItems.where(
      (item) => item.name.toLowerCase() == name.toLowerCase(),
    );
    if (matches.isNotEmpty) {
      final item = matches.first;
      final previousQuantity = item.quantity;
      item.quantity = (item.quantity + 1).clamp(1, 99);
      notifyListeners();
      try {
        await database.updateShoppingItem(item);
      } catch (_) {
        item.quantity = previousQuantity;
        notifyListeners();
        rethrow;
      }
      return AddShoppingItemResult(
        AddShoppingItemStatus.quantityIncreased,
        item: item,
      );
    }
    final item = await database.addShoppingItem(name);
    shoppingItems.add(item);
    notifyListeners();
    return AddShoppingItemResult(AddShoppingItemStatus.added, item: item);
  }

  Future<void> toggleShoppingItem(ShoppingItem item) async {
    final previousValue = item.bought;
    item.bought = !previousValue;
    notifyListeners();
    try {
      await database.updateShoppingItem(item);
    } catch (_) {
      item.bought = previousValue;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> changeShoppingQuantity(ShoppingItem item, int change) async {
    final previousQuantity = item.quantity;
    item.quantity = (item.quantity + change).clamp(1, 99);
    notifyListeners();
    try {
      await database.updateShoppingItem(item);
    } catch (_) {
      item.quantity = previousQuantity;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteShoppingItem(ShoppingItem item) async {
    final previousIndex = shoppingItems.indexOf(item);
    if (previousIndex < 0) return;
    shoppingItems.remove(item);
    notifyListeners();
    try {
      await database.deleteShoppingItem(item.id);
    } catch (_) {
      shoppingItems.insert(previousIndex.clamp(0, shoppingItems.length), item);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> restoreShoppingItem(ShoppingItem item, int index) async {
    final safeIndex = index.clamp(0, shoppingItems.length);
    shoppingItems.insert(safeIndex, item);
    notifyListeners();
    try {
      await database.restoreShoppingItem(item);
    } catch (_) {
      shoppingItems.remove(item);
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> updateShoppingItemDetails({
    required ShoppingItem item,
    required String name,
    required String note,
    required ShoppingCategory category,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return false;
    final duplicate = shoppingItems.any(
      (candidate) =>
          candidate.id != item.id &&
          candidate.name.toLowerCase() == cleanName.toLowerCase(),
    );
    if (duplicate) return false;

    final previousName = item.name;
    final previousNote = item.note;
    final previousCategory = item.category;
    item
      ..name = cleanName
      ..note = note.trim()
      ..category = category;
    notifyListeners();
    try {
      await database.updateShoppingItem(item);
      return true;
    } catch (_) {
      item
        ..name = previousName
        ..note = previousNote
        ..category = previousCategory;
      notifyListeners();
      rethrow;
    }
  }

  Future<int> clearBoughtShoppingItems() async {
    final count = shoppingItems.where((item) => item.bought).length;
    if (count == 0) return 0;
    final previousItems = [...shoppingItems];
    shoppingItems.removeWhere((item) => item.bought);
    notifyListeners();
    try {
      await database.clearBoughtItems();
      return count;
    } catch (_) {
      shoppingItems = previousItems;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    unawaited(database.close());
    super.dispose();
  }
}
