import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cashback_provider.dart';
import '../../widgets/brand_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class WalletCashbackScreen extends StatefulWidget {
  const WalletCashbackScreen({super.key});

  @override
  State<WalletCashbackScreen> createState() => _WalletCashbackScreenState();
}

class _WalletCashbackScreenState extends State<WalletCashbackScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated) {
        context.read<CashbackProvider>().fetchCashback();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cashbackProv = context.watch<CashbackProvider>();
    final cashback = cashbackProv.cashback;

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: const BrandAppBar(
          title: '5% Sovereign Cashback',
          showBack: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wallet, size: 64, color: AppColors.secondaryGold),
                const SizedBox(height: 16),
                const Text(
                  'Sign In to Access Your Wallet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Every settled purchase automatically awards 5% cashback directly into your Victorious Wallet.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Sign In to View Balance',
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
      appBar: const BrandAppBar(
        title: 'Sovereign Rewards Wallet',
        showBack: true,
      ),
      body: RefreshIndicator(
        color: AppColors.primaryPurple,
        onRefresh: () => cashbackProv.fetchCashback(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gold Sovereign Cashback Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryGoldDark.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'AVAILABLE CASHBACK',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '5% REWARD',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      cashback?.formattedAvailable ?? '₦0.00',
                      style: const TextStyle(
                        color: AppColors.primaryDarkPurple,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pending Maturation: ${cashback?.formattedPending ?? "₦0.00"}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // The 90/5/5 Mathematical Split Explainer Card
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
                    const Row(
                      children: [
                        Icon(Icons.balance, color: AppColors.primaryPurple, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'The Strict 90/5/5 Guarantee',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Victorious MARKET operates on zero float-drift mathematics evaluated via arbitrary-precision BCMath on every settled transaction:',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    _buildSplitRow('90%', 'Merchant Settlement', 'Vendor receives 90% of product revenue.'),
                    const SizedBox(height: 8),
                    _buildSplitRow('5%', 'Operating Logistics', 'Compensates professional fleet delivery.'),
                    const SizedBox(height: 8),
                    _buildSplitRow('5%', 'Customer Cashback', 'Awarded to your wallet, funded by platform.'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // How to Redeem Rules
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
                    const Text('Redemption Rules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    _buildRuleItem('Direct Checkout Discount', 'Toggle "Redeem Sovereign Cashback" at checkout to apply your rewards.'),
                    _buildRuleItem('50% Order Cap', 'You can redeem cashback up to 50% of the merchandise total per order.'),
                    _buildRuleItem('Zero Point Expiry', 'Earned sovereign rewards do not expire while your account is active.'),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitRow(String percentage, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              percentage,
              style: const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
