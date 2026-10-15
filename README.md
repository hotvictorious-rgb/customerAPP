# 🛍️ Victorious MARKET — Customer Mobile App (`customerAPP`)

> **Sovereign Omnichannel Retail & Directional Logistics Operating System**  
> **Brand Palette:** Royal Purple (`#5E17EB`) & Rich Gold (`#FFD700`)  
> **Framework:** Flutter 3.x (Dart 3.x) with **Provider** & **DioClient**  
> **Target Audience:** Nigerian Shoppers & Akwa Ibom Commercial Corridors (Uyo, Eket, Ikot Ekpene, Oron)

This is the brand-new, clean, production-grade Flutter Customer App for **Victorious MARKET**. Built completely from scratch with zero 6valley legacy code, pure clean architecture, and 100% alignment with the `newVmarket` backend API contracts.

---

## 🎨 Visual Identity & Brand Design Tokens

| Token | Hex | Role |
|---|---|---|
| **Primary Royal Purple** | `#5E17EB` | Top navigation app bar, primary checkout buttons, active indicators |
| **Dark Purple** | `#3B0B99` | Gradient transitions, header contrast surfaces |
| **Secondary Rich Gold** | `#FFD700` | Cashback badges, VIP tags, OTP security highlights |
| **Gold Deep Accent** | `#FFA000` | Rating stars, discount tags |
| **Scaffold Background** | `#F8F9FA` | Ultra-clean, high-contrast surface |
| **Card Surface** | `#FFFFFF` | Bordered cards, product tiles, modals |

---

## 📱 Complete Screen Inventory (All 16 Core Screens & Features)

1. **Splash Screen** (`lib/screens/splash/splash_screen.dart`): Animated luxury launch screen featuring `vm_icon.jpg`, Royal Purple background, Gold accents, and background token initialization.
2. **Customer Sign In** (`lib/screens/auth/login_screen.dart`): Email or phone number login, password toggle, test credential quick-filler, Sanctum Bearer token persistence.
3. **Customer Registration** (`lib/screens/auth/register_screen.dart`): Full customer registration with Nigerian phone validation and auto-login.
4. **Main 5-Tab Navigation Shell** (`lib/screens/shell/main_navigation_shell.dart`): Persistent bottom navigation with dynamic shopping bag badge counter (Market, Explore, Bag, Orders, Account).
5. **Marketplace Home Screen** (`lib/screens/home/home_screen.dart`):
   - Royal Purple Header with search bar pill
   - Call-to-Order pill (`📞 +2349118949035`)
   - 5% Sovereign Cashback banner
   - Directional LGA Corridor quick-filter chips (All Akwa Ibom, Uyo, Eket, Ikot Ekpene, Oron)
   - Circular category capsules
   - Flagship verified products carousel
   - Verified 2-column product grid with pull-to-refresh
6. **Explore & Search Catalog** (`lib/screens/catalog/catalog_screen.dart`): Live keyword search with category choice chips and empty state resets.
7. **Product Details Screen** (`lib/screens/catalog/product_details_screen.dart`):
   - Multi-image swipeable gallery with dot indicators
   - Naira price (`₦`) + 5% Cashback preview tag
   - Verified fresh stock badge (7-day freshness lifecycle)
   - Verified merchant card with in-shop pickup opening hours
   - Sticky action bar: "Add to Bag", "Buy Now", and **"Reserve for In-Shop Pickup (₦0.00 Paid Upfront)"**.
8. **Shopping Bag / Cart** (`lib/screens/cart/cart_screen.dart`): Item steppers (+/-), line totals, subtotal summary, "Proceed to Directional Checkout".
9. **Directional Checkout** (`lib/screens/checkout/checkout_screen.dart`):
   - Dual-mode switch: **Doorstep Delivery** vs **In-Shop Pickup**
   - Address selector with live directional lane rate calculation (`POST /api/v1/fulfillment/availability`)
   - 5% Sovereign Cashback redemption toggle (`use_cashback: true`)
   - Authoritative frozen checkout intent generation (`POST /api/v1/checkout/intent`)
   - Paystack payment gateway dialog
10. **In-Shop Inspection Reservation Pass** (`lib/screens/reservations/pickup_reservation_pass_screen.dart`):
    - 24-hr `₦0.00` down reservation pass
    - High-contrast `RES-XXXXXXXX` code & QR code
    - Merchant shop branch address, phone, and physical inspection rules
11. **Order History List** (`lib/screens/orders/orders_list_screen.dart`): Card list of ongoing and completed orders with status chips and "Track Live & PIN" buttons.
12. **Live Order Tracking & Secret OTP Card** (`lib/screens/orders/order_tracking_screen.dart`):
    - Prominent Gold Card: **Secret 6-Digit Delivery PIN** (`OtpSecurityCard`) with strict doorstep inspection rules
    - 5-stage live delivery progress stepper (Confirmed ➔ Processing ➔ Handover Ready ➔ Out for Delivery ➔ Delivered)
    - Assigned courier card with motorcycle plate number and one-tap call button
    - Itemized order receipt with 5% cashback awarded
    - Customer doorstep handover confirmation action
13. **Sovereign Rewards Wallet** (`lib/screens/wallet/wallet_cashback_screen.dart`):
    - Gold card showing Available Cashback (`₦`) and Pending Maturation
    - Strict 90/5/5 Mathematical Split guarantee breakdown
    - Redemption rules
14. **Saved Addresses** (`lib/screens/address/address_list_screen.dart`): Manage home, office, and branch addresses.
15. **Add New Address** (`lib/screens/address/add_address_screen.dart`): Canonical geography selector: Country (Nigeria) ➔ State (Akwa Ibom) ➔ LGA (Uyo, Eket, Ikot Ekpene, etc.) cascade.
16. **My Account & Support** (`lib/screens/account/account_screen.dart` & `lib/screens/support/support_screen.dart`):
    - Profile summary with name, email, avatar
    - API Server endpoint configurator (dev server, LAN IP, or live domain)
    - WhatsApp official desk, Call to Order, FAQs.

---

## 🛠️ Architecture & Invariants

```
lib/
├── core/
│   ├── constants/       # AppColors, ApiEndpoints, AppConstants
│   ├── network/         # ApiClient (Dio with token interceptor & error mapping)
│   ├── services/        # StorageService (flutter_secure_storage + SharedPreferences)
│   ├── theme/           # AppTheme (GoogleFonts Plus Jakarta Sans, Royal Purple/Gold tokens)
│   └── utils/           # CurrencyFormatter (₦ Naira arbitrary-precision formatting)
├── models/              # Clean immutable data models matching API contracts
├── providers/           # Provider state management (Auth, Catalog, Cart, Address, Checkout, Order, Cashback)
├── screens/             # 16 complete UI screens
└── widgets/             # Reusable UI components (ProductCard, BrandAppBar, OtpSecurityCard, DeliveryStepper, CallToOrderPill)
```

### Invariants Enforced:
1. **Untrusted Presentation Client:** The app never invents delivery fees, taxes, discounts, or stock logic. Everything is rendered from backend snapshots.
2. **Zero 6valley Baggage:** Every line of code is modular, modern Dart/Flutter without deprecated widgets or foreign business rules.
3. **Akwa Ibom Directional Lanes:** LGA-to-LGA rates strictly queried from the backend engine.

---

## 🚀 How to Run

### 1. Prerequisites
- Flutter SDK 3.x+
- Android Studio / Xcode

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run on Device / Emulator
```bash
flutter run
```

Ensure the `newVmarket` backend server is running on `http://127.0.0.1:8080` (or update the server URL via the in-app Account ➔ API Server Endpoint menu).
