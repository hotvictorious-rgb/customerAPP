import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_config_provider.dart';

class CallToOrderPill extends StatelessWidget {
  const CallToOrderPill({super.key});

  Future<void> _makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppConfigProvider>(
      builder: (context, config, _) {
        final phone = config.callToOrderPhone;

        return InkWell(
          onTap: () => _makePhoneCall(phone),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondaryGoldLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondaryGold, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryGold.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone_in_talk, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Call to Order: ',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  phone,
                  style: const TextStyle(
                    color: AppColors.primaryPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
