import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/reorder_quote_model.dart';
import '../models/return_case_model.dart';

class ReturnsProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<ReturnCaseModel> _cases = [];
  ReturnCaseModel? _activeCase;
  ReorderQuoteModel? _activeReorderQuote;
  bool _isLoading = false;
  String? _errorMessage;

  List<ReturnCaseModel> get cases => _cases;
  ReturnCaseModel? get activeCase => _activeCase;
  ReorderQuoteModel? get activeReorderQuote => _activeReorderQuote;
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

  void clearReorderQuote() {
    _activeReorderQuote = null;
    notifyListeners();
  }

  /// 1. Fetch Re-Order Quotation Manifest for Rejected Doorstep Items
  /// Queries backend /api/v1/customer/orders/reorder-rejected-items
  Future<ReorderQuoteModel?> fetchReorderQuote(String caseNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(ApiEndpoints.reorderRejectedItems, data: {
        'case_number': caseNumber.trim(),
      });

      if (res.data['status'] == true && res.data['data'] != null) {
        _activeReorderQuote = ReorderQuoteModel.fromJson(
          res.data['data'] as Map<String, dynamic>,
          caseNumber: caseNumber.trim(),
        );
        _isLoading = false;
        notifyListeners();
        return _activeReorderQuote;
      } else {
        _errorMessage = res.data['message']?.toString() ?? 'Failed to prepare re-order quotation.';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Network error while preparing re-order quotation.';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  /// 2. Authoritative 1-Click Execution with 100% Instant Wallet Credit Applied
  Future<Map<String, dynamic>?> executeReorderWithWallet({
    required ReorderQuoteModel quote,
    required int addressId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (quote.items.isEmpty) {
        _errorMessage = 'No valid items found in quotation manifest.';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final firstShopId = quote.items.first.shopId;
      final itemsPayload = quote.items.map((i) => {
        'product_id': i.productId,
        'quantity': i.quantity,
      }).toList();

      final res = await apiClient.post(ApiEndpoints.checkoutIntent, data: {
        'shop_id': firstShopId,
        'customer_address_id': addressId,
        'fulfillment_type': 'doorstep_delivery',
        'items': itemsPayload,
        'redeem_cashback': false,
        'redeem_wallet_credit': true,
        'payment_method': 'paystack',
      });

      if (res.data['status'] == true && res.data['data'] != null) {
        _activeReorderQuote = null;
        _isLoading = false;
        notifyListeners();
        return res.data['data'] as Map<String, dynamic>;
      } else {
        _errorMessage = res.data['message']?.toString() ?? 'Failed to execute 1-click replacement order.';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Network error while placing 1-click replacement order.';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }
}
