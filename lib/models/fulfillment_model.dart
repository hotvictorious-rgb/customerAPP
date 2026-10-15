import '../core/utils/currency_formatter.dart';

class FulfillmentResultModel {
  final bool isAvailable;
  final String fee;
  final String? etaHours;
  final String? laneName;
  final String message;

  FulfillmentResultModel({
    required this.isAvailable,
    required this.fee,
    this.etaHours,
    this.laneName,
    required this.message,
  });

  factory FulfillmentResultModel.fromJson(Map<String, dynamic> json) {
    return FulfillmentResultModel(
      isAvailable: json['is_available'] == true,
      fee: json['fee']?.toString() ?? '0.00',
      etaHours: json['eta_hours']?.toString(),
      laneName: json['lane_name'] as String?,
      message: json['message'] as String? ?? '',
    );
  }

  String get formattedFee => CurrencyFormatter.format(fee);
}
