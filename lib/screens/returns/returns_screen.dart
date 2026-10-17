import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/return_case_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/returns_provider.dart';
import '../../widgets/brand_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/reorder_quote_bottom_sheet.dart';
import '../orders/order_tracking_screen.dart';

class ReturnsScreen extends StatefulWidget {
  final String? initialOrderNumber;
  final int? initialOrderId;

  const ReturnsScreen({
    super.key,
    this.initialOrderNumber,
    this.initialOrderId,
  });

  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  String? _selectedOrderNumber;
  int? _selectedOrderId;
  String _selectedReason = 'materially_defective';
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, String>> _reasons = [
    {'value': 'materially_defective', 'label': 'Defective / Not Functioning'},
    {'value': 'wrong_item', 'label': 'Wrong Item Delivered'},
    {'value': 'different_from_advertised', 'label': 'Different from Advertised / Counterfeit'},
    {'value': 'damaged_item', 'label': 'Damaged in Transit / Broken'},
    {'value': 'missing_component', 'label': 'Missing Component or Accessory'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedOrderNumber = widget.initialOrderNumber;
    _selectedOrderId = widget.initialOrderId;
    final initialTab = widget.initialOrderNumber != null ? 1 : 0;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReturnsProvider>().fetchReturnCases();
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitDispute() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedOrderNumber == null || _selectedOrderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an order to dispute.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final returnsProv = context.read<ReturnsProvider>();
    final success = await returnsProv.fileOrderDispute(
      orderNumber: _selectedOrderNumber!,
      reason: _selectedReason,
      customerDescription: _descriptionController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      _descriptionController.clear();
      _tabController.animateTo(0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dispute filed successfully! Case opened for arbitration.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(returnsProv.errorMessage ?? 'Failed to file return request.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final returnsProv = context.watch<ReturnsProvider>();
    final orderProv = context.watch<OrderProvider>();

    return Scaffold(
      appBar: const BrandAppBar(
        title: 'Returns & Disputes',
        showBack: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryPurple,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.secondaryGold,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Return Cases', icon: Icon(Icons.assignment_return)),
                Tab(text: 'File a Claim', icon: Icon(Icons.report_problem)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Return Cases List
                RefreshIndicator(
                  color: AppColors.primaryPurple,
                  onRefresh: () => returnsProv.fetchReturnCases(),
                  child: returnsProv.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
                      : returnsProv.cases.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.verified_user_outlined, size: 64, color: AppColors.success),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No Active Return Disputes',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'All your orders are delivered and settled safely under our 24h escrow protection guarantee.',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    CustomButton(
                                      text: 'File a Claim on an Order',
                                      onPressed: () => _tabController.animateTo(1),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: returnsProv.cases.length,
                              itemBuilder: (ctx, idx) {
                                final c = returnsProv.cases[idx];
                                return _buildCaseCard(c);
                              },
                            ),
                ),

                // Tab 2: File a Claim Form
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.shield, color: Color(0xFFD97706), size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '24-Hour Sovereign Return Guarantee: Funds remain safely locked in platform escrow until disputes are resolved.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text('SELECT DELIVERED ORDER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: orderProv.orders.any((o) => o.orderNumber == _selectedOrderNumber)
                              ? _selectedOrderNumber
                              : null,
                          hint: Text(_selectedOrderNumber != null ? 'Order $_selectedOrderNumber' : 'Select order number'),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surfaceMuted,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                          ),
                          items: orderProv.orders.map((o) {
                            return DropdownMenuItem<String>(
                              value: o.orderNumber,
                              child: Text('${o.orderNumber} • ${o.formattedTotal}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedOrderNumber = val;
                              try {
                                final ord = orderProv.orders.firstWhere((o) => o.orderNumber == val);
                                _selectedOrderId = ord.id;
                              } catch (_) {}
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text('PRIMARY REASON FOR RETURN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedReason,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surfaceMuted,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                          ),
                          items: _reasons.map((r) {
                            return DropdownMenuItem<String>(
                              value: r['value'],
                              child: Text(r['label']!),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedReason = val);
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text('DETAILED DESCRIPTION OF ISSUE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Describe the defect, damage, or discrepancy in detail...',
                            filled: true,
                            fillColor: AppColors.surfaceMuted,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().length < 10) {
                              return 'Please provide at least 10 characters describing the issue.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        CustomButton(
                          text: 'Submit Return Claim',
                          icon: Icons.send,
                          isLoading: _isSubmitting,
                          backgroundColor: AppColors.primaryPurple,
                          onPressed: _submitDispute,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard(ReturnCaseModel c) {
    Color statusColor = AppColors.primaryPurple;
    if (c.status.contains('refunded')) statusColor = AppColors.success;
    if (c.status.contains('rejected')) statusColor = AppColors.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                c.caseNumber,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primaryDarkPurple),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  c.readableStatus,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Order #${c.orderNumber ?? c.orderId} • ${c.vendorName ?? "Merchant"}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Reason: ${c.readableReason}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Refundable Amount:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(
                c.formattedRefundable,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.success),
              ),
            ],
          ),
          if (c.vendorReturnOtp != null && c.vendorReturnOtp!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vendor Return Handshake OTP:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                  ),
                  Text(
                    c.vendorReturnOtp!,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF166534), letterSpacing: 2),
                  ),
                ],
              ),
            ),
          ],
          if (c.canReorderWithWalletCredit) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.flash_on, size: 16, color: AppColors.goldAccent),
                label: const Text(
                  '⚡ 1-Click Re-Order (Instant Wallet Credit)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                ),
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryPurple),
                    ),
                  );

                  final returnsProvider = context.read<ReturnsProvider>();
                  final quote = await returnsProvider.fetchReorderQuote(c.caseNumber);

                  if (mounted) {
                    Navigator.of(context).pop(); // Dismiss loading spinner
                  }

                  if (quote != null && mounted) {
                    ReorderQuoteBottomSheet.show(context, quote: quote);
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(returnsProvider.errorMessage ?? 'Unable to prepare re-order quotation.'),
                        backgroundColor: AppColors.danger,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
