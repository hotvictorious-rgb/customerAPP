import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/checkout_provider.dart';
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
                            Row(
                              children: [
                                if (product.isVmarketFlagship)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    margin: const EdgeInsets.only(right: 8),
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.successLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified, size: 12, color: AppColors.success),
                                      SizedBox(width: 4),
                                      Text(
                                        'Verified Fresh Stock',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
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

                            // Price & 5% Cashback preview
                            Row(
                              children: [
                                Text(
                                  product.formattedPrice,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryPurple,
                                  ),
                                ),
                                const SizedBox(width: 14),
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
