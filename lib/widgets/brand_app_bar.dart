import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/cart_provider.dart';
import '../providers/notification_provider.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/notifications/notifications_screen.dart';

/// Reusable Sovereign Brand Title for Victorious MARKET
class BrandTitle extends StatelessWidget {
  final double fontSize;
  final bool showSubtitle;
  final String? subtitle;
  final CrossAxisAlignment crossAxisAlignment;

  const BrandTitle({
    super.key,
    this.fontSize = 17,
    this.showSubtitle = true,
    this.subtitle,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
            children: const [
              TextSpan(
                text: 'Victorious ',
                style: TextStyle(color: Color(0xFFFFD700)),
              ),
              TextSpan(
                text: 'MARKET',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 1),
          Text(
            subtitle ?? 'Your Trusted Online Market',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: (fontSize * 0.62).clamp(10.0, 12.0),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ],
    );
  }
}

class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showCart;
  final bool showBack;
  final bool showNotification;
  final List<Widget>? actions;

  const BrandAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showCart = true,
    this.showBack = true,
    this.showNotification = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.royalPurpleGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (showBack && Navigator.canPop(context))
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    AppConstants.iconAsset,
                    width: 34,
                    height: 34,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.store, color: AppColors.secondaryGold, size: 30),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: titleWidget ??
                    (title != null
                        ? Text(
                            title!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : const BrandTitle()),
              ),
              if (actions != null) ...actions!,
              if (showNotification)
                Consumer<NotificationProvider>(
                  builder: (context, notifProv, _) => Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.white, size: 26),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                          );
                        },
                      ),
                      if (notifProv.unreadCount > 0)
                        Positioned(
                          right: 6,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                            child: Text(
                              notifProv.unreadCount > 99 ? '99+' : '${notifProv.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              if (showCart)
                Consumer<CartProvider>(
                  builder: (context, cart, _) => Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 26),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CartScreen()),
                          );
                        },
                      ),
                      if (cart.itemCount > 0)
                        Positioned(
                          right: 6,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryGold,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                            child: Text(
                              cart.itemCount > 99 ? '99+' : '${cart.itemCount}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
