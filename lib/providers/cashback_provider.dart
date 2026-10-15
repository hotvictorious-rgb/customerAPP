import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/cashback_model.dart';

class CashbackProvider extends ChangeNotifier {
  final ApiClient apiClient;

  CashbackModel? _cashback;
  bool _isLoading = false;

  CashbackModel? get cashback => _cashback;
  bool get isLoading => _isLoading;

  CashbackProvider({required this.apiClient});

  Future<void> fetchCashback() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await apiClient.get(ApiEndpoints.cashbackBalance);
      if (res.data['status'] == true && res.data['data'] != null) {
        _cashback = CashbackModel.fromJson(res.data['data']);
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }
}
