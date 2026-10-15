# Shopping List+ Requirements

## Assignment acceptance checklist

- [x] Empty-list and empty-filter states are distinct.
- [x] Every item starts at quantity 1 and cannot go below 1.
- [x] Duplicate names increase quantity instead of creating a second row.
- [x] Delete offers Undo and restores the complete item.
- [x] All, To buy, and Bought filters work from the source list.
- [x] Bought items appear after active items in the All view.
- [x] Long-press opens editable item details.
- [x] Name, note, and category changes are validated and saved.
- [x] Shopping-list and cart data survive app restarts through SQLite.
- [x] CRUD operations and persistence-failure rollbacks are tested.

## Extended shopping experience

- [x] Browsable grocery catalogue and category navigation.
- [x] Product detail with cart and shopping-list actions.
- [x] Persistent cart quantities and calculated total.
- [x] Confirmed local checkout that clears persisted cart data.
- [x] Modern floating confirmations, errors, and Undo actions.
- [x] Responsive layouts, loading states, accessible labels, and reduced motion.

## Manual quality checks

1. Add ` milk ` when Milk already exists and confirm quantity increases.
2. Delete an item while a filter is active, then use Undo.
3. Edit a name to an existing name and confirm the save is refused.
4. Restart the app and confirm list and cart contents persist.
5. Place an order and confirm both the visible and persisted cart are empty.
6. Enable reduced motion and confirm nonessential motion is removed.

## Scope

The catalogue and checkout are intentionally local. No authentication, payment processor, network API, or backend is required for this design-focused project.
