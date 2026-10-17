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
import '../legal/legal_document_screen.dart';
import '../notifications/notifications_screen.dart';
import '../orders/orders_list_screen.dart';
import '../reservations/pickup_reservation_pass_screen.dart';
import '../returns/returns_screen.dart';
import '../support/support_screen.dart';
import '../wallet/wallet_cashback_screen.dart';
import '../../providers/checkout_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  void _handleInspectionPassNavigation(BuildContext context) {
    final checkout = context.read<CheckoutProvider>();
    if (checkout.activeReservation != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PickupReservationPassScreen(reservation: checkout.activeReservation!),
        ),
      );
      return;
    }

    final codeCtrl = TextEditingController(text: 'RES-884291');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.storefront, color: AppColors.primaryPurple, size: 22),
            SizedBox(width: 8),
            Text('Inspection Pass Lookup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your 10-character reservation code to view your QR pass:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'e.g. RES-884291',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.qr_code),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final code = codeCtrl.text.trim();
              if (code.isEmpty) return;
              Navigator.pop(ctx);
              final res = await checkout.lookupReservation(code);
              if (res != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PickupReservationPassScreen(reservation: res)),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reservation not found. Please verify the code.')),
                );
              }
            },
            child: const Text('Lookup Pass'),
          ),
        ],
      ),
    );
  }

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
                    icon: Icons.notifications_active_outlined,
                    title: 'Notification Center',
                    subtitle: 'Dispatch alerts, courier updates & system notices',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
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
                    icon: Icons.storefront,
                    title: 'In-Shop Inspection Passes',
                    subtitle: 'Active 24-hr stock hold passes & QR verification',
                    onTap: () => _handleInspectionPassNavigation(context),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.assignment_return,
                    title: 'Returns & Refund Disputes',
                    subtitle: '24-hour escrow protection & return claims',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ReturnsScreen()));
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

            // Bank-Grade Legal & Governance Charter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'LEGAL & REGULATORY POLICIES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

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
                    icon: Icons.gavel_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Marketplace buyer & merchant operating rules',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalDocumentScreen(
                            slug: 'terms-of-service',
                            initialTitle: 'Terms of Service',
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy & Data Protection',
                    subtitle: 'Zero-knowledge credentials & data encryption',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalDocumentScreen(
                            slug: 'privacy-policy',
                            initialTitle: 'Privacy Policy',
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.shield_outlined,
                    title: '24-Hour Return & Escrow Policy',
                    subtitle: 'Physical inspection & automated 100% refund rules',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalDocumentScreen(
                            slug: 'return-policy',
                            initialTitle: '24-Hour Return Policy',
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Buyer Protection Charter',
                    subtitle: 'Akwa Ibom sovereign consumer guarantee',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalDocumentScreen(
                            slug: 'buyer-protection',
                            initialTitle: 'Buyer Protection Charter',
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'About Victorious MARKET',
                    subtitle: 'Our vision for Nigeria\'s trusted digital commerce',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalDocumentScreen(
                            slug: 'about-us',
                            initialTitle: 'About Victorious MARKET',
                          ),
                        ),
                      );
                    },
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
