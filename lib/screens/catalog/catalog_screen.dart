import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/brand_app_bar.dart';
import '../../widgets/product_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();

    return Scaffold(
      appBar: const BrandAppBar(
        title: 'Explore Marketplace',
        showBack: true,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => catalog.search(val),
                  decoration: InputDecoration(
                    hintText: 'Search products by name or description...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryPurple),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              catalog.search('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceMuted,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Horizontal category chip selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('All Categories'),
                          selected: catalog.selectedCategory == null,
                          onSelected: (_) => catalog.selectCategory(null),
                          selectedColor: AppColors.primaryPurple,
                          labelStyle: TextStyle(
                            color: catalog.selectedCategory == null ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      ...catalog.categories.map((cat) {
                        final isSelected = catalog.selectedCategory?.id == cat.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat.name),
                            selected: isSelected,
                            onSelected: (_) => catalog.selectCategory(cat),
                            selectedColor: AppColors.primaryPurple,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Product Results Grid
          Expanded(
            child: catalog.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryPurple),
                  )
                : catalog.products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
                            const SizedBox(height: 14),
                            const Text(
                              'No matching products found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Try clearing filters or search with another keyword',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                _searchController.clear();
                                catalog.selectCategory(null);
                                catalog.selectLga(null);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryPurple,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: const Text('Reset All Filters'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => catalog.fetchProducts(
                          categoryId: catalog.selectedCategory?.id,
                          lgaId: catalog.selectedLgaId,
                          search: _searchController.text,
                        ),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
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
          ),
        ],
      ),
    );
  }
}
