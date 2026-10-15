import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/brand_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/delivery_stepper.dart';
import '../../widgets/otp_security_card.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderNumber;

  const OrderTrackingScreen({super.key, required this.orderNumber});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().startLiveTracking(widget.orderNumber);
    });
  }

  @override
  void dispose() {
    context.read<OrderProvider>().stopLiveTracking();
    super.dispose();
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final order = orderProv.activeOrder;

    return Scaffold(
      appBar: BrandAppBar(
        title: 'Track: ${widget.orderNumber}',
        showBack: true,
      ),
      body: orderProv.isLoading && order == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
          : order == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      const Text('Order details currently loading...'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => orderProv.fetchOrderDetails(widget.orderNumber),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primaryPurple,
                  onRefresh: () => orderProv.fetchOrderDetails(widget.orderNumber),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Secret 6-Digit Delivery OTP Card (Prominent Gold Security Card)
                        if (order.verificationCode != null && order.verificationCode!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: OtpSecurityCard(
                              otpCode: order.verificationCode!,
                              isDelivered: order.isDelivered,
                            ),
                          ),

                        // 5-Stage Live Timeline Stepper
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Live Delivery Progress',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryPurple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.sync, size: 12, color: AppColors.primaryPurple),
                                        SizedBox(width: 4),
                                        Text(
                                          'Auto-updating',
                                          style: TextStyle(color: AppColors.primaryPurple, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              DeliveryStepper(currentStep: order.statusStepIndex),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Assigned Delivery Courier Card
                        if (order.riderName != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                              boxShadow: AppColors.cardShadow,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryPurple.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.two_wheeler, color: AppColors.primaryPurple, size: 26),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.riderName!,
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        order.riderVehicle ?? 'Logistics Fleet Courier',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                if (order.riderPhone != null)
                                  IconButton(
                                    icon: const Icon(Icons.phone, color: AppColors.primaryPurple),
                                    onPressed: () => _makeCall(order.riderPhone!),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Order Summary & Receipt
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Order Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 12),
                              ...order.items.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.quantity}x ${item.productName}',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text(
                                        item.formattedTotal,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal:', style: TextStyle(color: AppColors.textSecondary)),
                                  Text(order.formattedSubtotal, style: const TextStyle(fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Delivery Fee:', style: TextStyle(color: AppColors.textSecondary)),
                                  Text(order.formattedDeliveryFee, style: const TextStyle(fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('5% Cashback Awarded:', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                                  Text(order.formattedCashbackEarned, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Settled:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                                  Text(order.formattedTotal, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.primaryPurple)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Doorstep Confirmation Action
                        if (!order.isDelivered && order.verificationCode != null)
                          CustomButton(
                            text: 'Customer Confirm Parcel Received',
                            icon: Icons.check_circle,
                            backgroundColor: AppColors.success,
                            onPressed: () async {
                              final success = await orderProv.confirmDelivery(
                                order.orderNumber,
                                order.verificationCode!,
                              );
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Delivery custody finalized! Enjoy your purchase.'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                          ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
    );
  }
}
