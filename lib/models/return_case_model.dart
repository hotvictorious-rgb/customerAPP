import '../core/utils/currency_formatter.dart';

class ReturnCaseModel {
  final int id;
  final String caseNumber;
  final int orderId;
  final String? orderNumber;
  final String? vendorName;
  final String returnReason;
  final String? customerDescription;
  final String status;
  final String resolutionType;
  final String totalRefundableAmount;
  final String refundedAmount;
  final String? vendorReturnOtp;
  final bool vendorDisputed;
  final String? vendorDisputeReason;
  final String? createdAt;
  final List<ReturnItemModel> items;

  ReturnCaseModel({
    required this.id,
    required this.caseNumber,
    required this.orderId,
    this.orderNumber,
    this.vendorName,
    required this.returnReason,
    this.customerDescription,
    required this.status,
    required this.resolutionType,
    required this.totalRefundableAmount,
    required this.refundedAmount,
    this.vendorReturnOtp,
    this.vendorDisputed = false,
    this.vendorDisputeReason,
    this.createdAt,
    this.items = const [],
  });

  factory ReturnCaseModel.fromJson(Map<String, dynamic> json) {
    List<ReturnItemModel> parsedItems = [];
    if (json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((i) => ReturnItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    String? ordNum;
    if (json['order'] != null && json['order'] is Map) {
      ordNum = json['order']['order_number'] as String?;
    }

    String? vName;
    if (json['vendor'] != null && json['vendor'] is Map) {
      vName = json['vendor']['business_name'] as String?;
    }

    return ReturnCaseModel(
      id: json['id'] as int,
      caseNumber: json['case_number'] as String? ?? 'RET-000',
      orderId: json['order_id'] as int? ?? 0,
      orderNumber: ordNum,
      vendorName: vName,
      returnReason: json['return_reason'] as String? ?? 'other',
      customerDescription: json['customer_description'] as String?,
      status: json['status'] as String? ?? 'requested',
      resolutionType: json['resolution_type'] as String? ?? 'refund',
      totalRefundableAmount: json['total_refundable_amount']?.toString() ?? '0.00',
      refundedAmount: json['refunded_amount']?.toString() ?? '0.00',
      vendorReturnOtp: json['vendor_return_otp'] as String?,
      vendorDisputed: json['vendor_disputed'] == true || json['vendor_disputed'] == 1,
      vendorDisputeReason: json['vendor_dispute_reason'] as String?,
      createdAt: json['created_at'] as String?,
      items: parsedItems,
    );
  }

  String get formattedRefundable => CurrencyFormatter.format(totalRefundableAmount);
  String get formattedRefunded => CurrencyFormatter.format(refundedAmount);

  String get readableStatus {
    switch (status) {
      case 'requested':
        return 'Return Requested';
      case 'under_review':
        return 'Under Review';
      case 'approved_for_return':
        return 'Approved for Hub Return';
      case 'received_at_hub':
        return 'Received at Collection Hub';
      case 'inspected':
        return 'Hub Inspection Passed';
      case 'refund_pending':
        return 'Refund Processing';
      case 'refunded':
        return 'Refunded to Wallet';
      case 'rejected':
        return 'Return Rejected';
      case 'closed':
        return 'Case Resolved';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  String get readableReason {
    switch (returnReason) {
      case 'defective_product':
        return 'Defective / Not Working';
      case 'wrong_item_sent':
        return 'Wrong Item Delivered';
      case 'misdescribed_counterfeit':
        return 'Counterfeit / Not as Described';
      case 'damaged_in_transit':
        return 'Damaged During Transit';
      case 'change_of_mind':
        return 'Change of Mind';
      case 'missing_item':
        return 'Item Missing from Package';
      default:
        return returnReason.replaceAll('_', ' ');
    }
  }
}

class ReturnItemModel {
  final int id;
  final int orderItemId;
  final int productId;
  final String productName;
  final int quantity;
  final String unitPrice;
  final String refundableAmount;
  final String itemCondition;
  final String status;

  ReturnItemModel({
    required this.id,
    required this.orderItemId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.refundableAmount,
    required this.itemCondition,
    required this.status,
  });

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) {
    String pName = 'Product';
    if (json['product'] != null && json['product'] is Map) {
      pName = json['product']['name'] as String? ?? 'Product';
    }

    return ReturnItemModel(
      id: json['id'] as int,
      orderItemId: json['order_item_id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productName: pName,
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      refundableAmount: json['refundable_amount']?.toString() ?? '0.00',
      itemCondition: json['item_condition'] as String? ?? 'opened_tested',
      status: json['status'] as String? ?? 'requested',
    );
  }

  String get formattedTotal => CurrencyFormatter.format(refundableAmount);
}
