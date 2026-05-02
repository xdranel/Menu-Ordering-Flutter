# ChopChop — Customer Ordering App (Flutter)

Flutter mobile application for the ChopChop restaurant ordering system. Customers scan a QR code or open the app at their table, browse the menu, place an order, and pay — all without staff interaction.

This is the customer-facing mobile client. The Spring Boot backend that powers it lives at [Menu-Ordering](https://github.com/xdranel/Menu-Ordering).

---

## Features

- Browse menu by category with live availability status
- Promo pricing — discounted items show both original and sale price
- Local cart with quantity controls and swipe-to-delete
- Order placement → confirmation → payment → real-time status tracking
- Two payment methods: Cash (with suggested rounding) and QRIS (QR code scan)
- Polling order status every 5 seconds until complete or cancelled

---

## Tech Stack

| Layer | Library |
|-------|---------|
| State management | [Provider](https://pub.dev/packages/provider) 6.x |
| Navigation | [GoRouter](https://pub.dev/packages/go_router) 13.x |
| HTTP | [Dio](https://pub.dev/packages/dio) 5.x |
| Image caching | [cached_network_image](https://pub.dev/packages/cached_network_image) |
| Env config | [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) |
| Formatting | [intl](https://pub.dev/packages/intl) (IDR currency) |

---

## Prerequisites

- Flutter SDK 3.x (`flutter --version`)
- Dart SDK ^3.11.5 (bundled with Flutter)
- Android emulator or physical device
- The Spring Boot backend running locally (see [Menu-Ordering](https://github.com/xdranel/Menu-Ordering))

---

## Quick Start

### 1. Clone and install

```bash
git clone https://github.com/xdranel/Menu-Ordering-Flutter
cd Menu-Ordering-Flutter
flutter pub get
```

### 2. Configure environment

```bash
cp .env.example .env
```

Edit `.env`:

```
# Android emulator (default)
API_BASE_URL=http://10.0.2.2:8080

# Physical device — replace with your machine's local IP
# API_BASE_URL=http://192.168.x.x:8080
```

### 3. Start the backend

Follow [Menu-Ordering/docs/INSTALLATION.md](https://github.com/xdranel/Menu-Ordering/blob/master/docs/INSTALLATION.md) to run the Spring Boot backend on port 8080.

### 4. Run the app

```bash
flutter run
```

---

## Project Structure

```
lib/
├── core/
│   ├── api_client.dart       # Dio singleton with interceptors
│   ├── constants.dart        # Tax rate, currency formatter, cash rounding
│   ├── exceptions.dart       # ApiException, NetworkException
│   ├── router.dart           # GoRouter routes
│   └── theme.dart            # AppTheme (colors, typography, component styles)
│
├── models/
│   ├── api_response.dart     # Generic ApiResponse<T> envelope
│   ├── category_model.dart
│   ├── menu_model.dart
│   ├── cart_item_model.dart  # Local only — not sent to backend
│   ├── order_item_model.dart
│   ├── order_model.dart      # Enums: OrderStatus, PaymentStatus
│   └── payment_model.dart    # Enum: PaymentMethod (cash, qrCode)
│
├── services/
│   ├── menu_service.dart     # GET /cashier/api/categories, GET /customer/api/menus
│   ├── order_service.dart    # POST/GET /customer/api/orders
│   └── payment_service.dart  # POST /customer/api/payments, GET QR code
│
├── providers/
│   ├── menu_provider.dart    # Menu + categories state
│   ├── cart_provider.dart    # Local cart state
│   └── order_provider.dart   # Active order, payment, polling
│
├── screens/
│   ├── menu_screen.dart
│   ├── cart_screen.dart
│   ├── payment_screen.dart
│   ├── order_confirmation_screen.dart
│   └── order_tracking_screen.dart
│
├── widgets/
│   ├── menu_card.dart
│   ├── cart_badge.dart
│   ├── cart_item_tile.dart
│   ├── category_tab_bar.dart
│   ├── order_status_badge.dart
│   ├── price_display.dart
│   └── quantity_selector.dart
│
├── app.dart                  # MaterialApp.router
└── main.dart                 # dotenv.load() + MultiProvider + runApp
```

---

## Screen Flow

```
MenuScreen
  ↓ browse, tap item → cart
CartScreen  [name · notes (optional)]
  ↓ Place Order
OrderConfirmationScreen
  ↓ Pay Now
PaymentScreen  [Cash · QRIS]
  ↓ Confirm Payment
OrderTrackingScreen  [polls every 5s]
  ↓ Completed / Cancelled
MenuScreen  [start over]
```

---

## Environment Variables

| Key | Example | Description |
|-----|---------|-------------|
| `API_BASE_URL` | `http://10.0.2.2:8080` | Backend base URL |

Use `10.0.2.2` for Android emulator (maps to host machine localhost). For a physical device, use your machine's LAN IP (`192.168.x.x`).

---

## Business Rules

- **Tax:** 10% applied client-side — `Order.total` from backend is always pre-tax
- **Cash suggestion:** rounded up to the nearest IDR 1,000 after tax
- **Payment method values:** `CASH` or `QR_CODE` (not `QRIS`)
- **Order status flow:** `PENDING` → `CONFIRMED` → `PREPARING` → `READY` → `COMPLETED` (or `CANCELLED`)

---

## Documentation

- [docs/INSTALLATION.md](docs/INSTALLATION.md) — full setup guide including Android configuration
- [docs/API.md](docs/API.md) — customer API reference (endpoints used by this app)

---

## Related

- [Menu-Ordering](https://github.com/xdranel/Menu-Ordering) — Spring Boot backend (cashier dashboard + REST API)

## Authors

- [Gendhi Ramona P](https://github.com/XDX1O1)
- [Anak Agung Bramasta Jaya](https://github.com/BramastaJaya)
- [Haidar Fulca Kurniawan](https://github.com/sijuki09)
- [Arka Dwi Indrastata](https://github.com/Arkkop12)
- [Fitria Nur Rofika](https://github.com/fitrianurrofika)
- [Khansa Nailah Anjani](https://github.com/Ssa4a)