# Farmers Market App

> Flutter POS operator mobile app for agricultural marketplace in Côte d'Ivoire. Operators manage farmer profiles, place orders, and record commodity repayments.

## Live App

https://koumolou.github.io/farmers-market-app/

## Quick Test (No Setup Required)

The app is live and ready to use. Login with the operator account to test the full POS flow:

- Email: `operator@farmarket.ci`
- Password: `password`

## Backend API

https://web-production-09f71f.up.railway.app/api

---

## Tech Stack

- Flutter 3.x + Dart 3
- Riverpod — state management
- go_router — navigation
- Dio — HTTP client with auth interceptor
- flutter_secure_storage — token persistence
- Clean architecture: Screen → Provider → Repository → API

---

## Local Setup

### Requirements

- Flutter 3.x
- Dart 3.x

### Steps

```bash
git clone https://github.com/koumolou/farmers-market-app.git
cd farmers-market-app
flutter pub get
```

Make sure your Laravel API is running locally, then update the base URL in:

```dart
// lib/core/constants/api_constants.dart
static const String baseUrl = 'http://localhost:8000/api';
```

Run the app:

```bash
flutter run -d chrome
```

---

## Demo Credentials

| Role       | Email                   | Password |
| ---------- | ----------------------- | -------- |
| Operator   | operator@farmarket.ci   | password |
| Supervisor | supervisor@farmarket.ci | password |
| Admin      | admin@farmarket.ci      | password |

> Note: Only operators can place orders and record repayments. New Order and New Farmer buttons are hidden for other roles.

---

## App Features

| Feature             | Description                                                 |
| ------------------- | ----------------------------------------------------------- |
| Login               | Sanctum token authentication with secure storage            |
| Farmer lookup       | Search by farmer card ID or phone number                    |
| Create farmer       | New farmer profile with credit limit                        |
| Category navigation | Nested category browsing (2+ levels)                        |
| Product selection   | Add to cart with quantity control                           |
| Checkout            | Cash or credit payment with live total and interest preview |
| Credit enforcement  | UI reflects API block when credit limit exceeded            |
| Farmer profile      | Outstanding debt summary with progress bar                  |
| Debt list           | All open and partial debts with FIFO order indicator        |
| Repayment           | kg input with live FCFA conversion preview                  |
| Role-based UI       | Operator-only actions hidden from admin and supervisor      |

---

## Project Structure

lib/
├── core/
│ ├── constants/ # API URLs
│ ├── network/ # Dio client with auth interceptor
│ ├── storage/ # Secure token + role storage
│ ├── errors/ # AppException + error parsing
│ ├── providers/ # Role provider
│ └── router/ # go_router with auth guard
├── features/
│ ├── auth/ # Login screen, auth provider
│ ├── farmers/ # Farmer search, profile, create
│ ├── products/ # Category navigation, product grid
│ ├── checkout/ # Cart, checkout screen
│ └── debts/ # Debt list, repayment screen
└── shared/
└── widgets/ # AppSnackbar, AppButton

---

## Deployment

The Flutter web app is deployed to GitHub Pages from the `gh-pages` branch.

To rebuild and redeploy:

```bash
flutter build web --base-href /farmers-market-app/
cd build/web
git init
git add .
git commit -m "deploy"
git remote add origin https://github.com/koumolou/farmers-market-app.git
git push origin HEAD:gh-pages --force
cd ../..
```

---
