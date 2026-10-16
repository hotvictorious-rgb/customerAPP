import '../core/utils/currency_formatter.dart';

class WalletSummaryModel {
  final String availableBalance;
  final String currency;
  final String spendableRate;
  final List<WalletCreditItemModel> history;

  WalletSummaryModel({
    required this.availableBalance,
    this.currency = 'NGN',
    this.spendableRate = '100%',
    this.history = const [],
  });

  factory WalletSummaryModel.fromJson(Map<String, dynamic> json) {
    List<WalletCreditItemModel> parsedHistory = [];
    if (json['history'] is List) {
      parsedHistory = (json['history'] as List)
          .map((i) => WalletCreditItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return WalletSummaryModel(
      availableBalance: json['available_wallet_credit']?.toString() ?? '0.00',
      currency: json['currency'] as String? ?? 'NGN',
      spendableRate: json['spendable_rate'] as String? ?? '100%',
      history: parsedHistory,
    );
  }

  String get formattedBalance => CurrencyFormatter.format(availableBalance);
  double get balanceDouble => double.tryParse(availableBalance) ?? 0.0;
}

class WalletCreditItemModel {
  final int id;
  final String amount;
  final String creditType;
  final String status;
  final String? notes;
  final String? createdAt;

  WalletCreditItemModel({
    required this.id,
    required this.amount,
    required this.creditType,
    required this.status,
    this.notes,
    this.createdAt,
  });

  factory WalletCreditItemModel.fromJson(Map<String, dynamic> json) {
    return WalletCreditItemModel(
      id: json['id'] as int? ?? 0,
      amount: json['amount']?.toString() ?? '0.00',
      creditType: json['credit_type'] as String? ?? 'doorstep_refund_credit',
      status: json['status'] as String? ?? 'available',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  String get formattedAmount => CurrencyFormatter.format(amount);

  String get readableType {
    switch (creditType) {
      case 'doorstep_refund_credit':
        return 'Doorstep Return Refund';
      case 'return_refund_credit':
        return 'Item Return Refund';
      case 'admin_credit':
        return 'Customer Care Credit';
      default:
        return creditType.replaceAll('_', ' ').toUpperCase();
    }
  }
}
