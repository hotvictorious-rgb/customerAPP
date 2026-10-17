import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';

class SystemNotificationModel {
  final String id;
  final int? userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  final DateTime? readAt;
  final DateTime? createdAt;

  SystemNotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.actionUrl,
    this.readAt,
    this.createdAt,
  });

  bool get isRead => readAt != null;

  factory SystemNotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    return SystemNotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? ''),
      title: json['title']?.toString() ?? 'Market Alert',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null,
      actionUrl: json['action_url']?.toString(),
      readAt: parseDate(json['read_at']),
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  String get timeAgo {
    if (createdAt == null) return 'Recent';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, h:mm a').format(createdAt!);
  }

  IconData get iconData {
    final t = type.toLowerCase();
    if (t.contains('delivery') || t.contains('dispatch') || t.contains('rider') || t.contains('courier')) {
      return Icons.local_shipping_outlined;
    }
    if (t.contains('arrived') || t.contains('doorstep')) {
      return Icons.doorbell_outlined;
    }
    if (t.contains('order') || t.contains('purchase') || t.contains('package')) {
      return Icons.shopping_bag_outlined;
    }
    if (t.contains('reservation') || t.contains('pickup')) {
      return Icons.storefront_outlined;
    }
    if (t.contains('cashback') || t.contains('wallet') || t.contains('refund') || t.contains('payout')) {
      return Icons.account_balance_wallet_outlined;
    }
    if (t.contains('dispute') || t.contains('return') || t.contains('claim')) {
      return Icons.assignment_return_outlined;
    }
    if (t.contains('fail') || t.contains('alert') || t.contains('warning') || t.contains('reject')) {
      return Icons.warning_amber_rounded;
    }
    return Icons.notifications_active_outlined;
  }

  Color get accentColor {
    final t = type.toLowerCase();
    if (t.contains('fail') || t.contains('reject') || t.contains('warning')) {
      return AppColors.danger;
    }
    if (t.contains('cashback') || t.contains('wallet') || t.contains('refund') || t.contains('success')) {
      return AppColors.success;
    }
    if (t.contains('arrived') || t.contains('doorstep') || t.contains('reservation')) {
      return AppColors.secondaryGoldDark;
    }
    return AppColors.primaryPurple;
  }

  Color get backgroundColor {
    final t = type.toLowerCase();
    if (t.contains('fail') || t.contains('reject') || t.contains('warning')) {
      return AppColors.dangerLight;
    }
    if (t.contains('cashback') || t.contains('wallet') || t.contains('refund') || t.contains('success')) {
      return AppColors.successLight;
    }
    if (t.contains('arrived') || t.contains('doorstep') || t.contains('reservation')) {
      return AppColors.secondaryGoldLight;
    }
    return AppColors.surfaceMuted;
  }
}
