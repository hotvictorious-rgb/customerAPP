import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/system_notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/brand_app_bar.dart';
import '../orders/order_tracking_screen.dart';
import '../returns/returns_screen.dart';
import '../wallet/wallet_cashback_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilterIndex = 0; // 0 = All, 1 = Unread

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications(refresh: true);
    });
  }

  void _handleNotificationTap(SystemNotificationModel notif) {
    if (!notif.isRead) {
      context.read<NotificationProvider>().markAsRead(notif.id);
    }

    final data = notif.data;
    if (data != null) {
      if (data['order_number'] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(orderNumber: data['order_number'].toString()),
          ),
        );
        return;
      }
      if (data['case_number'] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReturnsScreen()),
        );
        return;
      }
      if (notif.type.toLowerCase().contains('cashback') || notif.type.toLowerCase().contains('wallet')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WalletCashbackScreen()),
        );
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NotificationProvider>();
    final allNotifs = prov.notifications;
    final displayedNotifs = _selectedFilterIndex == 1
        ? allNotifs.where((n) => !n.isRead).toList()
        : allNotifs;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: BrandAppBar(
        title: 'Notification Center',
        showBack: true,
        showCart: false,
        actions: [
          if (prov.unreadCount > 0)
            TextButton.icon(
              icon: const Icon(Icons.done_all, color: AppColors.secondaryGold, size: 18),
              label: const Text(
                'Mark All Read',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              onPressed: () => prov.markAllAsRead(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (All / Unread)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                _buildFilterChip('All (${allNotifs.length})', 0),
                const SizedBox(width: 10),
                _buildFilterChip('Unread (${prov.unreadCount})', 1),
              ],
            ),
          ),
          const Divider(height: 1),

          // Notification List
          Expanded(
            child: prov.isLoading && allNotifs.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
                : displayedNotifs.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: AppColors.primaryPurple,
                        onRefresh: () => prov.fetchNotifications(refresh: true),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: displayedNotifs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final notif = displayedNotifs[index];
                            return _buildNotificationCard(notif);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(SystemNotificationModel notif) {
    return InkWell(
      onTap: () => _handleNotificationTap(notif),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : notif.backgroundColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead ? AppColors.border : notif.accentColor.withOpacity(0.4),
            width: notif.isRead ? 1 : 1.5,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notif.accentColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(notif.iconData, color: notif.accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.isRead ? FontWeight.w700 : FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notif.timeAgo,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.body,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: notif.isRead ? AppColors.textSecondary : AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (!notif.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: notif.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, size: 56, color: AppColors.primaryPurple),
          ),
          const SizedBox(height: 18),
          const Text(
            'All Caught Up!',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'No notifications at the moment.\nDispatch and order updates will appear here in real time.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
