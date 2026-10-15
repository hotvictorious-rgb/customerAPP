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

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  List<ProductModel> get flagshipProducts => _flagshipProducts;
  List<ShopModel> get shops => _shops;
  ProductModel? get productDetails => _productDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CategoryModel? get selectedCategory => _selectedCategory;
  int? get selectedLgaId => _selectedLgaId;
  String get selectedCity => _selectedCity;
  String get selectedState => _selectedState;
  String get coverageStatusBadge => _coverageStatusBadge;

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
    bool refresh = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> params = {};
      if (categoryId != null) params['category_id'] = categoryId;
      if (lgaId != null) params['lga_id'] = lgaId;
      if (search != null && search.isNotEmpty) params['search'] = search;

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
    fetchProducts(
      categoryId: category?.id,
      lgaId: _selectedLgaId,
      search: _searchQuery,
    );
  }

  void selectLga(int? lgaId) {
    _selectedLgaId = lgaId;
    fetchProducts(
      categoryId: _selectedCategory?.id,
      lgaId: lgaId,
      search: _searchQuery,
    );
  }

  Future<void> fetchShops({int? lgaId}) async {
    try {
      final Map<String, dynamic> params = {};
      if (lgaId != null) params['lga_id'] = lgaId;
      final res = await apiClient.get('/api/v1/shops', queryParameters: params);
      if (res.data['status'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        _shops = list.map((e) => ShopModel.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (_) {}
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
    fetchProducts(
      categoryId: _selectedCategory?.id,
      lgaId: lgaId,
      search: _searchQuery,
    );
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    fetchProducts(
      categoryId: _selectedCategory?.id,
      lgaId: _selectedLgaId,
      search: query,
    );
  }
}
