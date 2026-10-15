import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class DeliveryStepper extends StatelessWidget {
  final int currentStep;

  const DeliveryStepper({super.key, required this.currentStep});

  final List<Map<String, dynamic>> _steps = const [
    {'title': 'Order Confirmed', 'subtitle': 'Payment settled & order locked'},
    {'title': 'Processing', 'subtitle': 'Merchant preparing item'},
    {'title': 'Handover Ready', 'subtitle': 'Package verified at branch counter'},
    {'title': 'Out for Delivery', 'subtitle': 'Rider in transit to your doorstep'},
    {'title': 'Delivered', 'subtitle': 'OTP verified & custody transferred'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_steps.length, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;
        final step = _steps[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.success
                        : (isCurrent ? AppColors.primaryPurple : AppColors.surfaceMuted),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.success
                          : (isCurrent ? AppColors.secondaryGold : AppColors.border),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : (isCurrent
                            ? Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondaryGold,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                  ),
                ),
                if (index < _steps.length - 1)
                  Container(
                    width: 2,
                    height: 38,
                    color: isCompleted ? AppColors.success : AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title'] as String,
                      style: TextStyle(
                        color: isCurrent
                            ? AppColors.primaryPurple
                            : (isCompleted ? AppColors.textPrimary : AppColors.textSecondary),
                        fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step['subtitle'] as String,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
