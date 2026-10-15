import '../core/utils/currency_formatter.dart';

class CheckoutIntentModel {
  final int intentId;
  final String fingerprint;
  final String merchandiseSubtotal;
  final String deliveryFee;
  final String cashbackApplied;
  final String totalPayable;
  final String expiresAt;

  CheckoutIntentModel({
    required this.intentId,
    required this.fingerprint,
    required this.merchandiseSubtotal,
    required this.deliveryFee,
    required this.cashbackApplied,
    required this.totalPayable,
    required this.expiresAt,
  });

  factory CheckoutIntentModel.fromJson(Map<String, dynamic> json) {
    return CheckoutIntentModel(
      intentId: json['intent_id'] as int,
      fingerprint: json['fingerprint'] as String? ?? '',
      merchandiseSubtotal: json['merchandise_subtotal']?.toString() ?? '0.00',
      deliveryFee: json['delivery_fee']?.toString() ?? '0.00',
      cashbackApplied: json['cashback_applied']?.toString() ?? '0.00',
      totalPayable: json['total_payable']?.toString() ?? '0.00',
      expiresAt: json['expires_at'] as String? ?? '',
    );
  }

  String get formattedSubtotal => CurrencyFormatter.format(merchandiseSubtotal);
  String get formattedDeliveryFee => CurrencyFormatter.format(deliveryFee);
  String get formattedCashback => CurrencyFormatter.format(cashbackApplied);
  String get formattedTotal => CurrencyFormatter.format(totalPayable);
}
