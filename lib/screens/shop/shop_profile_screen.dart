import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../models/shop_model.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/brand_app_bar.dart';
import '../../widgets/product_card.dart';

class ShopProfileScreen extends StatelessWidget {
  final ShopModel shop;

  const ShopProfileScreen({super.key, required this.shop});

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final shopProducts = catalog.products.where((p) => p.shop != null && p.shop!.id == shop.id).toList();

    return Scaffold(
      appBar: BrandAppBar(
        title: shop.name,
        showBack: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Merchant Banner & Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryPurple, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: shop.logoUrl != null && shop.logoUrl!.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: shop.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 36, color: AppColors.primaryPurple),
                          )
                        : const Icon(Icons.store, size: 36, color: AppColors.primaryPurple),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    shop.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.storefront, size: 14, color: AppColors.primaryPurple),
                        const SizedBox(width: 6),
                        Text(
                          '${shop.lgaName ?? "Commercial"} Corridor',
                          style: const TextStyle(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (shop.address != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      shop.address!,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),

                  // In-Shop Inspection Partner Trust Card (The Akwa Ibom Trust Model)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryGoldLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.secondaryGold),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user, color: AppColors.primaryPurple, size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verified In-Shop Inspection Partner',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Lock products for 24 hours. Walk into the store to inspect before counter payment (₦0.00 down).',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (shop.phone != null) ...[
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Contact Storefront', style: TextStyle(fontWeight: FontWeight.w700)),
                      onPressed: () => _makeCall(shop.phone!),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Products Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Verified Store Inventory (${shopProducts.isNotEmpty ? shopProducts.length : catalog.products.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Fresh 7-Day Stock',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Products Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: shopProducts.isNotEmpty ? shopProducts.length : catalog.products.take(6).length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  final p = shopProducts.isNotEmpty ? shopProducts[index] : catalog.products[index];
                  return ProductCard(product: p);
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
