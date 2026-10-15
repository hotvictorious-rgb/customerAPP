class BannerModel {
  final int id;
  final String bannerType;
  final String templateStyle;
  final String title;
  final String? subtitle;
  final String? badgeText;
  final String? discountTag;
  final List<String> featureTags;
  final String? imageUrl;
  final String bgGradient;
  final String textColor;
  final String ctaText;
  final String? ctaUrl;
  final int sortOrder;

  const BannerModel({
    required this.id,
    required this.bannerType,
    required this.templateStyle,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.discountTag,
    this.featureTags = const [],
    this.imageUrl,
    this.bgGradient = 'linear-gradient(135deg, #2D0C54 0%, #1A0536 100%)',
    this.textColor = '#FFFFFF',
    this.ctaText = 'Shop Verified Items',
    this.ctaUrl,
    this.sortOrder = 0,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    List<String> tags = [];
    if (json['feature_tags'] is List) {
      tags = (json['feature_tags'] as List).map((e) => e.toString()).toList();
    } else if (json['feature_tags'] is String && (json['feature_tags'] as String).isNotEmpty) {
      tags = (json['feature_tags'] as String).split(',').map((e) => e.trim()).toList();
    }

    return BannerModel(
      id: json['id'] ?? 0,
      bannerType: json['banner_type'] ?? 'hero_slider',
      templateStyle: json['template_style'] ?? 'luxury_split',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      badgeText: json['badge_text'],
      discountTag: json['discount_tag'],
      featureTags: tags,
      imageUrl: json['image_url'],
      bgGradient: json['bg_gradient'] ?? 'linear-gradient(135deg, #2D0C54 0%, #1A0536 100%)',
      textColor: json['text_color'] ?? '#FFFFFF',
      ctaText: json['cta_text'] ?? 'Shop Verified Items',
      ctaUrl: json['cta_url'],
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  bool get isLuxurySplit => templateStyle == 'luxury_split';
  bool get isFullCover => templateStyle == 'full_cover';
  bool get isFlashUrgency => templateStyle == 'flash_urgency';
  bool get isMinimalBento => templateStyle == 'minimal_bento';
  bool get isFreshMarket => templateStyle == 'fresh_market';
  bool get isBrandPrestige => templateStyle == 'brand_prestige';
}
