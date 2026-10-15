import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list/data/app_database.dart';
import 'package:shopping_list/data/product_repository.dart';
import 'package:shopping_list/models/shopping_item.dart';
import 'package:shopping_list/state/shop_controller.dart';

class FakeDatabase extends AppDatabase {
  FakeDatabase(this.items);

  final List<ShoppingItem> items;
  final Map<String, int> cart = {};
  int nextId = 100;

  @override
  Future<List<ShoppingItem>> loadShoppingItems() async => [...items];

  @override
  Future<Map<String, int>> loadCart() async => {...cart};

  @override
  Future<ShoppingItem> addShoppingItem(String name) async {
    final item = ShoppingItem(id: nextId++, name: name);
    items.add(item);
    return item;
  }

  @override
  Future<void> updateShoppingItem(ShoppingItem item) async {}

  @override
  Future<void> deleteShoppingItem(int id) async {
    items.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> restoreShoppingItem(ShoppingItem item) async {
    items.add(item);
  }

  @override
  Future<void> saveCartQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      cart.remove(productId);
    } else {
      cart[productId] = quantity;
    }
  }

  @override
  Future<void> clearCart() async => cart.clear();

  @override
  Future<void> close() async {}
}

class FailingDatabase extends FakeDatabase {
  FailingDatabase(super.items);

  @override
  Future<void> saveCartQuantity(String productId, int quantity) {
    throw StateError('cart write failed');
  }

  @override
  Future<void> updateShoppingItem(ShoppingItem item) {
    throw StateError('item update failed');
  }

  @override
  Future<void> deleteShoppingItem(int id) {
    throw StateError('item delete failed');
  }
}

ShopController buildController(List<ShoppingItem> items) {
  return ShopController(
    database: FakeDatabase(items),
    repository: const ProductRepository(),
  );
}

void main() {
  group('Shopping List+', () {
    test(
      'duplicates ignore spaces and capitals and increase quantity',
      () async {
        final milk = ShoppingItem(id: 1, name: 'Milk');
        final controller = buildController([milk]);
        await controller.initialize();

        final result = await controller.addShoppingItem('  mILK  ');

        expect(result.status, AddShoppingItemStatus.quantityIncreased);
        expect(result.item, same(milk));
        expect(milk.quantity, 2);
        expect(controller.shoppingItems, hasLength(1));
      },
    );

    test('checkout clears the in-memory cart and persisted cart', () async {
      final database = FakeDatabase([]);
      final controller = ShopController(
        database: database,
        repository: const ProductRepository(),
      );
      await controller.initialize();
      await controller.addToCart(controller.products.first, quantity: 2);

      await controller.completeCheckout();

      expect(controller.cartItems, isEmpty);
      expect(controller.cartCount, 0);
      expect(database.cart, isEmpty);
    });

    test('failed SQLite cart write rolls the visible cart back', () async {
      final controller = ShopController(
        database: FailingDatabase([]),
        repository: const ProductRepository(),
      );
      await controller.initialize();

      await expectLater(
        controller.addToCart(controller.products.first),
        throwsStateError,
      );

      expect(controller.cartCount, 0);
      expect(controller.cartItems, isEmpty);
    });

    test('failed SQLite item update restores its previous state', () async {
      final milk = ShoppingItem(id: 1, name: 'Milk');
      final controller = ShopController(
        database: FailingDatabase([milk]),
        repository: const ProductRepository(),
      );
      await controller.initialize();

      await expectLater(controller.toggleShoppingItem(milk), throwsStateError);

      expect(milk.bought, isFalse);
      expect(controller.itemsLeft, 1);
    });

    test(
      'failed SQLite delete restores the item at the same position',
      () async {
        final milk = ShoppingItem(id: 1, name: 'Milk');
        final bread = ShoppingItem(id: 2, name: 'Bread');
        final controller = ShopController(
          database: FailingDatabase([milk, bread]),
          repository: const ProductRepository(),
        );
        await controller.initialize();

        await expectLater(
          controller.deleteShoppingItem(milk),
          throwsStateError,
        );

        expect(controller.shoppingItems, [milk, bread]);
      },
    );

    test('quantity never goes below one', () async {
      final rice = ShoppingItem(id: 2, name: 'Rice');
      final controller = buildController([rice]);
      await controller.initialize();

      await controller.changeShoppingQuantity(rice, -5);

      expect(rice.quantity, 1);
    });

    test(
      'bought items are returned after items left in All ordering',
      () async {
        final milk = ShoppingItem(id: 1, name: 'Milk', bought: true);
        final bread = ShoppingItem(id: 2, name: 'Bread');
        final rice = ShoppingItem(id: 3, name: 'Rice');
        final controller = buildController([milk, bread, rice]);
        await controller.initialize();

        expect(controller.sortedShoppingItems.map((item) => item.name), [
          'Bread',
          'Rice',
          'Milk',
        ]);
      },
    );

    test('delete and undo restore the same object and position', () async {
      final milk = ShoppingItem(id: 1, name: 'Milk');
      final bread = ShoppingItem(
        id: 2,
        name: 'Bread',
        quantity: 3,
        bought: true,
      );
      final rice = ShoppingItem(id: 3, name: 'Rice');
      final controller = buildController([milk, bread, rice]);
      await controller.initialize();

      final index = controller.shoppingItems.indexOf(bread);
      await controller.deleteShoppingItem(bread);
      await controller.restoreShoppingItem(bread, index);

      expect(controller.shoppingItems, [milk, bread, rice]);
      expect(controller.shoppingItems[1].quantity, 3);
      expect(controller.shoppingItems[1].bought, isTrue);
    });

    test('details save name, note, and category together', () async {
      final rice = ShoppingItem(id: 3, name: 'Rice');
      final controller = buildController([rice]);
      await controller.initialize();

      final saved = await controller.updateShoppingItemDetails(
        item: rice,
        name: ' Brown rice ',
        note: ' 1 kg bag ',
        category: ShoppingCategory.home,
      );

      expect(saved, isTrue);
      expect(rice.name, 'Brown rice');
      expect(rice.note, '1 kg bag');
      expect(rice.category, ShoppingCategory.home);
    });

    test(
      'details refuse empty or duplicate names without changing the item',
      () async {
        final milk = ShoppingItem(id: 1, name: 'Milk');
        final rice = ShoppingItem(id: 2, name: 'Rice');
        final controller = buildController([milk, rice]);
        await controller.initialize();

        final emptySaved = await controller.updateShoppingItemDetails(
          item: rice,
          name: '   ',
          note: 'changed',
          category: ShoppingCategory.home,
        );
        final duplicateSaved = await controller.updateShoppingItemDetails(
          item: rice,
          name: 'milk',
          note: 'changed',
          category: ShoppingCategory.home,
        );

        expect(emptySaved, isFalse);
        expect(duplicateSaved, isFalse);
        expect(rice.name, 'Rice');
        expect(rice.note, isEmpty);
        expect(rice.category, ShoppingCategory.food);
      },
    );
  });
}
