import 'package:flutter/material.dart';

import '../../core/widgets/app_notice.dart';
import '../../models/shopping_item.dart';
import '../../state/shop_controller.dart';

class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({
    super.key,
    required this.item,
    required this.controller,
  });

  final ShoppingItem item;
  final ShopController controller;

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController noteController;
  late ShoppingCategory category;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item.name);
    noteController = TextEditingController(text: widget.item.note);
    category = widget.item.category;
  }

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() => saving = true);
    try {
      final saved = await widget.controller.updateShoppingItemDetails(
        item: widget.item,
        name: nameController.text,
        note: noteController.text,
        category: category,
      );
      if (!mounted) return;
      if (!saved) {
        setState(() => saving = false);
        showAppNotice(
          context,
          message: 'That item is already on the list. Choose another name.',
          tone: AppNoticeTone.error,
        );
        return;
      }
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => saving = false);
      showAppNotice(
        context,
        message: 'Your changes could not be saved. Try again.',
        tone: AppNoticeTone.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item details')),
      body: SafeArea(
        top: false,
        child: Form(
          key: formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Text(
                'Make this item easy to recognise in the aisle.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Milk',
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Enter an item name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: noteController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'The 1 litre bottle',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              Text('Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in ShoppingCategory.values)
                    ChoiceChip(
                      label: Text(option.label),
                      selected: category == option,
                      onSelected: (_) => setState(() => category = option),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: saving ? null : save,
                icon: saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(saving ? 'Saving…' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
