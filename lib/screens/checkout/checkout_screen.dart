import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../models/customer_address_model.dart';
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

  void _showAddressSelectionModal(BuildContext context) {
    final addressProv = context.read<AddressProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Delivery Destination',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16, color: AppColors.primaryPurple),
                  label: const Text('New Address', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
                    ).then((_) => _runFulfillmentCheck());
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: addressProv.addresses.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final addr = addressProv.addresses[i];
                  final isSelected = addressProv.selectedAddress?.id == addr.id;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? AppColors.primaryPurple : AppColors.textMuted,
                    ),
                    title: Text(
                      '${addr.contactName} (${addr.lgaName ?? "LGA"})',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13,
                        color: isSelected ? AppColors.primaryPurple : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      addr.fullAddressText,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      addressProv.selectAddress(addr);
                      Navigator.pop(ctx);
                      _runFulfillmentCheck();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finalizeOrderSuccess({required String orderNumber}) async {
    final cart = context.read<CartProvider>();
    cart.clearCart();

    final orderProv = context.read<OrderProvider>();
    await orderProv.fetchOrders();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment verified! Order $orderNumber is placed and being prepared.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(orderNumber: orderNumber),
        ),
      );
    }
  }

  void _showPaymentVerificationSheet({
    required String orderNumber,
    required String reference,
    required String authUrl,
  }) {
    bool isVerifying = false;
    String? verifyError;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.payment, color: AppColors.primaryPurple, size: 32),
              ),
              const SizedBox(height: 14),
              const Text(
                'Complete Payment via Paystack',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                'Order #$orderNumber • Ref: ${reference.length > 12 ? reference.substring(0, 12) + "..." : reference}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primaryPurple, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'The secure Paystack payment window has opened in your browser. Complete your transfer or card payment, then tap "Verify Payment".',
                        style: TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              if (verifyError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          verifyError!,
                          style: const TextStyle(color: AppColors.danger, fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              CustomButton(
                text: 'I Have Paid • Verify Payment',
                icon: Icons.verified_user,
                isLoading: isVerifying,
                backgroundColor: AppColors.success,
                onPressed: () async {
                  setSheetState(() {
                    isVerifying = true;
                    verifyError = null;
                  });

                  final checkout = context.read<CheckoutProvider>();
                  final ok = await checkout.verifyOrderPayment(
                    orderNumber: orderNumber,
                    reference: reference,
                  );

                  if (ok) {
                    Navigator.pop(ctx);
                    await _finalizeOrderSuccess(orderNumber: orderNumber);
                  } else {
                    setSheetState(() {
                      isVerifying = false;
                      verifyError = checkout.errorMessage ?? 'Payment could not be verified yet. If you were just debited, please wait 5 seconds and tap again.';
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.open_in_new, size: 16, color: AppColors.primaryPurple),
                label: const Text('Re-open Paystack Gateway', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryPurple),
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  final uri = Uri.parse(authUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
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
      // Step 2: Show Settlement / Paystack confirmation dialog
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
              final paystack = orderData != null ? orderData['paystack'] as Map<String, dynamic>? : null;

              if (orderData != null && orderNum != null) {
                if (paystack != null && paystack['authorization_url'] != null) {
                  final authUrl = paystack['authorization_url'] as String;
                  final reference = (paystack['reference'] ?? '') as String;
                  final uri = Uri.parse(authUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                  if (mounted) {
                    _showPaymentVerificationSheet(
                      orderNumber: orderNum,
                      reference: reference,
                      authUrl: authUrl,
                    );
                  }
                } else {
                  _finalizeOrderSuccess(orderNumber: orderNum);
                }
              } else if (mounted && checkout.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(checkout.errorMessage!),
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
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
                InkWell(
                  onTap: () => _showAddressSelectionModal(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Change',
                                    style: TextStyle(
                                      color: AppColors.primaryPurple,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.primaryPurple),
                                ],
                              ),
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
