import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_notice.dart';
import '../../core/widgets/quantity_stepper.dart';
import '../../models/shopping_item.dart';
import '../../state/shop_controller.dart';
import 'item_details_screen.dart';

enum ShoppingFilter {
  all('All'),
  toBuy('To buy'),
  bought('Bought');

  const ShoppingFilter(this.label);
  final String label;
}

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key, required this.controller});

  final ShopController controller;

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final itemController = TextEditingController();
  final itemFocusNode = FocusNode();
  ShoppingFilter filter = ShoppingFilter.all;
  bool adding = false;

  @override
  void dispose() {
    itemController.dispose();
    itemFocusNode.dispose();
    super.dispose();
  }

  List<ShoppingItem> get shownItems {
    switch (filter) {
      case ShoppingFilter.all:
        return [
          ...widget.controller.shoppingItems.where((item) => !item.bought),
          ...widget.controller.shoppingItems.where((item) => item.bought),
        ];
      case ShoppingFilter.toBuy:
        return widget.controller.shoppingItems
            .where((item) => !item.bought)
            .toList();
      case ShoppingFilter.bought:
        return widget.controller.shoppingItems
            .where((item) => item.bought)
            .toList();
    }
  }

  void showMessage(
    String message, {
    AppNoticeTone tone = AppNoticeTone.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showAppNotice(
      context,
      message: message,
      tone: tone,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  Future<void> addItem() async {
    if (adding) return;
    if (itemController.text.trim().isEmpty) {
      showMessage('Enter an item name to add it.', tone: AppNoticeTone.error);
      itemFocusNode.requestFocus();
      return;
    }
    setState(() => adding = true);
    try {
      final result = await widget.controller.addShoppingItem(
        itemController.text,
      );
      if (!mounted) return;
      final item = result.item;
      switch (result.status) {
        case AddShoppingItemStatus.added:
          itemController.clear();
          filter = ShoppingFilter.all;
        case AddShoppingItemStatus.quantityIncreased:
          itemController.clear();
          filter = ShoppingFilter.all;
          showMessage(
            '${item!.name} is already on the list: now ×${item.quantity}',
            tone: AppNoticeTone.info,
          );
        case AddShoppingItemStatus.invalid:
          showMessage(
            'Enter an item name to add it.',
            tone: AppNoticeTone.error,
          );
      }
      setState(() {});
      itemFocusNode.requestFocus();
    } catch (_) {
      if (!mounted) return;
      showMessage(
        'The item could not be saved. Try again.',
        tone: AppNoticeTone.error,
      );
    } finally {
      if (mounted) setState(() => adding = false);
    }
  }

  Future<void> deleteItem(ShoppingItem item) async {
    final originalIndex = widget.controller.shoppingItems.indexOf(item);
    try {
      await widget.controller.deleteShoppingItem(item);
      if (!mounted) return;
      showMessage(
        '${item.name} removed',
        tone: AppNoticeTone.info,
        actionLabel: 'Undo',
        onAction: () => unawaited(restoreItem(item, originalIndex)),
      );
    } catch (_) {
      if (!mounted) return;
      showMessage(
        '${item.name} could not be removed. Try again.',
        tone: AppNoticeTone.error,
      );
    }
  }

  Future<void> restoreItem(ShoppingItem item, int index) async {
    try {
      await widget.controller.restoreShoppingItem(item, index);
    } catch (_) {
      if (!mounted) return;
      showMessage(
        '${item.name} could not be restored. Try adding it again.',
        tone: AppNoticeTone.error,
      );
    }
  }

  Future<void> toggleItem(ShoppingItem item) async {
    try {
      await widget.controller.toggleShoppingItem(item);
    } catch (_) {
      if (!mounted) return;
      showMessage(
        '${item.name} could not be updated. Try again.',
        tone: AppNoticeTone.error,
      );
    }
  }

  Future<void> changeQuantity(ShoppingItem item, int change) async {
    try {
      await widget.controller.changeShoppingQuantity(item, change);
    } catch (_) {
      if (!mounted) return;
      showMessage(
        '${item.name} could not be updated. Try again.',
        tone: AppNoticeTone.error,
      );
    }
  }

  Future<void> openDetails(ShoppingItem item) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            ItemDetailsScreen(item: item, controller: widget.controller),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = shownItems;
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My list',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.controller.itemsLeft} ${widget.controller.itemsLeft == 1 ? 'item' : 'items'} left',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton.outlined(
                  onPressed: () {
                    itemFocusNode.requestFocus();
                    showMessage(
                      'Long-press an item to edit its details.',
                      tone: AppNoticeTone.info,
                    );
                  },
                  tooltip: 'Shopping list help',
                  icon: const Icon(Icons.info_outline),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: itemController,
                    focusNode: itemFocusNode,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => addItem(),
                    decoration: const InputDecoration(
                      hintText: 'Add an item…',
                      prefixIcon: Icon(Icons.add_shopping_cart_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: adding ? null : addItem,
                  child: Text(adding ? 'Adding…' : 'Add'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in ShoppingFilter.values)
                  ChoiceChip(
                    label: Text(option.label),
                    selected: filter == option,
                    onSelected: (_) => setState(() => filter = option),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: widget.controller.shoppingItems.isEmpty
                ? const AppEmptyState(
                    icon: Icons.playlist_add_rounded,
                    title: 'Your list is empty',
                    message: 'Add your first item above.',
                  )
                : items.isEmpty
                ? const AppEmptyState(
                    icon: Icons.filter_alt_off_outlined,
                    title: 'Nothing here',
                    message: 'Try another filter.',
                  )
                : ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _ShoppingItemTile(
                        item: item,
                        onToggle: () => unawaited(toggleItem(item)),
                        onDecrease: item.quantity > 1
                            ? () => unawaited(changeQuantity(item, -1))
                            : null,
                        onIncrease: () => unawaited(changeQuantity(item, 1)),
                        onDelete: () => deleteItem(item),
                        onLongPress: () => openDetails(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingItemTile extends StatelessWidget {
  const _ShoppingItemTile({
    required this.item,
    required this.onToggle,
    required this.onDecrease,
    required this.onIncrease,
    required this.onDelete,
    required this.onLongPress,
  });

  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onDelete;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final subtitle = item.note.isEmpty
        ? item.category.label
        : '${item.category.label} · ${item.note}';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onToggle,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 4, 8),
          child: Row(
            children: [
              Checkbox(
                value: item.bought,
                onChanged: (_) => onToggle(),
                semanticLabel: item.bought
                    ? 'Mark ${item.name} as not bought'
                    : 'Mark ${item.name} as bought',
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: item.bought ? AppTheme.muted : AppTheme.ink,
                        decoration: item.bought
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              QuantityStepper(
                quantity: item.quantity,
                onDecrease: onDecrease,
                onIncrease: onIncrease,
                compact: true,
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Remove ${item.name}',
                color: Theme.of(context).colorScheme.error,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
