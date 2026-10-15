import '../core/utils/currency_formatter.dart';

class PickupReservationModel {
  final String reservationCode;
  final String shopName;
  final String shopAddress;
  final String productName;
  final int quantity;
  final String estimatedTotal;
  final String status;
  final String expiresAt;
  final String? productThumbnail;

  PickupReservationModel({
    required this.reservationCode,
    required this.shopName,
    required this.shopAddress,
    required this.productName,
    required this.quantity,
    required this.estimatedTotal,
    required this.status,
    required this.expiresAt,
    this.productThumbnail,
  });

  factory PickupReservationModel.fromJson(Map<String, dynamic> json) {
    return PickupReservationModel(
      reservationCode: json['reservation_code'] as String? ?? '',
      shopName: json['shop_name'] as String? ?? (json['shop'] != null ? json['shop']['name'] : 'Merchant Shop'),
      shopAddress: json['shop_address'] as String? ?? (json['shop'] != null ? json['shop']['address'] : ''),
      productName: json['product_name'] as String? ?? (json['product'] != null ? json['product']['name'] : 'Item'),
      quantity: json['quantity'] as int? ?? 1,
      estimatedTotal: json['estimated_total']?.toString() ?? '0.00',
      status: json['status'] as String? ?? 'reserved',
      expiresAt: json['expires_at'] as String? ?? '',
      productThumbnail: json['product'] != null ? json['product']['thumbnail'] : null,
    );
  }

  String get formattedTotal => CurrencyFormatter.format(estimatedTotal);
}
