import 'package:flutter/material.dart';
import 'package:shopping_list/core/theme/app_theme.dart';
import 'package:shopping_list/core/widgets/app_notice.dart';
import 'package:shopping_list/data/app_database.dart';
import 'package:shopping_list/data/product_repository.dart';
import 'package:shopping_list/models/shopping_item.dart';
import 'package:shopping_list/navigation/app_shell.dart';
import 'package:shopping_list/state/shop_controller.dart';

const screen = String.fromEnvironment('SCREEN', defaultValue: 'shop');

void main() {
  runApp(
    _ScreenshotApp(
      controller: ShopController(
        database: DemoDatabase(),
        repository: const ProductRepository(),
      ),
    ),
  );
}

class DemoDatabase extends AppDatabase {
  @override
  Future<List<ShoppingItem>> loadShoppingItems() async => [
    ShoppingItem(
      id: 1,
      name: 'Milk',
      quantity: 2,
      note: '1 litre bottle',
      category: ShoppingCategory.drinks,
    ),
    ShoppingItem(id: 2, name: 'Bread', quantity: 1),
    ShoppingItem(
      id: 3,
      name: 'Rice',
      quantity: 2,
      bought: true,
      category: ShoppingCategory.food,
    ),
  ];

  @override
  Future<Map<String, int>> loadCart() async => {'avocado': 2, 'bread': 1};

  @override
  Future<void> close() async {}
}

class _ScreenshotApp extends StatelessWidget {
  const _ScreenshotApp({required this.controller});

  final ShopController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _ScreenshotHome(controller: controller),
    );
  }
}

class _ScreenshotHome extends StatefulWidget {
  const _ScreenshotHome({required this.controller});

  final ShopController controller;

  @override
  State<_ScreenshotHome> createState() => _ScreenshotHomeState();
}

class _ScreenshotHomeState extends State<_ScreenshotHome> {
  late final Future<void> initialize;
  bool noticeShown = false;

  @override
  void initState() {
    super.initState();
    initialize = widget.controller.initialize();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initialize,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (screen == 'notice' && !noticeShown) {
          noticeShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showAppNotice(
              context,
              message: 'Milk removed from your list.',
              tone: AppNoticeTone.info,
              actionLabel: 'Undo',
            );
          });
        }
        final index = switch (screen) {
          'list' || 'notice' => 2,
          'cart' => 3,
          _ => 0,
        };
        return AppShell(controller: widget.controller, initialIndex: index);
      },
    );
  }
}
