import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/return_case_model.dart';

class ReturnsProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<ReturnCaseModel> _cases = [];
  ReturnCaseModel? _activeCase;
  bool _isLoading = false;
  String? _errorMessage;

  List<ReturnCaseModel> get cases => _cases;
  ReturnCaseModel? get activeCase => _activeCase;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ReturnsProvider({required this.apiClient});

  Future<void> fetchReturnCases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.get(ApiEndpoints.returnCases);
      if (res.data['status'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        _cases = list.map((e) => ReturnCaseModel.fromJson(e)).toList();
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load return requests.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ReturnCaseModel?> fetchCaseDetails(String caseNumber) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await apiClient.get('${ApiEndpoints.returnCaseDetails}$caseNumber');
      if (res.data['status'] == true && res.data['data'] != null) {
        _activeCase = ReturnCaseModel.fromJson(res.data['data']);
        _isLoading = false;
        notifyListeners();
        return _activeCase;
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> createReturnCase({
    required int orderId,
    required String returnReason,
    String? customerDescription,
    required List<Map<String, dynamic>> items,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(ApiEndpoints.createReturnCase, data: {
        'order_id': orderId,
        'return_reason': returnReason,
        'customer_description': customerDescription,
        'items': items,
      });

      if (res.data['status'] == true) {
        await fetchReturnCases();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.data['message'] ?? 'Failed to submit return request.';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Network error while submitting return request.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> fileOrderDispute({
    required String orderNumber,
    required String reason,
    required String customerDescription,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post('${ApiEndpoints.orderDispute}$orderNumber/dispute', data: {
        'reason': reason,
        'customer_description': customerDescription,
      });

      if (res.data['status'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.data['message'] ?? 'Failed to file dispute.';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Network error while filing dispute.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<String?> reorderRejectedItems(int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(ApiEndpoints.reorderRejectedItems, data: {
        'order_id': orderId,
      });

      if (res.data['status'] == true && res.data['data'] != null) {
        final newOrderNumber = res.data['data']['order_number'] as String?;
        _isLoading = false;
        notifyListeners();
        return newOrderNumber;
      } else {
        _errorMessage = res.data['message'] ?? 'Failed to reorder replacement items.';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Network error while reordering replacement items.';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }
}
