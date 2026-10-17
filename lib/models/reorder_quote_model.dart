import '../core/utils/currency_formatter.dart';

class ReorderItemQuote {
  final int productId;
  final String productName;
  final int shopId;
  final int quantity;
  final String unitPrice;
  final String subtotal;

  ReorderItemQuote({
    required this.productId,
    required this.productName,
    required this.shopId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory ReorderItemQuote.fromJson(Map<String, dynamic> json) {
    return ReorderItemQuote(
      productId: json['product_id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? 'Replacement Item',
      shopId: json['shop_id'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      subtotal: json['subtotal']?.toString() ?? '0.00',
    );
  }

  String get formattedUnitPrice => CurrencyFormatter.format(unitPrice);
  String get formattedSubtotal => CurrencyFormatter.format(subtotal);
}

class ReorderQuoteModel {
  final String operation;
  final bool isQuote;
  final String caseNumber;
  final List<ReorderItemQuote> items;
  final String merchandiseSubtotal;
  final String walletCreditAvailable;
  final String walletCreditApplied;
  final String netPayableCash;

  ReorderQuoteModel({
    required this.operation,
    required this.isQuote,
    required this.caseNumber,
    required this.items,
    required this.merchandiseSubtotal,
    required this.walletCreditAvailable,
    required this.walletCreditApplied,
    required this.netPayableCash,
  });

  factory ReorderQuoteModel.fromJson(Map<String, dynamic> json, {String caseNumber = ''}) {
    List<ReorderItemQuote> parsedItems = [];
    if (json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((i) => ReorderItemQuote.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return ReorderQuoteModel(
      operation: json['operation'] as String? ?? 'quote_preview',
      isQuote: json['is_quote'] == true,
      caseNumber: caseNumber,
      items: parsedItems,
      merchandiseSubtotal: json['merchandise_subtotal']?.toString() ?? '0.00',
      walletCreditAvailable: json['wallet_credit_available']?.toString() ?? '0.00',
      walletCreditApplied: json['wallet_credit_applied']?.toString() ?? '0.00',
      netPayableCash: json['net_payable_cash']?.toString() ?? '0.00',
    );
  }

  String get formattedSubtotal => CurrencyFormatter.format(merchandiseSubtotal);
  String get formattedWalletAvailable => CurrencyFormatter.format(walletCreditAvailable);
  String get formattedWalletApplied => CurrencyFormatter.format(walletCreditApplied);
  String get formattedNetPayable => CurrencyFormatter.format(netPayableCash);

  bool get isFullyCoveredByWallet {
    final net = double.tryParse(netPayableCash) ?? 0.0;
    return net <= 0.001;
  }
}
