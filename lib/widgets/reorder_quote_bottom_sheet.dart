import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/reorder_quote_model.dart';
import '../providers/address_provider.dart';
import '../providers/order_provider.dart';
import '../providers/returns_provider.dart';
import '../screens/orders/order_tracking_screen.dart';
import 'custom_button.dart';

class ReorderQuoteBottomSheet extends StatefulWidget {
  final ReorderQuoteModel quote;

  const ReorderQuoteBottomSheet({
    super.key,
    required this.quote,
  });

  static Future<void> show(
    BuildContext context, {
    required ReorderQuoteModel quote,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReorderQuoteBottomSheet(quote: quote),
    );
  }

  @override
  State<ReorderQuoteBottomSheet> createState() => _ReorderQuoteBottomSheetState();
}

class _ReorderQuoteBottomSheetState extends State<ReorderQuoteBottomSheet> {
  int? _selectedAddressId;
  bool _isPlacingOrder = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressProvider = context.read<AddressProvider>();
      if (addressProvider.addresses.isEmpty) {
        addressProvider.fetchAddresses();
      }
      if (addressProvider.defaultAddress != null) {
        setState(() {
          _selectedAddressId = addressProvider.defaultAddress!.id;
        });
      }
    });
  }

  Future<void> _handleConfirmReorder() async {
    final addressProvider = context.read<AddressProvider>();
    final addressId = _selectedAddressId ?? addressProvider.defaultAddress?.id;

    if (addressId == null) {
      setState(() {
        _errorMessage = 'Please select a delivery address for replacement dispatch.';
      });
      return;
    }

    setState(() {
      _isPlacingOrder = true;
      _errorMessage = null;
    });

    final returnsProvider = context.read<ReturnsProvider>();
    final result = await returnsProvider.executeReorderWithWallet(
      quote: widget.quote,
      addressId: addressId,
    );

    if (!mounted) return;

    if (result != null) {
      final newOrderNumber = result['order_number']?.toString() ??
          (result['order'] != null ? result['order']['order_number']?.toString() : null);

      // Refresh orders and active returns
      context.read<OrderProvider>().fetchOrders();
      returnsProvider.fetchReturnCases();

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '⚡ Replacement order created successfully! Order #${newOrderNumber ?? ""}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );

      if (newOrderNumber != null && newOrderNumber.isNotEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(orderNumber: newOrderNumber),
          ),
        );
      }
    } else {
      setState(() {
        _isPlacingOrder = false;
        _errorMessage = returnsProvider.errorMessage ?? 'Failed to place replacement order.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final addressProvider = context.watch<AddressProvider>();
    final addresses = addressProvider.addresses;
    final defaultAddr = addressProvider.defaultAddress;

    if (_selectedAddressId == null && defaultAddr != null) {
      _selectedAddressId = defaultAddr.id;
    } else if (_selectedAddressId == null && addresses.isNotEmpty) {
      _selectedAddressId = addresses.first.id;
    }

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(color: Color(0x22000000), blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Banner
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE9D5FF)),
                  ),
                  child: const Icon(Icons.flash_on, color: AppColors.primaryPurple, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1-Click Instant Re-Order',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Case #${widget.quote.caseNumber} • 100% Wallet Credit Covered',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Explanatory Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.success, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your instant refund credit is pre-authorized. Confirming will dispatch new replacement stock immediately without payment gateway delays.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF166534),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Replacement Items Manifest
            const Text(
              'Replacement Items Manifest',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: widget.quote.items.length,
                separatorBuilder: (_, __) => const Divider(height: 16, color: Color(0xFFE2E8F0)),
                itemBuilder: (ctx, idx) {
                  final item = widget.quote.items[idx];
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Text(
                          '${item.quantity}x',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        item.formattedSubtotal,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // Delivery Address Selector
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),

            if (addresses.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_off, color: Color(0xFFD97706), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No saved address found. Please add a destination address first.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedAddressId,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryPurple),
                    items: addresses.map((addr) {
                      return DropdownMenuItem<int>(
                        value: addr.id,
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: AppColors.primaryPurple),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${addr.contactName} • ${addr.addressLine}',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedAddressId = val;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),

            // Financial Summary Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Merchandise Total:', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      Text(widget.quote.formattedSubtotal, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance_wallet, size: 14, color: AppColors.success),
                          SizedBox(width: 4),
                          Text('Instant Refund Wallet Credit:', style: TextStyle(fontSize: 12.5, color: AppColors.success, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Text(
                        '-${widget.quote.formattedWalletApplied}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.success),
                      ),
                    ],
                  ),
                  const Divider(height: 18, color: Color(0xFFE2E8F0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Net Cash Payable:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Text(
                        widget.quote.isFullyCoveredByWallet ? '₦0.00 (100% Free)' : widget.quote.formattedNetPayable,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: widget.quote.isFullyCoveredByWallet ? AppColors.success : AppColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.danger, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppColors.danger, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Confirm Reorder Action Button
            CustomButton(
              text: widget.quote.isFullyCoveredByWallet
                  ? 'Confirm 1-Click Replacement (₦0.00)'
                  : 'Pay Difference (${widget.quote.formattedNetPayable}) & Re-Order',
              icon: Icons.check_circle_outline,
              isLoading: _isPlacingOrder,
              onPressed: _handleConfirmReorder,
            ),
          ],
        ),
      ),
    );
  }
}
