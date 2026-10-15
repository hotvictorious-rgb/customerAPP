import '../core/utils/currency_formatter.dart';

class CashbackModel {
  final String availableCashback;
  final String pendingMaturation;
  final String currency;

  CashbackModel({
    required this.availableCashback,
    required this.pendingMaturation,
    required this.currency,
  });

  factory CashbackModel.fromJson(Map<String, dynamic> json) {
    return CashbackModel(
      availableCashback: json['available_cashback']?.toString() ?? '0.00',
      pendingMaturation: json['pending_maturation']?.toString() ?? '0.00',
      currency: json['currency'] as String? ?? 'NGN',
    );
  }

  String get formattedAvailable => CurrencyFormatter.format(availableCashback);
  String get formattedPending => CurrencyFormatter.format(pendingMaturation);
  double get availableDouble => double.tryParse(availableCashback) ?? 0.0;
}
