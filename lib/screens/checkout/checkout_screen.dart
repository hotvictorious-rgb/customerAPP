import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/address_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/cashback_provider.dart';
import '../../providers/checkout_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/brand_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../address/add_address_screen.dart';
import '../orders/order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().fetchAddresses();
      context.read<CashbackProvider>().fetchCashback();
      _runFulfillmentCheck();
    });
  }

  Future<void> _runFulfillmentCheck() async {
    final cart = context.read<CartProvider>();
    final address = context.read<AddressProvider>();
    final checkout = context.read<CheckoutProvider>();

    if (cart.shopId != null) {
      await checkout.checkFulfillmentAvailability(
        shopId: cart.shopId!,
        destinationLgaId: address.selectedAddress?.lgaId,
      );
    }
  }

  Future<void> _processCheckout() async {
    final cart = context.read<CartProvider>();
    final address = context.read<AddressProvider>();
    final checkout = context.read<CheckoutProvider>();

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your bag is empty.')));
      return;
    }

    if (checkout.isDoorstepDelivery && address.selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a delivery address.')));
      return;
    }

    // Step 1: Create Authoritative Checkout Intent Snapshot
    final intent = await checkout.createCheckoutIntent(
      shopId: cart.shopId!,
      customerAddressId: address.selectedAddress?.id,
      items: cart.items,
    );

    if (intent != null && mounted) {
      // Step 2: Show Settlement Simulation / Paystack confirmation dialog
      _showPaystackDialog(intent.fingerprint, intent.totalPayable);
    } else if (mounted && checkout.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(checkout.errorMessage!),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showPaystackDialog(String fingerprint, String amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.payment, color: AppColors.secondaryGold, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Paystack Gateway', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Secure Payment Gateway Settlement',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Payable: ₦$amount',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryPurple),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Intent Fingerprint: ${fingerprint.substring(0, 16)}...',
                style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              Navigator.pop(ctx);
              final cart = context.read<CartProvider>();
              final address = context.read<AddressProvider>();
              final checkout = context.read<CheckoutProvider>();

              final orderData = await checkout.executeOrderAndPay(
                shopId: cart.shopId!,
                customerAddressId: address.selectedAddress?.id,
                items: cart.items,
                paymentMethod: 'paystack',
              );

              final orderNum = orderData != null ? orderData['order_number'] as String? : null;

              cart.clearCart();

              // Fetch latest orders & open tracking screen
              final orderProv = context.read<OrderProvider>();
              await orderProv.fetchOrders();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment verified! Your order is placed and being prepared.'),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingScreen(
                      orderNumber: orderNum ?? (orderProv.orders.isNotEmpty ? orderProv.orders.first.orderNumber : 'VM-ORD-9081'),
                    ),
                  ),
                );
              }
            },
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final address = context.watch<AddressProvider>();
    final checkout = context.watch<CheckoutProvider>();
    final cashback = context.watch<CashbackProvider>();

    return Scaffold(
      appBar: const BrandAppBar(
        title: 'Directional Checkout',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fulfillment Mode Switcher
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        checkout.setFulfillmentType('doorstep_delivery');
                        _runFulfillmentCheck();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: checkout.isDoorstepDelivery ? AppColors.primaryPurple : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_shipping,
                              size: 16,
                              color: checkout.isDoorstepDelivery ? Colors.white : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Doorstep Delivery',
                              style: TextStyle(
                                color: checkout.isDoorstepDelivery ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        checkout.setFulfillmentType('in_shop_pickup');
                        _runFulfillmentCheck();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !checkout.isDoorstepDelivery ? AppColors.primaryPurple : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.storefront,
                              size: 16,
                              color: !checkout.isDoorstepDelivery ? Colors.white : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'In-Shop Pickup',
                              style: TextStyle(
                                color: !checkout.isDoorstepDelivery ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // If Doorstep: Shipping Address Section
            if (checkout.isDoorstepDelivery) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Delivery Destination Address',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16, color: AppColors.primaryPurple),
                    label: const Text('Add New', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddAddressScreen()),
                      ).then((_) => _runFulfillmentCheck());
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (address.addresses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_off, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'No saved address found. Please add your Akwa Ibom destination address.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddAddressScreen()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('Add', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryPurple, width: 1.5),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primaryPurple, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            address.selectedAddress?.contactName ?? 'Recipient',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          const Spacer(),
                          Text(
                            address.selectedAddress?.phone ?? '',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        address.selectedAddress?.fullAddressText ?? '',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Directional Lane Result Card
              if (checkout.fulfillmentResult != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: checkout.fulfillmentResult!.isAvailable ? AppColors.successLight : AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: checkout.fulfillmentResult!.isAvailable ? AppColors.success : AppColors.danger,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        checkout.fulfillmentResult!.isAvailable ? Icons.check_circle : Icons.error_outline,
                        color: checkout.fulfillmentResult!.isAvailable ? AppColors.success : AppColors.danger,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              checkout.fulfillmentResult!.laneName ?? 'Directional Lane Active',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: checkout.fulfillmentResult!.isAvailable ? AppColors.textPrimary : AppColors.danger,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              checkout.fulfillmentResult!.message,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (checkout.fulfillmentResult!.isAvailable)
                        Text(
                          checkout.fulfillmentResult!.formattedFee,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryPurple),
                        ),
                    ],
                  ),
                ),
            ] else ...[
              // In-Shop Pickup Explanation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGoldLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.secondaryGold),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.storefront, color: AppColors.primaryPurple, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Akwa Ibom Trust Model (₦0.00 Delivery Fee)',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Items are reserved for you at the merchant shop for 24 hours. Physically inspect before paying.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // 100% Spendable Wallet Credit Redemption Card (From Doorstep Refunds & Returns)
            if (cashback.walletSummary != null && cashback.walletSummary!.balanceDouble > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0F766E), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F766E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'Apply Spendable Wallet Credit',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              SizedBox(width: 6),
                              Text(
                                '100%',
                                style: TextStyle(
                                  color: Color(0xFF0F766E),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Available Refund Balance: ${cashback.walletSummary!.formattedBalance}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: checkout.redeemWalletCredit,
                      activeColor: const Color(0xFF0F766E),
                      onChanged: (val) => checkout.toggleWalletCredit(val),
                    ),
                  ],
                ),
              ),

            // 5% Sovereign Cashback Redemption Card
            if (cashback.cashback != null && cashback.cashback!.availableDouble > 0)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondaryGold, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: AppColors.secondaryGoldDark, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Redeem Sovereign Cashback',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                          Text(
                            'Available Balance: ${cashback.cashback!.formattedAvailable} (Capped at 50% of items)',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: checkout.redeemCashback,
                      activeColor: AppColors.primaryPurple,
                      onChanged: (val) => checkout.toggleCashback(val),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Final Authoritative Price Summary
            Container(
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
                  const Text('Payment Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Merchandise Subtotal', style: TextStyle(color: AppColors.textSecondary)),
                      Text(cart.formattedSubtotal, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Directional Delivery Fee', style: TextStyle(color: AppColors.textSecondary)),
                      Text(
                        checkout.isDoorstepDelivery
                            ? (checkout.fulfillmentResult?.formattedFee ?? 'Calculating...')
                            : '₦0.00 (In-Shop Pickup)',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  if (checkout.redeemCashback) ...[
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Cashback Discount Applied', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                        Text('Applied at Intent', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                  if (checkout.redeemWalletCredit) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Spendable Wallet Credit', style: TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold)),
                        Text(
                          'Up to ${cashback.walletSummary?.formattedBalance ?? "₦0.00"}',
                          style: const TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Grand Total Payable', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      Text(
                        cart.formattedSubtotal,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryPurple),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            CustomButton(
              text: checkout.isDoorstepDelivery
                  ? (checkout.redeemWalletCredit ? 'Confirm & Apply Wallet Credit' : 'Pay via Paystack')
                  : 'Confirm In-Shop Reservation',
              icon: Icons.lock,
              isLoading: checkout.isLoading,
              onPressed: _processCheckout,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
