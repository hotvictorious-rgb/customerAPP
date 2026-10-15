import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/banner_model.dart';

class BannerProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<BannerModel> _heroBanners = [];
  List<BannerModel> _promoBanners = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BannerModel> get heroBanners => _heroBanners;
  List<BannerModel> get promoBanners => _promoBanners;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BannerProvider({required this.apiClient});

  Future<void> fetchBanners() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.get(ApiEndpoints.banners);
      if (res.data['status'] == true && res.data['data'] != null) {
        final data = res.data['data'];
        
        if (data['hero_banners'] is List) {
          _heroBanners = (data['hero_banners'] as List)
              .map((e) => BannerModel.fromJson(e))
              .toList();
        }

        if (data['promo_banners'] is List) {
          _promoBanners = (data['promo_banners'] as List)
              .map((e) => BannerModel.fromJson(e))
              .toList();
        }
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Could not load storefront banners.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
