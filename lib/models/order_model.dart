import 'product_model.dart';
import '../core/utils/currency_formatter.dart';

class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final String unitPrice;
  final int quantity;
  final String lineTotal;
  final String? thumbnail;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    this.thumbnail,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productName: json['product'] != null ? json['product']['name'] : (json['name'] ?? 'Product Item'),
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      quantity: json['quantity'] as int? ?? 1,
      lineTotal: json['line_total']?.toString() ?? '0.00',
      thumbnail: json['product'] != null ? json['product']['thumbnail'] : null,
    );
  }

  String get formattedPrice => CurrencyFormatter.format(unitPrice);
  String get formattedTotal => CurrencyFormatter.format(lineTotal);
}

class OrderModel {
  final int id;
  final String orderNumber;
  final String fulfillmentType;
  final String orderStatus;
  final String paymentStatus;
  final String merchandiseSubtotal;
  final String deliveryFee;
  final String cashbackRedeemed;
  final String grandTotal;
  final String customerCashback5;
  final String? verificationCode; // Secret 6-digit Delivery OTP
  final String? shopName;
  final String? shopAddress;
  final String? shopPhone;
  final String? riderName;
  final String? riderPhone;
  final String? riderVehicle;
  final List<OrderItemModel> items;
  final String createdAt;
  final String? riderArrivedAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.fulfillmentType,
    required this.orderStatus,
    required this.paymentStatus,
    required this.merchandiseSubtotal,
    required this.deliveryFee,
    required this.cashbackRedeemed,
    required this.grandTotal,
    required this.customerCashback5,
    this.verificationCode,
    this.shopName,
    this.shopAddress,
    this.shopPhone,
    this.riderName,
    this.riderPhone,
    this.riderVehicle,
    this.items = const [],
    required this.createdAt,
    this.riderArrivedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItemModel> parsedItems = [];
    if (json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    String? rName;
    String? rPhone;
    String? rVeh;
    if (json['rider'] != null) {
      final r = json['rider'];
      rVeh = r['vehicle_plate_number'] as String?;
      if (r['user'] != null) {
        rName = r['user']['name'] as String?;
        rPhone = r['user']['phone'] as String?;
      }
    }

    return OrderModel(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String? ?? 'ORD-000',
      fulfillmentType: json['fulfillment_type'] as String? ?? 'doorstep_delivery',
      orderStatus: json['order_status'] as String? ?? 'confirmed',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      merchandiseSubtotal: json['merchandise_subtotal']?.toString() ?? '0.00',
      deliveryFee: json['delivery_fee']?.toString() ?? '0.00',
      cashbackRedeemed: json['cashback_redeemed']?.toString() ?? '0.00',
      grandTotal: json['grand_total']?.toString() ?? '0.00',
      customerCashback5: json['customer_cashback_5']?.toString() ?? '0.00',
      verificationCode: json['verification_code'] as String?,
      shopName: json['shop'] != null ? json['shop']['name'] : 'Merchant Shop',
      shopAddress: json['shop'] != null ? json['shop']['address'] : null,
      shopPhone: json['shop'] != null ? json['shop']['phone'] : null,
      riderName: rName,
      riderPhone: rPhone,
      riderVehicle: rVeh,
      items: parsedItems,
      createdAt: json['created_at'] as String? ?? '',
      riderArrivedAt: json['rider_arrived_at'] as String?,
    );
  }

  String get formattedTotal => CurrencyFormatter.format(grandTotal);
  String get formattedSubtotal => CurrencyFormatter.format(merchandiseSubtotal);
  String get formattedDeliveryFee => CurrencyFormatter.format(deliveryFee);
  String get formattedCashbackEarned => CurrencyFormatter.format(customerCashback5);

  bool get isDoorstepDelivery => fulfillmentType == 'doorstep_delivery';
  bool get isDelivered => orderStatus == 'delivered' || orderStatus == 'completed';
  bool get isOutForDelivery => orderStatus == 'out_for_delivery';
  bool get riderArrived => riderArrivedAt != null;

  int get statusStepIndex {
    switch (orderStatus.toLowerCase()) {
      case 'confirmed':
        return 0;
      case 'processing':
        return 1;
      case 'ready_for_pickup':
        return 2;
      case 'out_for_delivery':
        return 3;
      case 'delivered':
      case 'completed':
        return 4;
      default:
        return 0;
    }
  }
}
