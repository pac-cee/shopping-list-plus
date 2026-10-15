import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/cart/cart_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/shop/shop_screen.dart';
import '../features/shopping_list/shopping_list_screen.dart';
import '../state/shop_controller.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.controller, this.initialIndex = 0});

  final ShopController controller;
  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final PageController pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex.clamp(0, 3);
    pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void selectPage(int index) {
    setState(() => currentIndex = index);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      pageController.jumpToPage(index);
    } else {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (widget.controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (widget.controller.loadError case final error?) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(error, textAlign: TextAlign.center),
              ),
            ),
          );
        }

        return Scaffold(
          body: PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ShopScreen(controller: widget.controller),
              CategoriesScreen(controller: widget.controller),
              ShoppingListScreen(controller: widget.controller),
              CartScreen(
                controller: widget.controller,
                onBrowse: () => selectPage(0),
              ),
            ],
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: selectPage,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront),
                  label: 'Shop',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view_rounded),
                  label: 'Categories',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.checklist_rounded),
                  selectedIcon: Icon(Icons.fact_check_rounded),
                  label: 'My List',
                ),
                NavigationDestination(
                  icon: _CartIcon(count: widget.controller.cartCount),
                  selectedIcon: _CartIcon(
                    count: widget.controller.cartCount,
                    selected: true,
                  ),
                  label: 'Cart',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CartIcon extends StatelessWidget {
  const _CartIcon({required this.count, this.selected = false});

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      label: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Text(count > 99 ? '99+' : '$count', key: ValueKey(count)),
      ),
      child: Icon(selected ? Icons.shopping_bag : Icons.shopping_bag_outlined),
    );
  }
}
