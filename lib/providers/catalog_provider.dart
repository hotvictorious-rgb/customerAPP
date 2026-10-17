import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/shop_model.dart';

class CatalogProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  List<ProductModel> _flagshipProducts = [];
  List<ProductModel> _shopProducts = [];
  List<ShopModel> _shops = [];
  ProductModel? _productDetails;
  bool _isLoading = false;
  String? _errorMessage;

  CategoryModel? _selectedCategory;
  int? _selectedLgaId = 69;
  String _selectedCity = 'Uyo';
  String _selectedState = 'Akwa Ibom';
  String _coverageStatusBadge = '⚡ In-Shop Pickup & Same-Day Active';
  String _searchQuery = '';

  // Multi-Facet Filters
  String? _selectedCondition; // 'brand_new', 'uk_used'
  bool _flagshipOnly = false;
  String? _selectedPackageTier; // 'bike', 'keke'

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  List<ProductModel> get flagshipProducts => _flagshipProducts;
  List<ProductModel> get shopProducts => _shopProducts;
  List<ShopModel> get shops => _shops;
  ProductModel? get productDetails => _productDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CategoryModel? get selectedCategory => _selectedCategory;
  int? get selectedLgaId => _selectedLgaId;
  String get selectedCity => _selectedCity;
  String get selectedState => _selectedState;
  String get coverageStatusBadge => _coverageStatusBadge;
  String get searchQuery => _searchQuery;

  String? get selectedCondition => _selectedCondition;
  bool get flagshipOnly => _flagshipOnly;
  String? get selectedPackageTier => _selectedPackageTier;

  CatalogProvider({required this.apiClient});

  Future<void> fetchCategories() async {
    try {
      final res = await apiClient.get(ApiEndpoints.categories);
      if (res.data['status'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        _categories = list.map((e) => CategoryModel.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchProducts({
    int? categoryId,
    int? lgaId,
    String? search,
    String? condition,
    bool? flagshipOnly,
    String? packageTier,
    bool refresh = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> params = {};
      final catId = categoryId ?? _selectedCategory?.id;
      if (catId != null) params['category_id'] = catId;

      final locLga = lgaId ?? _selectedLgaId;
      if (locLga != null) params['lga_id'] = locLga;

      final s = search ?? _searchQuery;
      if (s.isNotEmpty) params['search'] = s;

      final cond = condition ?? _selectedCondition;
      if (cond != null && cond.isNotEmpty) params['condition'] = cond;

      final flag = flagshipOnly ?? _flagshipOnly;
      if (flag) params['flagship_only'] = 1;

      final tier = packageTier ?? _selectedPackageTier;
      if (tier != null && tier.isNotEmpty) params['package_tier'] = tier;

      final res = await apiClient.get(ApiEndpoints.products, queryParameters: params);
      if (res.data['status'] == true && res.data['data'] != null) {
        final dataWrapper = res.data['data'];
        final list = (dataWrapper is Map && dataWrapper['data'] != null)
            ? dataWrapper['data'] as List
            : (dataWrapper is List ? dataWrapper : []);

        _products = list.map((e) => ProductModel.fromJson(e)).toList();
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load products.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFlagshipProducts() async {
    try {
      final res = await apiClient.get(ApiEndpoints.products, queryParameters: {'flagship_only': 1});
      if (res.data['status'] == true && res.data['data'] != null) {
        final dataWrapper = res.data['data'];
        final list = (dataWrapper is Map && dataWrapper['data'] != null)
            ? dataWrapper['data'] as List
            : (dataWrapper is List ? dataWrapper : []);

        _flagshipProducts = list.map((e) => ProductModel.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<ProductModel?> fetchProductDetails(int id) async {
    _isLoading = true;
    _productDetails = null;
    notifyListeners();

    try {
      final res = await apiClient.get('${ApiEndpoints.productDetails}$id');
      if (res.data['status'] == true && res.data['data'] != null) {
        _productDetails = ProductModel.fromJson(res.data['data']);
        _isLoading = false;
        notifyListeners();
        return _productDetails;
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
    return null;
  }

  void selectCategory(CategoryModel? category) {
    _selectedCategory = category;
    fetchProducts();
  }

  void setCondition(String? condition) {
    if (_selectedCondition == condition) {
      _selectedCondition = null; // Toggle off
    } else {
      _selectedCondition = condition;
    }
    fetchProducts();
  }

  void toggleFlagship() {
    _flagshipOnly = !_flagshipOnly;
    fetchProducts();
  }

  void setPackageTier(String? tier) {
    if (_selectedPackageTier == tier) {
      _selectedPackageTier = null; // Toggle off
    } else {
      _selectedPackageTier = tier;
    }
    fetchProducts();
  }

  void resetAllFilters() {
    _selectedCategory = null;
    _selectedCondition = null;
    _flagshipOnly = false;
    _selectedPackageTier = null;
    _searchQuery = '';
    fetchProducts();
  }

  void selectLga(int? lgaId) {
    _selectedLgaId = lgaId;
    fetchProducts();
  }

  Future<void> fetchShops({int? lgaId}) async {
    try {
      final Map<String, dynamic> params = {};
      if (lgaId != null) params['lga_id'] = lgaId;
      final res = await apiClient.get(ApiEndpoints.shops, queryParameters: params);
      if (res.data['status'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        _shops = list.map((e) => ShopModel.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchProductsByShop(int shopId) async {
    _isLoading = true;
    _shopProducts = [];
    notifyListeners();

    try {
      final res = await apiClient.get(ApiEndpoints.products, queryParameters: {'shop_id': shopId});
      if (res.data['status'] == true && res.data['data'] != null) {
        final dataWrapper = res.data['data'];
        final list = (dataWrapper is Map && dataWrapper['data'] != null)
            ? dataWrapper['data'] as List
            : (dataWrapper is List ? dataWrapper : []);

        _shopProducts = list.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  void setLocation({
    required String city,
    required String state,
    required int lgaId,
    String? badge,
  }) {
    _selectedCity = city;
    _selectedState = state;
    _selectedLgaId = lgaId;
    if (badge != null) _coverageStatusBadge = badge;
    fetchShops(lgaId: lgaId);
    fetchProducts();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    fetchProducts();
  }
}
