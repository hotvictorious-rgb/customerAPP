import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/checkout_provider.dart';
import '../../providers/review_provider.dart';
import '../../widgets/brand_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import '../checkout/checkout_screen.dart';
import '../reservations/pickup_reservation_pass_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  int _activeImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().fetchProductDetails(widget.productId);
      context.read<ReviewProvider>().fetchProductReviews(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final product = catalog.productDetails;

    return Scaffold(
      appBar: BrandAppBar(
        title: product?.name ?? 'Product Details',
        showBack: true,
      ),
      body: catalog.isLoading && product == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
          : product == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                      const SizedBox(height: 12),
                      const Text('Product not found or currently unlisted.', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Gallery Carousel
                      Container(
                        height: 320,
                        width: double.infinity,
                        color: Colors.white,
                        child: Stack(
                          children: [
                            PageView.builder(
                              itemCount: product.images.isNotEmpty ? product.images.length : 1,
                              onPageChanged: (i) => setState(() => _activeImageIndex = i),
                              itemBuilder: (context, index) {
                                final imgUrl = product.images.isNotEmpty
                                    ? product.images[index]
                                    : product.thumbnail;
                                return imgUrl != null && imgUrl.startsWith('http')
                                    ? CachedNetworkImage(
                                        imageUrl: imgUrl,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => const Center(
                                          child: Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.textMuted),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.textMuted),
                                      );
                              },
                            ),
                            // Dots indicator
                            if (product.images.length > 1)
                              Positioned(
                                bottom: 12,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    product.images.length,
                                    (i) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      width: _activeImageIndex == i ? 18 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _activeImageIndex == i ? AppColors.primaryPurple : AppColors.border,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Core Product Information Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badges Row
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (product.isVmarketFlagship)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.goldGradient,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'VMARKET FLAGSHIP',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                // Condition Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: product.isUkUsed ? const Color(0xFFEBF5FF) : AppColors.successLight,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: product.isUkUsed ? const Color(0xFF76A9FA) : AppColors.success.withOpacity(0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        product.isUkUsed ? Icons.devices_other : Icons.new_releases,
                                        size: 12,
                                        color: product.isUkUsed ? const Color(0xFF1E429F) : AppColors.success,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        product.conditionLabel ?? (product.isUkUsed ? 'UK Used' : 'Brand New'),
                                        style: TextStyle(
                                          color: product.isUkUsed ? const Color(0xFF1E429F) : AppColors.success,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Star Rating Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, size: 12, color: Color(0xFFD97706)),
                                      const SizedBox(width: 4),
                                      Text(
                                        product.rating > 0
                                            ? '${product.rating.toStringAsFixed(1)} (${product.reviewsCount})'
                                            : 'New Listing',
                                        style: const TextStyle(
                                          color: Color(0xFF92400E),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Logistics Courier Tier Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: product.isKekeTier ? const Color(0xFFFFF7ED) : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: product.isKekeTier ? const Color(0xFFFDBA74) : const Color(0xFFD1D5DB),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        product.isKekeTier ? Icons.local_shipping : Icons.two_wheeler,
                                        size: 12,
                                        color: product.isKekeTier ? const Color(0xFFC2410C) : AppColors.textPrimary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        product.packageTierLabel ?? (product.isKekeTier ? 'Keke Cargo' : 'Bike Dispatch'),
                                        style: TextStyle(
                                          color: product.isKekeTier ? const Color(0xFFC2410C) : AppColors.textPrimary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Price, Slash Price & 5% Cashback preview
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  product.formattedPrice,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryPurple,
                                  ),
                                ),
                                if (product.hasDiscount) ...[
                                  Text(
                                    product.formattedSlashPrice ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMuted,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  if (product.discountPercent != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.danger.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '-${product.discountPercent}% OFF',
                                        style: const TextStyle(
                                          color: AppColors.danger,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryGoldLight,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.secondaryGold),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.stars, color: AppColors.primaryPurple, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        '+5% Sovereign Cashback',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Warranty Banner Pill
                            if (product.warrantyLabel != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.primaryPurple),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Warranty: ${product.warrantyLabel}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),

                            // Quantity Stepper
                            Row(
                              children: [
                                const Text(
                                  'Quantity:',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 18),
                                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                        padding: EdgeInsets.zero,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          '$_quantity',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 18),
                                        onPressed: () => setState(() => _quantity++),
                                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  product.inStock ? '${product.currentStock} in stock' : 'Out of Stock',
                                  style: TextStyle(
                                    color: product.inStock ? AppColors.success : AppColors.danger,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Merchant / Shop Branch Information Card
                      if (product.shop != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sold & Fulfilled by Verified Merchant',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryPurple.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.storefront, color: AppColors.primaryPurple),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.shop!.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (product.shop!.address != null)
                                          Text(
                                            product.shop!.address!,
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (product.shop!.pickupEnabled) ...[
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'In-Shop Inspection & Pickup is active at this branch (${product.shop!.pickupOpeningTime ?? "08:00"} - ${product.shop!.pickupClosingTime ?? "18:00"}).',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Description
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Product Description',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description != null && product.description!.isNotEmpty
                                  ? product.description!
                                  : 'Genuine retail product verified by Victorious MARKET multi-actor compliance protocols in Akwa Ibom State.',
                              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                            ),
                          ],
                        ),
                      ),

                      // Verified Demonstration Video Card (Zero-Trust YouTube Stream)
                      if (product.hasVideo) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.white,
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.play_circle_fill, color: Colors.red, size: 22),
                                      SizedBox(width: 8),
                                      Text(
                                        'Verified Video Unboxing',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                                    ),
                                    child: const Text(
                                      'YouTube HD',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: product.videoThumbnailUrl ??
                                          'https://img.youtube.com/vi/${product.youtubeVideoId}/hqdefault.jpg',
                                      height: 190,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Container(
                                        height: 190,
                                        color: Colors.black12,
                                        child: const Center(child: Icon(Icons.videocam, size: 48, color: AppColors.textMuted)),
                                      ),
                                    ),
                                    Container(
                                      height: 190,
                                      width: double.infinity,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(30),
                                        onTap: () => _openVideoModal(context, product),
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.red.withOpacity(0.5),
                                                blurRadius: 16,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Row(
                                children: [
                                  Icon(Icons.shield, size: 13, color: AppColors.primaryPurple),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'Zero-Trust Stream: Verified merchant physical unboxing and inspection video.',
                                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Verified Customer Reviews & Star Ratings Section
                      const SizedBox(height: 12),
                      Consumer<ReviewProvider>(
                        builder: (context, reviewProv, _) {
                          final reviews = reviewProv.productReviews;
                          final avgRating = reviewProv.averageRating > 0 ? reviewProv.averageRating : product.rating;
                          final count = reviewProv.reviewsCount > 0 ? reviewProv.reviewsCount : product.reviewsCount;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.white,
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Customer Reviews',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.success.withOpacity(0.3)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.verified, size: 12, color: AppColors.success),
                                          SizedBox(width: 4),
                                          Text(
                                            'Verified Buyers Only',
                                            style: TextStyle(
                                              color: AppColors.success,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Overall Rating Summary Row
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                avgRating.toStringAsFixed(1),
                                                style: const TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w900,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Text(
                                                '/ 5.0',
                                                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: List.generate(5, (index) {
                                              return Icon(
                                                index < avgRating.round() ? Icons.star : Icons.star_border,
                                                color: Colors.amber,
                                                size: 16,
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '$count ${count == 1 ? "review" : "reviews"}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Post-delivery verified',
                                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (reviewProv.isLoading && reviews.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 24.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                else if (reviews.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Icon(Icons.rate_review_outlined, size: 40, color: AppColors.textMuted.withOpacity(0.5)),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'No customer reviews yet',
                                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Only verified buyers who completed their order can leave an authentic review.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: reviews.length,
                                    separatorBuilder: (_, __) => const Divider(height: 24),
                                    itemBuilder: (context, idx) {
                                      final rev = reviews[idx];
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                                                    child: Text(
                                                      rev.customerName != null && rev.customerName!.isNotEmpty
                                                          ? rev.customerName![0].toUpperCase()
                                                          : 'C',
                                                      style: const TextStyle(
                                                        color: AppColors.primaryPurple,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    rev.customerName ?? 'Verified Customer',
                                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                                  ),
                                                  if (rev.isVerifiedBuyer) ...[
                                                    const SizedBox(width: 6),
                                                    const Icon(Icons.check_circle, size: 13, color: AppColors.success),
                                                  ],
                                                ],
                                              ),
                                              Row(
                                                children: List.generate(5, (sIdx) {
                                                  return Icon(
                                                    sIdx < rev.rating ? Icons.star : Icons.star_border,
                                                    color: Colors.amber,
                                                    size: 13,
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                          if (rev.headline != null && rev.headline!.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              rev.headline!,
                                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                            ),
                                          ],
                                          const SizedBox(height: 4),
                                          Text(
                                            rev.comment,
                                            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${rev.createdAt.day}/${rev.createdAt.month}/${rev.createdAt.year}',
                                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 120), // Padding for sticky bottom bar
                    ],
                  ),
                ),
      // Sticky Bottom Dual-Action Bar
      bottomNavigationBar: product == null
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        // Add to Cart
                        Expanded(
                          child: CustomButton(
                            text: 'Add to Bag',
                            isSecondary: true,
                            icon: Icons.add_shopping_cart,
                            onPressed: () {
                              final cart = context.read<CartProvider>();
                              if (cart.isDifferentShop(product)) {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Row(
                                      children: [
                                        Icon(Icons.store, color: AppColors.primaryPurple, size: 20),
                                        SizedBox(width: 8),
                                        Text('Single Store Checkout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    content: Text(
                                      'Your bag contains items from ${cart.currentShopName}. Would you like to clear your bag and start a new order from ${product.shop?.name ?? "this merchant"}?',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Keep Current Bag'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryPurple,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          cart.clearAndAdd(product, quantity: _quantity);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Bag cleared and added $_quantity of ${product.name}'),
                                              backgroundColor: AppColors.primaryDarkPurple,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        child: const Text('Start New Bag'),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }

                              cart.addToCart(product, quantity: _quantity);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added $_quantity of ${product.name} to bag'),
                                  backgroundColor: AppColors.primaryDarkPurple,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Buy Now
                        Expanded(
                          child: CustomButton(
                            text: 'Buy Now',
                            icon: Icons.flash_on,
                            onPressed: () {
                              final auth = context.read<AuthProvider>();
                              if (!auth.isAuthenticated) {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                                return;
                              }
                              context.read<CartProvider>().clearCart();
                              context.read<CartProvider>().addToCart(product, quantity: _quantity);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                            },
                          ),
                        ),
                      ],
                    ),

                    // In-Shop Inspection Option (Inspect First, Pay Later)
                    if (product.shop?.pickupEnabled == true) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.storefront, color: AppColors.primaryPurple, size: 18),
                        label: const Text(
                          'Reserve for In-Shop Pickup (₦0.00 Paid Upfront)',
                          style: TextStyle(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.secondaryGold, width: 1.5),
                          backgroundColor: AppColors.secondaryGoldLight,
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          final auth = context.read<AuthProvider>();
                          if (!auth.isAuthenticated) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                            return;
                          }

                          final checkout = context.read<CheckoutProvider>();
                          final reservation = await checkout.createInShopReservation(
                            shopId: product.shopId,
                            productId: product.id,
                            quantity: _quantity,
                          );

                          if (reservation != null && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PickupReservationPassScreen(reservation: reservation),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  void _openVideoModal(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.play_circle_fill, color: Colors.red, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Video Demonstration',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: product.videoThumbnailUrl ??
                        'https://img.youtube.com/vi/${product.youtubeVideoId}/hqdefault.jpg',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.4),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Video ID: ${product.youtubeVideoId}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'monospace',
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock, size: 16, color: AppColors.success),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Zero-Trust Stream: No server-side HTTP calls. Stream rendered via sandboxed Google YouTube CDN.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
