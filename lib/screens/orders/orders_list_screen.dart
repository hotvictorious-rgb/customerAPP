import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/brand_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import 'order_tracking_screen.dart';

class OrdersListScreen extends StatefulWidget {
  final bool isRootTab;

  const OrdersListScreen({super.key, this.isRootTab = false});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated) {
        context.read<OrderProvider>().fetchOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProv = context.watch<OrderProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: BrandAppBar(
          title: 'My Orders',
          showBack: !widget.isRootTab,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                const Text(
                  'Sign In to Track Orders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Access your real-time 5-stage delivery timelines and secret 6-digit delivery OTP cards.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Sign In Now',
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: BrandAppBar(
        title: 'Order History & Tracking',
        showBack: !widget.isRootTab,
      ),
      body: RefreshIndicator(
        onRefresh: () => orderProv.fetchOrders(),
        color: AppColors.primaryPurple,
        child: orderProv.isLoading && orderProv.orders.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
            : orderProv.orders.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          const Text(
                            'No Orders Yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your completed and ongoing purchases in Victorious MARKET will appear here.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orderProv.orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final order = orderProv.orders[index];
                      return _buildOrderCard(context, order);
                    },
                  ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    Color statusColor;
    switch (order.orderStatus.toLowerCase()) {
      case 'delivered':
      case 'completed':
        statusColor = AppColors.success;
        break;
      case 'out_for_delivery':
        statusColor = AppColors.warning;
        break;
      case 'ready_for_pickup':
        statusColor = AppColors.primaryPurple;
        break;
      default:
        statusColor = AppColors.primaryLightPurple;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderNumber,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.orderStatus.toUpperCase().replaceAll('_', ' '),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${order.items.length} item(s) • Total: ${order.formattedTotal}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.stars, color: AppColors.secondaryGoldDark, size: 14),
              const SizedBox(width: 4),
              Text(
                'Earns 5% Cashback: ${order.formattedCashbackEarned}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.isDoorstepDelivery ? 'Doorstep Delivery' : 'In-Shop Pickup',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.gps_fixed, size: 14),
                label: const Text('Track Live & PIN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderTrackingScreen(orderNumber: order.orderNumber),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
