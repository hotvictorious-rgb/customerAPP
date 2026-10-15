import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/banner_model.dart';
import '../screens/catalog/catalog_screen.dart';

class BannerSliderWidget extends StatefulWidget {
  final List<BannerModel> banners;

  const BannerSliderWidget({super.key, required this.banners});

  @override
  State<BannerSliderWidget> createState() => _BannerSliderWidgetState();
}

class _BannerSliderWidgetState extends State<BannerSliderWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (widget.banners.length > 1) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_pageController.hasClients) {
          int nextPage = (_currentPage + 1) % widget.banners.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant BannerSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.banners.length != oldWidget.banners.length) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildBannerCard(context, banner),
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == index ? 22 : 6,
                height: 5,
                decoration: BoxDecoration(
                  color: _currentPage == index ? AppColors.primaryPurple : AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBannerCard(BuildContext context, BannerModel banner) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CatalogScreen()),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: _parseGradient(banner.templateStyle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: banner.isFullCover
              ? _buildFullCover(banner)
              : _buildSplitLayout(banner),
        ),
      ),
    );
  }

  Widget _buildFullCover(BannerModel banner) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (banner.imageUrl != null && banner.imageUrl!.isNotEmpty)
          CachedNetworkImage(
            imageUrl: banner.imageUrl!,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => _buildFallbackGraphic(banner),
          )
        else
          _buildFallbackGraphic(banner),
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.75),
              ],
            ),
          ),
        ),
        Positioned(
          left: 14,
          right: 14,
          bottom: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (banner.badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  margin: const EdgeInsets.bottom(4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    banner.badgeText!.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              Text(
                banner.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (banner.subtitle != null)
                Text(
                  banner.subtitle!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSplitLayout(BannerModel banner) {
    return Row(
      children: [
        // Left Column (Text & CTAs)
        Expanded(
          flex: 12,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge Pill
                if (banner.badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    margin: const EdgeInsets.bottom(5),
                    decoration: BoxDecoration(
                      color: _getBadgeBg(banner.templateStyle),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      banner.badgeText!.toUpperCase(),
                      style: TextStyle(
                        color: _getBadgeTextColor(banner.templateStyle),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                // Main Headline
                Text(
                  banner.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 3),

                // Subtitle
                if (banner.subtitle != null)
                  Text(
                    banner.subtitle!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 8),

                // Action Pill & Discount Tag
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getCtaColor(banner.templateStyle),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            banner.ctaText,
                            style: TextStyle(
                              color: _getCtaTextColor(banner.templateStyle),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 11,
                            color: _getCtaTextColor(banner.templateStyle),
                          ),
                        ],
                      ),
                    ),
                    if (banner.discountTag != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          banner.discountTag!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),

        // Right Column (Cutout Image / Graphic)
        Expanded(
          flex: 8,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 12, 10),
            child: Center(
              child: banner.imageUrl != null && banner.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: banner.imageUrl!,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondaryGold),
                        ),
                      ),
                      errorWidget: (_, __, ___) => _buildFallbackGraphic(banner),
                    )
                  : _buildFallbackGraphic(banner),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackGraphic(BannerModel banner) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: const Icon(Icons.storefront, color: AppColors.secondaryGold, size: 36),
    );
  }

  LinearGradient _parseGradient(String style) {
    switch (style) {
      case 'flash_urgency':
        return const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF7F1D1D), Color(0xFF991B1B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'fresh_market':
        return const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'brand_prestige':
        return const LinearGradient(
          colors: [Color(0xFF0A0A0A), Color(0xFF1E1B4B), Color(0xFF311042)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'minimal_bento':
        return const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'luxury_split':
      default:
        return const LinearGradient(
          colors: [Color(0xFF2D0C54), Color(0xFF4C1D95), Color(0xFF1E0738)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getBadgeBg(String style) {
    switch (style) {
      case 'flash_urgency':
        return Colors.red.shade600;
      case 'fresh_market':
        return const Color(0xFF10B981);
      case 'brand_prestige':
      case 'luxury_split':
      default:
        return AppColors.secondaryGold;
    }
  }

  Color _getBadgeTextColor(String style) {
    switch (style) {
      case 'flash_urgency':
      case 'fresh_market':
        return Colors.white;
      case 'brand_prestige':
      case 'luxury_split':
      default:
        return AppColors.textPrimary;
    }
  }

  Color _getCtaColor(String style) {
    switch (style) {
      case 'flash_urgency':
        return Colors.amber.shade400;
      case 'fresh_market':
        return Colors.white;
      case 'brand_prestige':
      case 'luxury_split':
      default:
        return AppColors.secondaryGold;
    }
  }

  Color _getCtaTextColor(String style) {
    switch (style) {
      case 'fresh_market':
        return const Color(0xFF064E3B);
      case 'flash_urgency':
      case 'brand_prestige':
      case 'luxury_split':
      default:
        return AppColors.textPrimary;
    }
  }
}
