# Shopping List+ Architecture

## Overview

Shopping List+ is an offline-first Flutter application. Widgets render current state, `ShopController` owns the business rules, and `AppDatabase` is the single persistence boundary. The grocery catalogue is bundled locally, so the app requires no server or account.

```text
Screens and reusable widgets
          |
          v
 ShopController (rules and UI state)
          |
          +----------> ProductRepository (local catalogue)
          |
          v
 AppDatabase (SQLite v3)
          |
          +----------> items
          +----------> cart_items
```

## Main modules

| Area | Responsibility |
| --- | --- |
| `lib/features/` | Shop, categories, list, item details, product details, and cart screens |
| `lib/state/shop_controller.dart` | Quantities, filtering source data, validation, totals, checkout, and persistence coordination |
| `lib/data/app_database.dart` | SQLite creation, migration, reads, writes, and deletes |
| `lib/data/product_repository.dart` | Read-only local grocery catalogue |
| `lib/core/` | Theme and shared feedback/navigation widgets |
| `lib/models/` | Shopping item, product, and cart value objects |

## SQLite model

The database is `shopping_list.db`, schema version 3.

### `items`

| Column | Purpose |
| --- | --- |
| `id` | Stable integer primary key |
| `name` | Case-insensitive unique item name |
| `bought` | Stored boolean (`0` or `1`) |
| `quantity` | Bounded item quantity |
| `note` | Optional detail text |
| `category` | Food, drinks, or home |

### `cart_items`

| Column | Purpose |
| --- | --- |
| `product_id` | Product key and primary key |
| `quantity` | Persisted cart quantity |

Version 2 added the cart table. Version 3 added item notes and categories. Existing installations migrate without deleting user data.

## CRUD and business rules

| Operation | Shopping list | Cart |
| --- | --- | --- |
| Create | Add a cleaned, non-empty name | Add a catalogue product |
| Read | Load and filter saved items | Load saved product quantities |
| Update | Toggle, change quantity, rename, note, or category | Increase or decrease quantity |
| Delete | Delete one, clear bought, then optionally Undo | Reduce to zero or clear after checkout |

- Item names are compared case-insensitively; adding a duplicate increases its quantity.
- List quantities stay between 1 and 99. Cart quantities stay between 0 and 99.
- Filtered rows act on stable item objects rather than visible indexes.
- Optimistic updates make the interface immediate. Every SQLite failure restores the previous in-memory value and displays an error notice.
- Checkout requires confirmation, clears the database and UI together, and rolls back if the database write fails.
- Delete Undo restores the original id, order, quantity, bought state, note, and category.

## Feedback and accessibility

Confirmations use a floating top notice instead of a bottom snackbar. This keeps feedback close to the page heading and away from bottom navigation, with status icon, short message, and contextual Undo. Notices are announced as live regions. Controls use descriptive semantics, practical touch targets, and reduced-motion behavior.

## Verification

```sh
flutter analyze
flutter test
flutter build ios --simulator
```

The controller tests cover normal operations and failed-write rollback behavior.
