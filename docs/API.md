# API Reference — Flutter Customer App

This document covers only the endpoints used by the Flutter customer app. For the full backend API (cashier, reports, WebSocket), see [Menu-Ordering/docs/API.md](https://github.com/xdranel/Menu-Ordering/blob/master/docs/API.md).

---

## Base URL

| Environment | URL |
|-------------|-----|
| Android emulator | `http://10.0.2.2:8080` |
| Physical device | `http://192.168.x.x:8080` |

Set via `API_BASE_URL` in `.env`.

---

## Authentication

None required. All customer endpoints are `permitAll()` in Spring Security.

The `/cashier/api/categories` endpoint is an exception — it lives under the cashier path but has been added to `permitAll()` explicitly since there is no `/customer/api/categories` equivalent.

---

## Response Envelope

All responses use:

```json
{
  "success": true,
  "message": "string",
  "data": {},
  "timestamp": "2025-01-01T12:00:00"
}
```

On error:
```json
{
  "success": false,
  "message": "Error description",
  "data": null
}
```

Flutter maps this to `ApiResponse<T>` in `lib/models/api_response.dart`.

---

## Categories

### Get All Categories

```http
GET /cashier/api/categories
```

**Response:**
```json
{
  "success": true,
  "data": [
    { "id": 1, "name": "SEMUA", "displayOrder": 1 },
    { "id": 2, "name": "PROMO", "displayOrder": 2 },
    { "id": 3, "name": "MAKANAN UTAMA", "displayOrder": 3 },
    { "id": 4, "name": "MINUMAN", "displayOrder": 4 }
  ]
}
```

Flutter model: `Category` (`lib/models/category_model.dart`)

---

## Menu

### Get Available Menu Items

```http
GET /customer/api/menus
```

**Query parameters:**

| Param | Type | Description |
|-------|------|-------------|
| `categoryId` | Long | Filter by category (omit for all) |
| `search` | String | Search by name/description |

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Nasi Goreng Spesial",
      "description": "Nasi goreng dengan ayam dan sayuran",
      "price": 35000,
      "promoPrice": null,
      "currentPrice": 35000,
      "isPromo": false,
      "available": true,
      "imageUrl": "/images/menu/nasi-goreng.jpg",
      "category": {
        "id": 3,
        "name": "MAKANAN UTAMA"
      }
    }
  ]
}
```

> `currentPrice` = `promoPrice` when `isPromo` is `true`, otherwise `price`.
> Flutter uses `MenuItem.getCurrentPrice()` — never read `.price` directly in UI.

Flutter model: `MenuItem` (`lib/models/menu_model.dart`)

**Field names (verified against `MenuResponse.java`):**

| Flutter field | JSON key | Notes |
|---------------|----------|-------|
| `available` | `available` | Not `isAvailable` |
| `isPromo` | `isPromo` | Not `isOnPromo` |
| `categoryId` | `category.id` | Nested object |
| `categoryName` | `category.name` | Nested object |

---

## Orders

### Create Order

```http
POST /customer/api/orders
Content-Type: application/json
```

**Request body:**
```json
{
  "orderType": "CUSTOMER_SELF",
  "customerName": "John Doe",
  "items": [
    { "menuId": 1, "quantity": 2 },
    { "menuId": 3, "quantity": 1 }
  ]
}
```

> `orderType` is required (`@NotNull`). Always send `"CUSTOMER_SELF"`.
> Item field is `menuId` (not `menuItemId`).
> No `tableNumber` or `notes` — `OrderRequest` does not have these fields.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 42,
    "orderNumber": "ORD-A1B2C3D4",
    "customerName": "John Doe",
    "total": 105000,
    "status": "PENDING",
    "paymentStatus": "PENDING",
    "orderType": "CUSTOMER_SELF",
    "items": [
      {
        "id": 1,
        "menu": {
          "id": 1,
          "name": "Nasi Goreng Spesial",
          "price": 35000,
          "available": true,
          "isPromo": false
        },
        "quantity": 2,
        "price": 35000,
        "subtotal": 70000
      }
    ],
    "createdAt": "2025-01-01T12:00:00"
  }
}
```

> `total` is always pre-tax. Flutter computes displayed total as `total * 1.10`.

Flutter model: `Order` (`lib/models/order_model.dart`)

---

### Get Order by Number

```http
GET /customer/api/orders/{orderNumber}
```

Returns the same shape as the Create Order response.

Used by `OrderTrackingScreen` — polled every 5 seconds until status is `COMPLETED` or `CANCELLED`.

---

### Order Status Values

| Value | Flutter enum | Meaning |
|-------|-------------|---------|
| `PENDING` | `OrderStatus.pending` | Just placed, not yet confirmed |
| `CONFIRMED` | `OrderStatus.confirmed` | Accepted by cashier |
| `PREPARING` | `OrderStatus.preparing` | Kitchen is cooking |
| `READY` | `OrderStatus.ready` | Ready for pickup |
| `COMPLETED` | `OrderStatus.completed` | Done — terminal state |
| `CANCELLED` | `OrderStatus.cancelled` | Cancelled — terminal state |

### Payment Status Values

| Value | Flutter enum | Meaning |
|-------|-------------|---------|
| `PENDING` | `PaymentStatus.pending` | Not yet paid |
| `PAID` | `PaymentStatus.paid` | Payment accepted |
| `FAILED` | `PaymentStatus.failed` | Payment failed |
| `REFUNDED` | `PaymentStatus.refunded` | Refunded |

---

## QR Code

### Generate QR Code for Order

```http
GET /customer/api/orders/{orderNumber}/qr-code
```

**Response:**
```json
{
  "success": true,
  "data": {
    "success": true,
    "orderNumber": "ORD-A1B2C3D4",
    "qrCodeImage": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
    "message": "QR code generated successfully"
  }
}
```

> `data` is a `PaymentResponse` object — not a plain string.
> The base64 image is at `data.qrCodeImage`.
> Flutter strips the `data:image/png;base64,` prefix then calls `base64Decode()` → `Uint8List` → `Image.memory()`.

---

## Payments

### Submit Payment

```http
POST /customer/api/payments
Content-Type: application/json
```

**Cash payment:**
```json
{
  "orderNumber": "ORD-A1B2C3D4",
  "paymentMethod": "CASH",
  "cashAmount": 120000
}
```

**QR payment:**
```json
{
  "orderNumber": "ORD-A1B2C3D4",
  "paymentMethod": "QR_CODE",
  "qrData": "payment_data_string"
}
```

> Payment method values are `CASH` and `QR_CODE`. The Flutter enum `PaymentMethod.qrCode` serializes to `"QR_CODE"` via `toApiString`.

**Response:**
```json
{
  "success": true,
  "data": {
    "success": true,
    "orderNumber": "ORD-A1B2C3D4",
    "message": "Payment successful",
    "change": 15000
  }
}
```

> `change` is only present for CASH payments.
> A successful payment auto-generates an invoice on the backend.

Flutter model: `PaymentMethod` (`lib/models/payment_model.dart`)

---

## Flutter Enum Serialization

| Dart enum | Sent to API | Received from API |
|-----------|-------------|-------------------|
| `PaymentMethod.cash` | `"CASH"` | `"CASH"` |
| `PaymentMethod.qrCode` | `"QR_CODE"` | `"QR_CODE"` |
| `OrderStatus.pending` | — | `"PENDING"` |
| `OrderStatus.confirmed` | — | `"CONFIRMED"` |
| `OrderStatus.preparing` | — | `"PREPARING"` |
| `OrderStatus.ready` | — | `"READY"` |
| `OrderStatus.completed` | — | `"COMPLETED"` |
| `OrderStatus.cancelled` | — | `"CANCELLED"` |
| `PaymentStatus.pending` | — | `"PENDING"` |
| `PaymentStatus.paid` | — | `"PAID"` |
| `PaymentStatus.failed` | — | `"FAILED"` |
| `PaymentStatus.refunded` | — | `"REFUNDED"` |

All incoming enum strings are parsed with `e.name.toUpperCase() == value` to handle case mismatch.

---

## Error Handling

| HTTP Status | Flutter handling |
|-------------|-----------------|
| 4xx | `ApiException(statusCode, message)` |
| 5xx | `ApiException(statusCode, message)` |
| No connection / timeout | `NetworkException` |

Both are caught in service methods and re-thrown; providers catch them and set `error` string for display.

---

**Last Updated:** 2026-05-02
