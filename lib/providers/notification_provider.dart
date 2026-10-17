import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/services/firebase_notification_service.dart';
import '../models/system_notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<SystemNotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<SystemNotificationModel>? _streamSub;

  List<SystemNotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider({required this.apiClient}) {
    _streamSub = FirebaseNotificationService.instance.onNotificationReceived.listen((notif) {
      _notifications.insert(0, notif);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }

  /// Fetch in-app notifications from backend matrix
  Future<void> fetchNotifications({bool refresh = false}) async {
    if (!refresh && _notifications.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.get(ApiEndpoints.inAppNotifications);
      if (res.data['status'] == true && res.data['data'] != null) {
        final raw = res.data['data'];
        final list = (raw is Map && raw['data'] is List)
            ? raw['data'] as List
            : (raw is List ? raw : []);

        _notifications = list.map((item) => SystemNotificationModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _errorMessage = 'Unable to synchronize notifications.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Mark single notification as read
  Future<bool> markAsRead(String id) async {
    try {
      await apiClient.post('${ApiEndpoints.markNotificationRead}$id');

      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final old = _notifications[index];
        _notifications[index] = SystemNotificationModel(
          id: old.id,
          userId: old.userId,
          title: old.title,
          body: old.body,
          type: old.type,
          data: old.data,
          actionUrl: old.actionUrl,
          readAt: DateTime.now(),
          createdAt: old.createdAt,
        );
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      await apiClient.post(ApiEndpoints.markNotificationRead.replaceAll(RegExp(r'/$'), ''));

      _notifications = _notifications.map((n) {
        if (n.isRead) return n;
        return SystemNotificationModel(
          id: n.id,
          userId: n.userId,
          title: n.title,
          body: n.body,
          type: n.type,
          data: n.data,
          actionUrl: n.actionUrl,
          readAt: DateTime.now(),
          createdAt: n.createdAt,
        );
      }).toList();

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
