import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/shop_model.dart';
import '../../providers/address_provider.dart';
import '../../providers/banner_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/banner_slider.dart';
import '../../widgets/brand_app_bar.dart';
import '../../widgets/call_to_order_pill.dart';
import '../../widgets/location_selection_modal.dart';
import '../../widgets/product_card.dart';
import '../catalog/catalog_screen.dart';
import '../shop/shop_profile_screen.dart';
import '../wallet/wallet_cashback_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BannerProvider>().fetchBanners();
      context.read<CatalogProvider>().fetchCategories();
      context.read<CatalogProvider>().fetchProducts();
      context.read<CatalogProvider>().fetchFlagshipProducts();
      context.read<CatalogProvider>().fetchShops(lgaId: 69);
      context.read<AddressProvider>().fetchLgas(3); // Canonical Akwa Ibom State
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final bannerProvider = context.watch<BannerProvider>();
    final addressProv = context.watch<AddressProvider>();

    return Scaffold(
      appBar: BrandAppBar(
        showBack: false,
        titleWidget: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                AppConstants.iconAsset,
                width: 34,
                height: 34,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.store, color: AppColors.secondaryGold, size: 28),
              ),
            ),
            const SizedBox(width: 10),
            const BrandTitle(
              fontSize: 16.5,
              showSubtitle: true,
              subtitle: 'Your Trusted Online Market',
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryPurple,
        onRefresh: () async {
          await Future.wait([
            context.read<BannerProvider>().fetchBanners(),
            catalog.fetchCategories(),
            catalog.fetchProducts(),
            catalog.fetchFlagshipProducts(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic Proximity Coverage Strip (Matching newVmarket)
              GestureDetector(
                onTap: () => LocationSelectionModal.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            catalog.coverageStatusBadge,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Change your location ▾',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search & Call-to-Order Header Box
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  gradient: AppColors.royalPurpleGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Search Bar Pill
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CatalogScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: AppColors.primaryPurple, size: 22),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Search products, electronics, groceries...',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(Icons.tune, color: AppColors.primaryPurple, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CallToOrderPill(),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Dynamic Multi-Template Hero Banner Slider
              if (bannerProvider.heroBanners.isNotEmpty)
                BannerSliderWidget(banners: bannerProvider.heroBanners)
              else if (bannerProvider.isLoading)
                Container(
                  height: 180,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryPurple),
                  ),
                ),

              const SizedBox(height: 14),

              // 5% Sovereign Cashback Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WalletCashbackScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryGoldDark.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.wallet, color: AppColors.secondaryGold, size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '5% INSTANT CASHBACK REWARD',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Earn 5% on every verified purchase in your Sovereign Wallet.',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textPrimary),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Canonical LGA Quick Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Shop by LGA Corridor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        catalog.selectLga(null);
                      },
                      child: const Text('All LGAs', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildLgaChip(context, 'All Akwa Ibom', null, catalog.selectedLgaId == null),
                    ...(addressProv.lgas.isNotEmpty ? addressProv.lgas : appConfig.activeCorridors).map((lga) => _buildLgaChip(context, lga.name.endsWith('LGA') ? lga.name : '${lga.name} LGA', lga.id, catalog.selectedLgaId == lga.id)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Categories Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular Categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CatalogScreen()),
                        );
                      },
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: AppColors.primaryPurple,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (catalog.categories.isNotEmpty)
                SizedBox(
                  height: 95,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: catalog.categories.length,
                    itemBuilder: (context, index) {
                      final cat = catalog.categories[index];
                      return GestureDetector(
                        onTap: () {
                          catalog.selectCategory(cat);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CatalogScreen()),
                          );
                        },
                        child: Container(
                          width: 76,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.border, width: 1.5),
                                  boxShadow: AppColors.cardShadow,
                                ),
                                child: Center(
                                  child: Icon(
                                    _getCategoryIcon(cat.slug),
                                    color: AppColors.primaryPurple,
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // Mid-Page Promotional Banner Strip
              if (bannerProvider.promoBanners.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CatalogScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.secondaryGold.withOpacity(0.5), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.campaign, color: AppColors.secondaryGold, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bannerProvider.promoBanners.first.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (bannerProvider.promoBanners.first.subtitle != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    bannerProvider.promoBanners.first.subtitle!,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryGold,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              bannerProvider.promoBanners.first.ctaText,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Flagship Products Section
              if (catalog.flagshipProducts.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryGold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.star, size: 14, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Victorious Flagship Products',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: catalog.flagshipProducts.length,
                    itemBuilder: (context, index) {
                      final product = catalog.flagshipProducts[index];
                      return Container(
                        width: 170,
                        margin: const EdgeInsets.only(right: 14),
                        child: ProductCard(product: product),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Stores Closer to You in {City} (Matching _shops_grid.blade.php)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.storefront, size: 18, color: AppColors.primaryPurple),
                    const SizedBox(width: 8),
                    Text(
                      'Stores Closer to You in ${catalog.selectedCity}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (catalog.shops.isNotEmpty)
                SizedBox(
                  height: 135,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: catalog.shops.length,
                    itemBuilder: (context, index) {
                      final shop = catalog.shops[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ShopProfileScreen(shop: shop)),
                          );
                        },
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 60,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: AppColors.surfaceMuted,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: shop.logoUrl != null && shop.logoUrl!.startsWith('http')
                                    ? CachedNetworkImage(
                                        imageUrl: shop.logoUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.store, color: AppColors.primaryPurple),
                                      )
                                    : const Icon(Icons.store, color: AppColors.primaryPurple),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                shop.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '🏪 ${shop.lgaName ?? "Local"} Hub',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_outlined, color: AppColors.primaryPurple, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Verified merchants in ${catalog.selectedCity} are preparing fresh stock. Orders fulfilled via transit corridors.',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Product Feed Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Verified Storefront Listings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${catalog.products.length} Products',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Strictly 2-Column Mobile Product Grid
              if (catalog.isLoading && catalog.products.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primaryPurple),
                  ),
                )
              else if (catalog.products.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted),
                      SizedBox(height: 12),
                      Text(
                        'No products found in this category or corridor.',
                        style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: catalog.products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      return ProductCard(product: catalog.products[index]);
                    },
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLgaChip(BuildContext context, String title, int? lgaId, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(title),
        selected: isSelected,
        onSelected: (_) {
          context.read<CatalogProvider>().selectLga(lgaId);
        },
        selectedColor: AppColors.primaryPurple,
        backgroundColor: Colors.white,
        checkmarkColor: AppColors.secondaryGold,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primaryPurple : AppColors.border,
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String slug) {
    if (slug.contains('phone') || slug.contains('tech') || slug.contains('electr')) {
      return Icons.phone_android;
    } else if (slug.contains('fashion') || slug.contains('wear') || slug.contains('cloth')) {
      return Icons.checkroom;
    } else if (slug.contains('food') || slug.contains('grocer')) {
      return Icons.local_dining;
    } else if (slug.contains('beauty') || slug.contains('health')) {
      return Icons.spa;
    } else {
      return Icons.category_outlined;
    }
  }
}
