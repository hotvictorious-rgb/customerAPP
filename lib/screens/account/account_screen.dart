import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cashback_provider.dart';
import '../../widgets/brand_app_bar.dart';
import '../address/address_list_screen.dart';
import '../auth/login_screen.dart';
import '../orders/orders_list_screen.dart';
import '../support/support_screen.dart';
import '../wallet/wallet_cashback_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _makeCall() async {
    final uri = Uri.parse('tel:${AppConstants.callToOrderPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showApiSettingsDialog(BuildContext context) {
    final storage = context.read<StorageService>();
    final controller = TextEditingController(text: storage.getBaseUrl());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('API Server Endpoint', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set the backend server URL (e.g. http://10.0.2.2:8080 or your live domain):',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'http://127.0.0.1:8080',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
            onPressed: () async {
              await storage.saveBaseUrl(controller.text.trim());
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API Server URL updated.')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cashback = context.watch<CashbackProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: const BrandAppBar(
        title: 'My Account',
        showBack: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Profile Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppColors.royalPurpleGradient,
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondaryGold, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        auth.isAuthenticated ? user!.name.substring(0, 1).toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.isAuthenticated ? user!.name : 'Welcome, Guest Shopper',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.isAuthenticated ? user!.email : 'Sign in to access your sovereign rewards',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (!auth.isAuthenticated)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryGold,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      },
                      child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Stats Card (Cashback & Orders)
            if (auth.isAuthenticated)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletCashbackScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryGoldDark.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.stars, color: AppColors.secondaryGold, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '5% CASHBACK BALANCE',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                              ),
                              Text(
                                cashback.cashback?.formattedAvailable ?? '₦0.00',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryDarkPurple),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textPrimary),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Menu Links
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.receipt_long,
                    title: 'My Orders & Live Tracking',
                    subtitle: 'Track live courier status and delivery PINs',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersListScreen()));
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet,
                    title: 'Sovereign Cashback Wallet',
                    subtitle: 'View available balance & 90/5/5 ledger',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletCashbackScreen()));
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.location_on,
                    title: 'Saved Delivery Addresses',
                    subtitle: 'Manage canonical Akwa Ibom destination addresses',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressListScreen()));
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.phone_in_talk,
                    title: 'Call to Order Line',
                    subtitle: AppConstants.callToOrderPhone,
                    onTap: _makeCall,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.support_agent,
                    title: 'Customer Care & Help Center',
                    subtitle: 'WhatsApp support and inquiries',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.settings_ethernet,
                    title: 'API Server Endpoint',
                    subtitle: 'Configure backend host URL',
                    onTap: () => _showApiSettingsDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (auth.isAuthenticated)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: AppColors.danger),
                  label: const Text('Sign Out', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.danger),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await auth.logout();
                  },
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryPurple, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
