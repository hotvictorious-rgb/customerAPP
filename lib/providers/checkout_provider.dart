import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/checkout_intent_model.dart';
import '../models/fulfillment_model.dart';
import '../models/pickup_reservation_model.dart';
import 'cart_provider.dart';

class CheckoutProvider extends ChangeNotifier {
  final ApiClient apiClient;

  String _fulfillmentType = 'doorstep_delivery';
  bool _redeemCashback = false;
  bool _redeemWalletCredit = false;
  FulfillmentResultModel? _fulfillmentResult;
  CheckoutIntentModel? _checkoutIntent;
  PickupReservationModel? _activeReservation;
  bool _isLoading = false;
  String? _errorMessage;

  String get fulfillmentType => _fulfillmentType;
  bool get isDoorstepDelivery => _fulfillmentType == 'doorstep_delivery';
  bool get redeemCashback => _redeemCashback;
  bool get redeemWalletCredit => _redeemWalletCredit;
  FulfillmentResultModel? get fulfillmentResult => _fulfillmentResult;
  CheckoutIntentModel? get checkoutIntent => _checkoutIntent;
  PickupReservationModel? get activeReservation => _activeReservation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CheckoutProvider({required this.apiClient});

  void setFulfillmentType(String type) {
    _fulfillmentType = type;
    notifyListeners();
  }

  void toggleCashback(bool value) {
    _redeemCashback = value;
    notifyListeners();
  }

  void toggleWalletCredit(bool value) {
    _redeemWalletCredit = value;
    notifyListeners();
  }

  Future<bool> checkFulfillmentAvailability({
    required int shopId,
    int? destinationLgaId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(ApiEndpoints.fulfillmentAvailability, data: {
        'fulfillment_type': _fulfillmentType,
        'shop_id': shopId,
        if (_fulfillmentType == 'doorstep_delivery' && destinationLgaId != null)
          'destination_lga_id': destinationLgaId,
      });

      if (res.data['data'] != null) {
        _fulfillmentResult = FulfillmentResultModel.fromJson(res.data['data']);
        _isLoading = false;
        notifyListeners();
        return _fulfillmentResult!.isAvailable;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _fulfillmentResult = null;
    } catch (_) {
      _errorMessage = 'Fulfillment check failed. Please check network.';
      _fulfillmentResult = null;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<CheckoutIntentModel?> createCheckoutIntent({
    required int shopId,
    int? customerAddressId,
    required List<CartItem> items,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final itemsPayload = items.map((item) => {
        'product_id': item.product.id,
        'quantity': item.quantity,
      }).toList();

      final res = await apiClient.post(ApiEndpoints.checkoutIntent, data: {
        'fulfillment_type': _fulfillmentType,
        'shop_id': shopId,
        if (_fulfillmentType == 'doorstep_delivery')
          'customer_address_id': customerAddressId,
        'items': itemsPayload,
        'redeem_cashback': _redeemCashback,
      });

      if (res.data['status'] == true && res.data['data'] != null) {
        _checkoutIntent = CheckoutIntentModel.fromJson(res.data['data']);
        _isLoading = false;
        notifyListeners();
        return _checkoutIntent;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to generate checkout intent.';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<Map<String, dynamic>?> executeOrderAndPay({
    required int shopId,
    int? customerAddressId,
    required List<CartItem> items,
    String paymentMethod = 'paystack',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final itemsPayload = items.map((item) => {
        'product_id': item.product.id,
        'quantity': item.quantity,
      }).toList();

      final res = await apiClient.post(ApiEndpoints.checkoutExecute, data: {
        'shop_id': shopId,
        'fulfillment_type': _fulfillmentType,
        if (_fulfillmentType == 'doorstep_delivery')
          'customer_address_id': customerAddressId,
        'items': itemsPayload,
        'redeem_cashback': _redeemCashback,
        'redeem_wallet_credit': _redeemWalletCredit,
        'payment_method': paymentMethod,
      });

      if (res.data['status'] == true && res.data['data'] != null) {
        _isLoading = false;
        notifyListeners();
        return res.data['data'];
      } else {
        _errorMessage = res.data['message'] ?? 'Failed to finalize order.';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to submit order. Please check network.';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<PickupReservationModel?> createInShopReservation({
    required int shopId,
    required int productId,
    int quantity = 1,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(ApiEndpoints.createReservation, data: {
        'shop_id': shopId,
        'product_id': productId,
        'quantity': quantity,
      });

      if (res.data['status'] == true && res.data['data'] != null) {
        _activeReservation = PickupReservationModel.fromJson(res.data['data']);
        _isLoading = false;
        notifyListeners();
        return _activeReservation;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to create in-shop reservation.';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<PickupReservationModel?> lookupReservation(String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await apiClient.get('${ApiEndpoints.getReservation}${code.trim().toUpperCase()}');
      if (res.data['status'] == true && res.data['data'] != null) {
        _activeReservation = PickupReservationModel.fromJson(res.data['data']);
        _isLoading = false;
        notifyListeners();
        return _activeReservation;
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> verifyOrderPayment({
    required String orderNumber,
    required String reference,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(ApiEndpoints.verifyPayment, data: {
        'order_number': orderNumber,
        'reference': reference,
      });

      if (res.data['status'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.data['message'] ?? 'Payment verification failed.';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Payment verification could not be completed.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}

