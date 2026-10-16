/// Authoritative Backend API Endpoints matching newVmarket backend
class ApiEndpoints {
  // Configurable base URL with build-time environment override
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  // System & App Remote Configuration (Zero-Hardcoded)
  static const String appConfig = '/api/v1/config';

  // Auth
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String me = '/api/v1/auth/me';

  // Geography (Canonical: Country -> State -> LGA)
  static const String countries = '/api/v1/geography/countries';
  static const String states = '/api/v1/geography/states/';
  static const String lgas = '/api/v1/geography/lgas/';

  // Customer Addresses
  static const String addressList = '/api/v1/customer/address/list';
  static const String addressAdd = '/api/v1/customer/address/add';

  // Catalog & Storefront Dynamic Banners
  static const String banners = '/api/v1/banners';
  static const String categories = '/api/v1/categories';
  static const String products = '/api/v1/products';
  static const String productDetails = '/api/v1/products/'; // + {id}

  // Fulfillment Availability & Directional Lanes
  static const String fulfillmentAvailability = '/api/v1/fulfillment/availability';

  // Checkout & Sovereign Cashback
  static const String checkoutIntent = '/api/v1/checkout/intent';
  static const String checkoutExecute = '/api/v1/customer/orders/checkout';
  static const String cashbackBalance = '/api/v1/customer/cashback';

  // In-Shop Inspection Reservations (₦0.00 down)
  static const String createReservation = '/api/v1/pickup-reservations/create';
  static const String getReservation = '/api/v1/pickup-reservations/'; // + {code}

  // Customer Orders & 5-Stage Live Tracking Handshake
  static const String customerOrders = '/api/v1/customer/orders';
  static const String customerOrderDetails = '/api/v1/customer/orders/'; // + {order_number}
  static const String verifyPayment = '/api/v1/customer/orders/verify-payment';
  static const String confirmDelivery = '/api/v1/customer/orders/'; // + {order_number}/confirm-delivery

  // Customer Wallet Credits (100% Spendable Refund Balance)
  static const String customerWallet = '/api/v1/customer/wallet';

  // Customer 24h Post-Delivery Disputes & Item-Level Returns
  static const String orderDispute = '/api/v1/customer/orders/'; // + {order_number}/dispute
  static const String returnCases = '/api/v1/customer/returns';
  static const String createReturnCase = '/api/v1/customer/returns/create';
  static const String returnCaseDetails = '/api/v1/customer/returns/'; // + {case_number}
  static const String reorderRejectedItems = '/api/v1/customer/orders/reorder-rejected-items';

  // Customer Verified Product Reviews (Only Delivered Purchases)
  static const String productReviews = '/api/v1/products/'; // + {id}/reviews
  static const String submitReview = '/api/v1/customer/reviews';
  static const String myReviews = '/api/v1/customer/reviews/my-reviews';
}
