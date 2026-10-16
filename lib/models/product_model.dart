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
  final String? youtubeVideoId;
  final String? videoThumbnailUrl;
  final String? videoEmbedUrl;
  final List<String> images;
  final bool isInStock;
  final bool isVmarketFlagship;
  final ShopModel? shop;
  final CategoryModel? category;
  final DateTime? lastFreshnessVerifiedAt;
  final DateTime? listingConfirmedAt;

  ProductModel({
    required this.id,
    required this.shopId,
    required this.categoryId,
    required this.name,
    this.slug,
    this.description,
    required this.unitPrice,
    required this.currentStock,
    this.isInStock = true,
    this.minimumOrderQty = 1,
    this.thumbnail,
    this.youtubeVideoId,
    this.videoThumbnailUrl,
    this.videoEmbedUrl,
    this.images = const [],
    this.isVmarketFlagship = false,
    this.shop,
    this.category,
    this.lastFreshnessVerifiedAt,
    this.listingConfirmedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List).map((e) => e.toString()).toList();
    } else if (json['images'] is String && (json['images'] as String).isNotEmpty) {
      parsedImages = [json['images'] as String];
    }

    final confirmedAt = json['listing_confirmed_at'] != null
        ? DateTime.tryParse(json['listing_confirmed_at'].toString())
        : (json['last_freshness_verified_at'] != null
            ? DateTime.tryParse(json['last_freshness_verified_at'].toString())
            : null);

    final rawStock = json['inventory_quantity'] ?? json['current_stock'] ?? 0;
    final inStockVal = json['is_in_stock'] == true || json['is_in_stock'] == 1 || (json['is_in_stock'] == null && (rawStock is int ? rawStock > 0 : true));

    return ProductModel(
      id: json['id'] as int,
      shopId: json['shop_id'] as int? ?? 1,
      categoryId: json['category_id'] as int? ?? 1,
      name: json['name'] as String? ?? 'Product',
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      currentStock: rawStock is int ? rawStock : int.tryParse(rawStock.toString()) ?? 0,
      isInStock: inStockVal,
      minimumOrderQty: json['minimum_order_qty'] as int? ?? 1,
      thumbnail: json['thumbnail'] as String?,
      youtubeVideoId: json['youtube_video_id'] as String?,
      videoThumbnailUrl: json['video_thumbnail_url'] as String?,
      videoEmbedUrl: json['video_embed_url'] as String?,
      images: parsedImages,
      isVmarketFlagship: json['is_vmarket_flagship'] == 1 || json['is_vmarket_flagship'] == true,
      shop: json['shop'] != null ? ShopModel.fromJson(json['shop']) : null,
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
      lastFreshnessVerifiedAt: json['last_freshness_verified_at'] != null
          ? DateTime.tryParse(json['last_freshness_verified_at'].toString())
          : null,
      listingConfirmedAt: confirmedAt,
    );
  }

  String get formattedPrice => CurrencyFormatter.format(unitPrice);
  bool get inStock => isInStock && currentStock > 0;
  bool get hasVideo => youtubeVideoId != null && youtubeVideoId!.trim().isNotEmpty;

  bool get isFresh {
    if (listingConfirmedAt == null) return true;
    final diff = DateTime.now().difference(listingConfirmedAt!).inDays;
    return diff < 7;
  }

  int get daysFreshRemaining {
    if (listingConfirmedAt == null) return 7;
    final diff = DateTime.now().difference(listingConfirmedAt!).inDays;
    return (7 - diff).clamp(0, 7);
  }
}
