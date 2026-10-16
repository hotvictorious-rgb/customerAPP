class ReviewModel {
  final int id;
  final int productId;
  final int customerId;
  final int orderId;
  final int rating;
  final String? headline;
  final String comment;
  final bool isVerifiedBuyer;
  final String status;
  final String? customerName;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.customerId,
    required this.orderId,
    required this.rating,
    this.headline,
    required this.comment,
    this.isVerifiedBuyer = true,
    this.status = 'active',
    this.customerName,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String? name;
    if (json['customer'] is Map) {
      name = json['customer']['name']?.toString();
    } else if (json['customer_name'] != null) {
      name = json['customer_name']?.toString();
    }

    return ReviewModel(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      customerId: json['customer_id'] as int? ?? 0,
      orderId: json['order_id'] as int? ?? 0,
      rating: json['rating'] as int? ?? 5,
      headline: json['headline'] as String?,
      comment: json['comment'] as String? ?? '',
      isVerifiedBuyer: json['is_verified_buyer'] == true || json['is_verified_buyer'] == 1,
      status: json['status'] as String? ?? 'active',
      customerName: name ?? 'Verified Customer',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get starsText => '★' * rating + '☆' * (5 - rating);
}
