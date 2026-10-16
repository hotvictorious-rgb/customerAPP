import 'product_model.dart';
import '../core/utils/currency_formatter.dart';

class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final String unitPrice;
  final int quantity;
  final int? acceptedQuantity;
  final int? rejectedQuantity;
  final String? rejectionCategory;
  final String? defectPhoto;
  final String lineTotal;
  final String? thumbnail;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.acceptedQuantity,
    this.rejectedQuantity,
    this.rejectionCategory,
    this.defectPhoto,
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
      acceptedQuantity: json['accepted_quantity'] as int?,
      rejectedQuantity: json['rejected_quantity'] as int?,
      rejectionCategory: json['rejection_category'] as String?,
      defectPhoto: json['defect_photo'] as String?,
      lineTotal: json['line_total']?.toString() ?? '0.00',
      thumbnail: json['product'] != null ? json['product']['thumbnail'] : (json['thumbnail'] as String?),
    );
  }

  String get formattedPrice => CurrencyFormatter.format(unitPrice);
  String get formattedTotal => CurrencyFormatter.format(lineTotal);
  bool get hasRejection => (rejectedQuantity ?? 0) > 0;
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
  final String walletCreditApplied;
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
  final bool hasRiderArrived;
  final bool isHandshakePending;

  // Visual Audit Trail & Proofs
  final String? pickupCounterPhoto;
  final String? doorstepDeliveryPhoto;
  final String? deliveryAttemptPhoto;
  final String? deliveryFailureReason;
  final List<String> itemRejectionPhotos;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.fulfillmentType,
    required this.orderStatus,
    required this.paymentStatus,
    required this.merchandiseSubtotal,
    required this.deliveryFee,
    required this.cashbackRedeemed,
    this.walletCreditApplied = '0.00',
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
    this.hasRiderArrived = false,
    this.isHandshakePending = false,
    this.pickupCounterPhoto,
    this.doorstepDeliveryPhoto,
    this.deliveryAttemptPhoto,
    this.deliveryFailureReason,
    this.itemRejectionPhotos = const [],
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

    final arrived = json['has_rider_arrived'] == true || json['rider_arrived_at'] != null;
    final status = json['order_status'] as String? ?? 'confirmed';

    // Parse Visual Audit Trail
    String? pickupPhoto;
    String? deliveryPhoto;
    String? attemptPhoto;
    String? attemptReason;
    List<String> rejectionPhotos = [];

    if (json['visual_audit_trail'] is Map) {
      final vat = json['visual_audit_trail'];
      pickupPhoto = vat['pickup_counter_photo'] as String?;
      deliveryPhoto = vat['doorstep_delivery_photo'] as String?;
      attemptPhoto = vat['delivery_attempt_photo'] as String?;
      attemptReason = vat['delivery_failure_reason'] as String?;
      if (vat['item_rejection_photos'] is List) {
        rejectionPhotos = (vat['item_rejection_photos'] as List).map((e) => e.toString()).toList();
      }
    } else {
      pickupPhoto = json['pickup_proof_image'] as String?;
      deliveryPhoto = json['proof_of_delivery_image'] as String?;
      attemptPhoto = json['delivery_attempt_photo_path'] as String?;
      attemptReason = json['delivery_failure_reason'] as String?;
    }

    return OrderModel(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String? ?? 'ORD-000',
      fulfillmentType: json['fulfillment_type'] as String? ?? 'doorstep_delivery',
      orderStatus: status,
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      merchandiseSubtotal: json['merchandise_subtotal']?.toString() ?? '0.00',
      deliveryFee: json['delivery_fee']?.toString() ?? '0.00',
      cashbackRedeemed: json['cashback_redeemed']?.toString() ?? '0.00',
      walletCreditApplied: json['wallet_credit_applied']?.toString() ?? '0.00',
      grandTotal: json['grand_total']?.toString() ?? '0.00',
      customerCashback5: json['customer_cashback_5']?.toString() ?? '0.00',
      verificationCode: (json['delivery_otp'] ?? json['verification_code']) as String?,
      shopName: json['shop'] != null ? json['shop']['name'] : 'Merchant Shop',
      shopAddress: json['shop'] != null ? json['shop']['address'] : null,
      shopPhone: json['shop'] != null ? json['shop']['phone'] : null,
      riderName: rName,
      riderPhone: rPhone,
      riderVehicle: rVeh,
      items: parsedItems,
      createdAt: json['created_at'] as String? ?? '',
      riderArrivedAt: json['rider_arrived_at'] as String?,
      hasRiderArrived: arrived,
      isHandshakePending: json['is_handshake_pending'] == true || (status == 'out_for_delivery' && arrived),
      pickupCounterPhoto: pickupPhoto,
      doorstepDeliveryPhoto: deliveryPhoto,
      deliveryAttemptPhoto: attemptPhoto,
      deliveryFailureReason: attemptReason,
      itemRejectionPhotos: rejectionPhotos,
    );
  }

  String get formattedTotal => CurrencyFormatter.format(grandTotal);
  String get formattedSubtotal => CurrencyFormatter.format(merchandiseSubtotal);
  String get formattedDeliveryFee => CurrencyFormatter.format(deliveryFee);
  String get formattedCashbackEarned => CurrencyFormatter.format(customerCashback5);

  bool get isDoorstepDelivery => fulfillmentType == 'doorstep_delivery';
  bool get isDelivered => orderStatus == 'delivered' || orderStatus == 'completed';
  bool get isOutForDelivery => orderStatus == 'out_for_delivery';
  bool get riderArrived => hasRiderArrived || riderArrivedAt != null;

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
