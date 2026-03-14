# Team Workflow For Parallel Development

## 1. One-Time Setup (Done)
- Shared architecture is created under `lib/`:
  - `models/`
  - `services/`
  - `providers/`
  - `screens/`
  - `widgets/`
- Routing is centralized in `lib/core/routes/app_routes.dart`.
- App theme and constants are centralized in `lib/core/theme/` and `lib/core/constants/`.

## 2. Ownership To Avoid Conflicts
- Member 1: `lib/screens/home/` and `lib/providers/product_provider.dart`
- Member 2: `lib/screens/product_detail/`
- Member 3: `lib/screens/cart/` and `lib/providers/cart_provider.dart`
- Member 4: `lib/screens/checkout/`, `lib/screens/orders/`, `lib/providers/order_provider.dart`
- Shared files (only touch when needed and announce in group first):
  - `lib/core/routes/app_routes.dart`
  - `lib/models/`
  - `lib/services/`
  - `lib/app.dart`

## 3. Branch Strategy
- Main integration branch: `develop`
- Feature branch per person:
  - `feature/home-ui`
  - `feature/product-detail`
  - `feature/cart-state`
  - `feature/checkout-orders`
- Always create PR into `develop`, do not push directly to `main`.

## 4. Daily Sync Rule
- Before coding: pull latest `develop`.
- End of day: open PR with small scope and clear title.
- If changing model/provider contract, notify team before merge.

## 5. Local Validation Before PR
Run these commands:

```bash
flutter pub get
flutter analyze
flutter test
```

If all pass, open PR.

## 6. Important Requirement Reminder
- Keep app bar title format: `TH4 - Nhom [So nhom]` in home screen.
- Cart state must be managed with Provider, not by passing cart list across screens.
- Keep persistence in providers via `LocalStorageService`.
