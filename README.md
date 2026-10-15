# Shopping List+

A complete, offline-first Flutter shopping experience with a grocery catalogue, personal shopping list, and persistent cart.

## Features

- Shows **Your list is empty** when the list has no items and **Nothing here** when only the current filter is empty.
- Gives every item a quantity stepper that starts at 1 and never goes below 1.
- Treats names case-insensitively and ignores surrounding spaces, so adding ` milk ` increases Milk's quantity instead of creating a duplicate.
- Deletes with an **Undo** action that restores the same item, position, quantity, and bought state.
- Filters by **All**, **To buy**, and **Bought**, with bought items kept at the bottom of All.
- Opens **Item details** on long-press, where the name, note, and Food/Drinks/Home category can be edited safely.
- Persists the list, quantities, bought status, notes, categories, catalogue cart, and cart quantities with SQLite.
- Completes checkout locally after confirmation and clears the persisted SQLite cart.
- Rolls optimistic changes back if a SQLite write fails, so the screen never lies about saved data.
- Uses compact floating top confirmations with clear status icons and Undo actions.
- Includes accessible labels, 44 px touch targets, keyboard submission, reduced-motion support, and responsive grocery grids.

## Screenshots

| Grocery catalogue | Shopping list |
| --- | --- |
| ![Grocery catalogue](screenshots/shop.png) | ![Shopping list quantity controls](screenshots/list.png) |

| Persistent cart | Floating confirmation |
| --- | --- |
| ![Shopping cart](screenshots/cart.png) | ![Modern top confirmation with Undo](screenshots/notice.png) |

## Run

```sh
flutter pub get
flutter run
```

The SQLite database is created as `shopping_list.db` in the app's database directory.

## Documentation

- [Architecture and data flow](docs/ARCHITECTURE.md)
- [Requirements and acceptance checklist](docs/REQUIREMENTS.md)

## Verify

```sh
flutter analyze
flutter test
flutter build ios --simulator
```
