import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/brand_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../legal/legal_document_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _makeCall() async {
    final uri = Uri.parse('tel:${AppConstants.callToOrderPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/2349118949035?text=Hello%20Victorious%20MARKET,%20I%20need%20support');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmail() async {
    final uri = Uri.parse('mailto:${AppConstants.supportEmail}?subject=Support%20Inquiry');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandAppBar(
        title: 'Customer Support & Help',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.royalPurpleGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.purpleShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'We are here for you 24/7',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Reach our verified customer desk directly for order questions, directional delivery inquiries, or reservation passes.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text('Call Us'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryGold,
                            foregroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _makeCall,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.chat, size: 16),
                          label: const Text('WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primaryPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _openWhatsApp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            _buildFaqTile(
              'How does the 5% Sovereign Cashback work?',
              'Victorious MARKET awards 5% cashback on the merchandise subtotal of every settled order. It is funded by the platform and stored in your digital wallet. You can redeem it as a direct discount (up to 50% of merchandise) on future orders.',
            ),
            _buildFaqTile(
              'What is "In-Shop Inspection" (₦0.00 Paid Upfront)?',
              'The Akwa Ibom Trust Model allows you to reserve products for 24 hours without paying any money upfront. You visit the verified merchant branch, physically inspect the item, and only pay digitally when completely satisfied.',
            ),
            _buildFaqTile(
              'When should I disclose my 6-Digit Delivery PIN?',
              'Disclose your secret 6-digit PIN to the delivery rider ONLY AFTER you have physically received and inspected the package at your doorstep. Once the rider submits your PIN, custody is officially finalized.',
            ),
            _buildFaqTile(
              'How are delivery fees calculated?',
              'Delivery fees are determined strictly by the backend directional lane engine based on the merchant shop\'s LGA and your destination LGA (e.g. Uyo -> Eket). Neither the app nor couriers can alter these authoritative rates.',
            ),

            const SizedBox(height: 24),

            const Text(
              'Platform Governance & Policies',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.shield_outlined, color: AppColors.primaryPurple),
                    title: const Text('24-Hour Return & Refund Charter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Step-by-step physical inspection and refund rights', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.verified_user_outlined, color: AppColors.primaryPurple),
                    title: const Text('Buyer Protection Guarantee', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Escrow security and doorstep rejection safety', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.gavel_outlined, color: AppColors.primaryPurple),
                    title: const Text('Terms of Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Official platform agreements and dispute resolution', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
