import 'category_model.dart';
import 'shop_model.dart';
import '../core/utils/currency_formatter.dart';

class ProductModel {
  final int id;
  final int shopId;
  final int categoryId;
  final String name;
  final String? slug;
  final String? description;
  final String unitPrice;
  final int currentStock;
  final int minimumOrderQty;
  final String? thumbnail;
  final List<String> images;
  final bool isVmarketFlagship;
  final ShopModel? shop;
  final CategoryModel? category;
  final DateTime? lastFreshnessVerifiedAt;

  ProductModel({
    required this.id,
    required this.shopId,
    required this.categoryId,
    required this.name,
    this.slug,
    this.description,
    required this.unitPrice,
    required this.currentStock,
    this.minimumOrderQty = 1,
    this.thumbnail,
    this.images = const [],
    this.isVmarketFlagship = false,
    this.shop,
    this.category,
    this.lastFreshnessVerifiedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List).map((e) => e.toString()).toList();
    } else if (json['images'] is String && (json['images'] as String).isNotEmpty) {
      parsedImages = [json['images'] as String];
    }

    return ProductModel(
      id: json['id'] as int,
      shopId: json['shop_id'] as int? ?? 1,
      categoryId: json['category_id'] as int? ?? 1,
      name: json['name'] as String? ?? 'Product',
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      currentStock: json['current_stock'] as int? ?? 0,
      minimumOrderQty: json['minimum_order_qty'] as int? ?? 1,
      thumbnail: json['thumbnail'] as String?,
      images: parsedImages,
      isVmarketFlagship: json['is_vmarket_flagship'] == 1 || json['is_vmarket_flagship'] == true,
      shop: json['shop'] != null ? ShopModel.fromJson(json['shop']) : null,
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
      lastFreshnessVerifiedAt: json['last_freshness_verified_at'] != null
          ? DateTime.tryParse(json['last_freshness_verified_at'].toString())
          : null,
    );
  }

  String get formattedPrice => CurrencyFormatter.format(unitPrice);
  bool get inStock => currentStock > 0;
}
