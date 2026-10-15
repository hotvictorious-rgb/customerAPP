import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<OrderModel> _orders = [];
  OrderModel? _activeOrder;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _pollingTimer;

  List<OrderModel> get orders => _orders;
  OrderModel? get activeOrder => _activeOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  OrderProvider({required this.apiClient});

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.get(ApiEndpoints.customerOrders);
      if (res.data['status'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        _orders = list.map((e) => OrderModel.fromJson(e)).toList();
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load order history.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<OrderModel?> fetchOrderDetails(String orderNumber) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await apiClient.get('${ApiEndpoints.customerOrderDetails}$orderNumber');
      if (res.data['status'] == true && res.data['data'] != null) {
        _activeOrder = OrderModel.fromJson(res.data['data']);
        _isLoading = false;
        notifyListeners();
        return _activeOrder;
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> confirmDelivery(String orderNumber, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(
        '${ApiEndpoints.customerOrderDetails}$orderNumber/confirm-delivery',
        data: {'delivery_otp': otp},
      );

      if (res.data['status'] == true) {
        await fetchOrderDetails(orderNumber);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.data['message'] ?? 'OTP verification failed.';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to submit delivery confirmation.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void startLiveTracking(String orderNumber) {
    stopLiveTracking();
    fetchOrderDetails(orderNumber);
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchOrderDetails(orderNumber);
    });
  }

  void stopLiveTracking() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    stopLiveTracking();
    super.dispose();
  }
}
