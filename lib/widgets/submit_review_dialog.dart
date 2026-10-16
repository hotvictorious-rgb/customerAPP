import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/review_provider.dart';
import 'custom_button.dart';

class SubmitReviewDialog extends StatefulWidget {
  final int orderId;
  final int productId;
  final String productName;

  const SubmitReviewDialog({
    super.key,
    required this.orderId,
    required this.productId,
    required this.productName,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int orderId,
    required int productId,
    required String productName,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SubmitReviewDialog(
        orderId: orderId,
        productId: productId,
        productName: productName,
      ),
    );
  }

  @override
  State<SubmitReviewDialog> createState() => _SubmitReviewDialogState();
}

class _SubmitReviewDialogState extends State<SubmitReviewDialog> {
  int _selectedRating = 5;
  final _headlineController = TextEditingController();
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _headlineController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(Icons.rate_review, color: AppColors.primaryPurple, size: 22),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Leave Verified Buyer Review',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Text(
                widget.productName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Star Rating Selector
              const Center(
                child: Text(
                  'Tap stars to rate your purchase:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starNum = index + 1;
                  return IconButton(
                    icon: Icon(
                      starNum <= _selectedRating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFB800),
                      size: 36,
                    ),
                    onPressed: () => setState(() => _selectedRating = starNum),
                  );
                }),
              ),

              Center(
                child: Text(
                  _selectedRating == 5
                      ? '⭐⭐⭐⭐⭐ Excellent'
                      : _selectedRating == 4
                          ? '⭐⭐⭐⭐ Very Good'
                          : _selectedRating == 3
                              ? '⭐⭐⭐ Average'
                              : _selectedRating == 2
                                  ? '⭐⭐ Poor'
                                  : '⭐ Very Bad',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple, fontSize: 13),
                ),
              ),

              const SizedBox(height: 16),

              // Headline Input
              TextFormField(
                controller: _headlineController,
                decoration: InputDecoration(
                  labelText: 'Headline (e.g., Fast delivery, crisp display!)',
                  hintText: 'Summarize your experience',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.title, size: 18),
                ),
                maxLength: 100,
              ),

              const SizedBox(height: 10),

              // Detailed Comment Input
              TextFormField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Your Detailed Review *',
                  hintText: 'Describe product condition, delivery experience, packaging, and performance...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (val) {
                  if (val == null || val.trim().length < 5) {
                    return 'Please enter at least 5 characters for your review.';
                  }
                  return null;
                },
              ),

              if (reviewProvider.errorMessage != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reviewProvider.errorMessage!,
                          style: const TextStyle(color: AppColors.danger, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              CustomButton(
                text: 'Post Verified Review',
                icon: Icons.check_circle,
                isLoading: reviewProvider.isLoading,
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final success = await reviewProvider.submitReview(
                    orderId: widget.orderId,
                    productId: widget.productId,
                    rating: _selectedRating,
                    headline: _headlineController.text.trim().isEmpty ? null : _headlineController.text.trim(),
                    comment: _commentController.text.trim(),
                  );

                  if (success && mounted) {
                    Navigator.pop(context, true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Thank you! Your verified buyer review is now live.'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
