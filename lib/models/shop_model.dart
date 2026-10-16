class ShopModel {
  final int id;
  final String name;
  final String? slug;
  final String? address;
  final int? lgaId;
  final String? lgaName;
  final String? logoUrl;
  final bool pickupEnabled;
  final String? pickupOpeningTime;
  final String? pickupClosingTime;

  ShopModel({
    required this.id,
    required this.name,
    this.slug,
    this.address,
    this.lgaId,
    this.lgaName,
    this.logoUrl,
    this.pickupEnabled = false,
    this.pickupOpeningTime,
    this.pickupClosingTime,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    String? lName;
    if (json['lga'] is Map) {
      lName = json['lga']['name'] as String?;
    }
    return ShopModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Merchant Shop',
      slug: json['slug'] as String?,
      address: json['address'] as String?,
      lgaId: json['lga_id'] as int?,
      lgaName: lName ?? json['lga_name'] as String?,
      logoUrl: json['logo_url'] ?? json['image_path'] as String?,
      pickupEnabled: json['pickup_enabled'] == 1 || json['pickup_enabled'] == true,
      pickupOpeningTime: json['pickup_opening_time'] as String?,
      pickupClosingTime: json['pickup_closing_time'] as String?,
    );
  }
}
