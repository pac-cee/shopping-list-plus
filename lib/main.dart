import 'package:flutter/material.dart';

import 'app.dart';
import 'data/app_database.dart';
import 'data/product_repository.dart';
import 'state/shop_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BasketApp(
      controller: ShopController(
        database: AppDatabase(),
        repository: const ProductRepository(),
      ),
    ),
  );
}
