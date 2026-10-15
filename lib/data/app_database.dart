import 'package:sqflite/sqflite.dart';

import '../models/shopping_item.dart';

class AppDatabase {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = '${await getDatabasesPath()}/shopping_list.db';
    _database = await openDatabase(
      path,
      version: 3,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
    return _database!;
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL COLLATE NOCASE UNIQUE,
        bought INTEGER NOT NULL DEFAULT 0,
        quantity INTEGER NOT NULL DEFAULT 1,
        note TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL DEFAULT 'food'
      )
    ''');
    await _createCartTable(db);

    final batch = db.batch();
    for (final name in ['Milk', 'Bread', 'Rice']) {
      batch.insert('items', {'name': name, 'bought': 0, 'quantity': 1});
    }
    await batch.commit(noResult: true);
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) await _createCartTable(db);
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE items ADD COLUMN note TEXT NOT NULL DEFAULT ''",
      );
      await db.execute(
        "ALTER TABLE items ADD COLUMN category TEXT NOT NULL DEFAULT 'food'",
      );
    }
  }

  Future<void> _createCartTable(Database db) {
    return db.execute('''
      CREATE TABLE cart_items (
        product_id TEXT PRIMARY KEY,
        quantity INTEGER NOT NULL
      )
    ''');
  }

  Future<List<ShoppingItem>> loadShoppingItems() async {
    final db = await database;
    final rows = await db.query('items', orderBy: 'bought ASC, id ASC');
    return rows.map(ShoppingItem.fromMap).toList();
  }

  Future<ShoppingItem> addShoppingItem(String name) async {
    final db = await database;
    final id = await db.insert('items', {
      'name': name,
      'bought': 0,
      'quantity': 1,
      'note': '',
      'category': ShoppingCategory.food.name,
    });
    return ShoppingItem(id: id, name: name);
  }

  Future<void> updateShoppingItem(ShoppingItem item) async {
    final db = await database;
    await db.update(
      'items',
      {
        'name': item.name,
        'bought': item.bought ? 1 : 0,
        'quantity': item.quantity,
        'note': item.note,
        'category': item.category.name,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> restoreShoppingItem(ShoppingItem item) async {
    final db = await database;
    await db.insert('items', {
      'id': item.id,
      'name': item.name,
      'bought': item.bought ? 1 : 0,
      'quantity': item.quantity,
      'note': item.note,
      'category': item.category.name,
    });
  }

  Future<void> deleteShoppingItem(int id) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearBoughtItems() async {
    final db = await database;
    return db.delete('items', where: 'bought = ?', whereArgs: [1]);
  }

  Future<Map<String, int>> loadCart() async {
    final db = await database;
    final rows = await db.query('cart_items');
    return {
      for (final row in rows)
        row['product_id']! as String: row['quantity']! as int,
    };
  }

  Future<void> saveCartQuantity(String productId, int quantity) async {
    final db = await database;
    if (quantity <= 0) {
      await db.delete(
        'cart_items',
        where: 'product_id = ?',
        whereArgs: [productId],
      );
      return;
    }
    await db.insert('cart_items', {
      'product_id': productId,
      'quantity': quantity,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
