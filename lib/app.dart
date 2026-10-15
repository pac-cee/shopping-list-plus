import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'navigation/app_shell.dart';
import 'state/shop_controller.dart';

class BasketApp extends StatefulWidget {
  const BasketApp({super.key, required this.controller, this.initialIndex = 0});

  final ShopController controller;
  final int initialIndex;

  @override
  State<BasketApp> createState() => _BasketAppState();
}

class _BasketAppState extends State<BasketApp> {
  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AppShell(
        controller: widget.controller,
        initialIndex: widget.initialIndex,
      ),
    );
  }
}
