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
import '../returns/returns_screen.dart';
import '../wallet/wallet_cashback_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderNumber;

  const OrderTrackingScreen({super.key, required this.orderNumber});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final TextEditingController _otpInputController = TextEditingController();
  bool _isSubmittingOtp = false;
  String? _otpError;
  bool _hasTriggeredArrivalSheet = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().startLiveTracking(widget.orderNumber);
    });
  }

  @override
  void dispose() {
    _otpInputController.dispose();
    context.read<OrderProvider>().stopLiveTracking();
    super.dispose();
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _confirmDeliveryOtp(OrderModel order, [String? otpOverride]) async {
    final otp = (otpOverride ?? _otpInputController.text).trim();
    if (otp.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      setState(() {
        _otpError = 'Please enter a valid 6-digit numeric verification code.';
      });
      return;
    }

    setState(() {
      _isSubmittingOtp = true;
      _otpError = null;
    });

    final orderProv = context.read<OrderProvider>();
    final success = await orderProv.confirmDelivery(order.orderNumber, otp);

    if (!mounted) return;

    setState(() {
      _isSubmittingOtp = false;
      if (!success) {
        _otpError = orderProv.errorMessage ?? 'Invalid verification code. Please try again.';
      } else {
        _otpError = null;
        _otpInputController.clear();
      }
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delivery custody finalized! 5% Cashback credited to your wallet.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _checkAndTriggerDoorstepSheet(OrderModel order) {
    if (order.riderArrived && !order.isDelivered && !_hasTriggeredArrivalSheet) {
      _hasTriggeredArrivalSheet = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showDoorstepBottomSheet(order);
      });
    }
  }

  void _showDoorstepBottomSheet(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryGold.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, color: AppColors.primaryPurple, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Courier at Your Doorstep!',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                        Text(
                          '${order.riderName ?? "Courier"} has arrived with your order',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
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
                    Icon(Icons.shield_outlined, color: AppColors.success, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Physically inspect the package seal first. Once satisfied, enter the 6-digit code received via SMS/WhatsApp.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textPrimary, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ENTER 6-DIGIT DELIVERY CODE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _otpInputController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 10,
                  color: AppColors.primaryDarkPurple,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  hintStyle: const TextStyle(letterSpacing: 10, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceMuted,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2)),
                ),
              ),
              if (order.verificationCode != null && order.verificationCode!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Center(
                  child: InkWell(
                    onTap: () {
                      _otpInputController.text = order.verificationCode!;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryGoldLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.secondaryGold),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sms, size: 14, color: AppColors.primaryPurple),
                          const SizedBox(width: 6),
                          Text(
                            'Auto-Fill Received Code: ${order.verificationCode}',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryDarkPurple),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (_otpError != null) ...[
                const SizedBox(height: 10),
                Text(
                  _otpError!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 20),
              CustomButton(
                text: 'Confirm Delivery & Release Custody',
                icon: Icons.verified_user,
                isLoading: _isSubmittingOtp,
                backgroundColor: AppColors.success,
                onPressed: () async {
                  await _confirmDeliveryOtp(order);
                  if (mounted && _otpError == null) {
                    Navigator.pop(ctx);
                  }
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.danger),
                  label: const Text(
                    'Wrong Item / Defective? Reject Delivery',
                    style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showRejectionGuideDialog(order);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectionGuideDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: AppColors.danger, size: 22),
            SizedBox(width: 8),
            Text('Doorstep Refusal Guard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'If the item is broken, wrong, or counterfeit:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 8),
            Text(
              '1. DO NOT enter or share your 6-digit delivery PIN.\n'
              '2. Inform the dispatch courier you are refusing the package.\n'
              '3. The courier will return the package to the merchant.\n'
              '4. Your payment is protected in platform escrow and will be credited to your wallet.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReturnsScreen()));
            },
            child: const Text('File Return Case'),
          ),
        ],
      ),
    );
  }

  Widget _buildDoorstepArrivalCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.royalPurpleGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.purpleShadow,
        border: Border.all(color: AppColors.secondaryGold, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.doorbell, color: AppColors.textPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COURIER HAS ARRIVED!',
                      style: TextStyle(
                        color: AppColors.secondaryGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '${order.riderName ?? "Courier"} is at your doorstep',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Inspect your parcel seal before entering code. Enter the 6-digit delivery PIN you received to confirm custody:',
            style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.3),
          ),
          const SizedBox(height: 14),
          // 6-Digit Code Input Box
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.secondaryGold, width: 1.5),
            ),
            child: TextField(
              controller: _otpInputController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
                color: AppColors.primaryDarkPurple,
              ),
              decoration: const InputDecoration(
                counterText: '',
                hintText: 'Enter 6-Digit PIN',
                hintStyle: TextStyle(letterSpacing: 2, fontSize: 14, color: AppColors.textMuted, fontWeight: FontWeight.normal),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (order.verificationCode != null && order.verificationCode!.isNotEmpty) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                _otpInputController.text = order.verificationCode!;
                _confirmDeliveryOtp(order, order.verificationCode!);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on, size: 13, color: AppColors.secondaryGold),
                    const SizedBox(width: 4),
                    Text(
                      'One-Tap Verify (Demo Code: ${order.verificationCode})',
                      style: const TextStyle(color: AppColors.secondaryGold, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_otpError != null) ...[
            const SizedBox(height: 8),
            Text(
              _otpError!,
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 16),
          CustomButton(
            text: 'Confirm Delivery & Release Custody',
            icon: Icons.check_circle_outline,
            isLoading: _isSubmittingOtp,
            backgroundColor: AppColors.success,
            onPressed: () => _confirmDeliveryOtp(order),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveredCelebrationCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success, width: 1.5),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DELIVERY COMPLETED & VERIFIED',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.formattedCashbackEarned} Sovereign Cashback Credited',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletCashbackScreen()));
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet, size: 16, color: AppColors.primaryPurple),
                SizedBox(width: 6),
                Text(
                  'View Sovereign Cashback Balance in Wallet',
                  style: TextStyle(color: AppColors.primaryPurple, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 11, color: AppColors.primaryPurple),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.primaryPurple, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '24-Hour Return Window Active',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Item defective or wrong? Open a return claim before funds unlock to vendor.',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE2E2),
                    foregroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReturnsScreen(
                          initialOrderNumber: order.orderNumber,
                          initialOrderId: order.id,
                        ),
                      ),
                    );
                  },
                  child: const Text('Request Return', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAttemptCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Courier Delivery Attempt Logged',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF92400E)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Text('ATTEMPT FAILED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFB45309))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Our dispatch courier arrived at your address but could not complete handover (${order.deliveryFailureReason?.replaceAll("_", " ") ?? "Gate Locked / Recipient Unreachable"}).',
            style: const TextStyle(fontSize: 12, color: Color(0xFF78350F), height: 1.3),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order.deliveryAttemptPhoto!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: const Color(0xFFFEF3C7),
                      child: const Icon(Icons.camera_alt, color: Color(0xFFB45309)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📸 Doorstep / Gate Proof Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF92400E))),
                      const SizedBox(height: 2),
                      const Text('Live photo captured on courier device at arrival.', style: TextStyle(fontSize: 10.5, color: Color(0xFF78350F))),
                      if (order.riderPhone != null) ...[
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => _makeCall(order.riderPhone!),
                          child: const Text('📞 Call Courier Directly', style: TextStyle(color: AppColors.primaryPurple, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualAuditTrailCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
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
          const Row(
            children: [
              Icon(Icons.camera_alt_outlined, color: AppColors.primaryPurple, size: 20),
              SizedBox(width: 8),
              Text('Live Camera Audit Trail', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          if (order.pickupCounterPhoto != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        order.pickupCounterPhoto!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey[200]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🏬 Merchant Counter Pickup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('Live photo verified at branch counter', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (order.doorstepDeliveryPhoto != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        order.doorstepDeliveryPhoto!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey[200]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🏠 Doorstep Delivery Handover', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF166534))),
                          Text('Live photo snapped upon package handover', style: TextStyle(fontSize: 10.5, color: Color(0xFF15803D))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (order.itemRejectionPhotos.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '❌ Doorstep Rejection Proofs (${order.itemRejectionPhotos.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF991B1B)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: order.itemRejectionPhotos.map((p) => ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        p,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey[300]),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final order = orderProv.activeOrder;

    if (order != null) {
      _checkAndTriggerDoorstepSheet(order);
    }

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
                        // State 0: Courier Attempt Failure Warning (e.g. Locked gate / Unreachable)
                        if (order.deliveryAttemptPhoto != null)
                          _buildDeliveryAttemptCard(order),

                        // State 1: Courier arrived at Doorstep -> Prompt Entry Card
                        if (order.riderArrived && !order.isDelivered)
                          _buildDoorstepArrivalCard(order)
                        // State 2: Order Delivered -> Celebratory Card
                        else if (order.isDelivered)
                          _buildDeliveredCelebrationCard(order)
                        // State 3: Out for Delivery or earlier -> Secret Delivery PIN card
                        else if (order.verificationCode != null && order.verificationCode!.isNotEmpty)
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
                                      color: order.riderArrived && !order.isDelivered
                                          ? AppColors.secondaryGoldLight
                                          : AppColors.primaryPurple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: order.riderArrived && !order.isDelivered
                                          ? Border.all(color: AppColors.secondaryGold)
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          order.riderArrived && !order.isDelivered ? Icons.location_on : Icons.sync,
                                          size: 12,
                                          color: order.riderArrived && !order.isDelivered ? AppColors.secondaryGoldDark : AppColors.primaryPurple,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          order.riderArrived && !order.isDelivered ? 'Rider at Doorstep' : 'Auto-updating',
                                          style: TextStyle(
                                            color: order.riderArrived && !order.isDelivered ? AppColors.secondaryGoldDark : AppColors.primaryPurple,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
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
                                      if (item.hasRejection) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFFFECACA)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.cancel, size: 12, color: Color(0xFFDC2626)),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Rejected (${item.rejectedQuantity}) • ${item.rejectionCategory?.replaceAll("_", " ") ?? "Defect / Mismatch"}',
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                                              ),
                                              if (item.defectPhoto != null) ...[
                                                const SizedBox(width: 6),
                                                const Text('📸 Defect Snapped', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
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
                              if (order.walletCreditApplied != '0.00' && order.walletCreditApplied != '0') ...[
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Refund Wallet Credit Applied:', style: TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold)),
                                    Text('-₦${order.walletCreditApplied}', style: const TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
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

                        // Visual Audit Trail Card
                        if (order.pickupCounterPhoto != null || order.doorstepDeliveryPhoto != null || order.itemRejectionPhotos.isNotEmpty)
                          _buildVisualAuditTrailCard(order),

                        // Bottom Action Button if Doorstep Card was scrolled past
                        if (order.riderArrived && !order.isDelivered) ...[
                          const SizedBox(height: 20),
                          CustomButton(
                            text: 'Open Code Input Box',
                            icon: Icons.keyboard,
                            backgroundColor: AppColors.primaryPurple,
                            onPressed: () => _showDoorstepBottomSheet(order),
                          ),
                        ],

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
    );
  }
}
