import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/app_config_model.dart';
import '../models/geography_models.dart';
import '../models/legal_document_model.dart';

class AppConfigProvider extends ChangeNotifier {
  final ApiClient apiClient;

  AppConfigModel? _config;
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, LegalDocumentModel> _cachedLegalDocs = {};

  AppConfigModel? get config => _config;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, LegalDocumentModel> get cachedLegalDocs => _cachedLegalDocs;

  // Safe Dynamic Getters (With production-grade offline fallbacks)
  String get appName => _config?.appName ?? 'Victorious MARKET';
  String get appSlogan => _config?.appSlogan ?? 'Akwa Ibom Sovereign Marketplace';
  String get supportPhone => _config?.supportPhone ?? '09118949035';
  String get supportEmail => _config?.supportEmail ?? 'support@victoriousmarket.com.ng';
  String get callToOrderPhone => _config?.callToOrderPhone ?? '+2349118949035';
  String get currencySymbol => _config?.currencySymbol ?? '₦';
  String get currencyCode => _config?.currencyCode ?? 'NGN';
  double get cashbackPercentage => _config?.cashbackPercentage ?? 5.0;

  List<LgaModel> get activeCorridors => _config?.activeCorridors ?? [
    LgaModel(id: 69, stateId: 1, name: 'Uyo'),
    LgaModel(id: 70, stateId: 1, name: 'Eket'),
    LgaModel(id: 71, stateId: 1, name: 'Ikot Ekpene'),
    LgaModel(id: 72, stateId: 1, name: 'Oron'),
  ];

  bool get isMaintenance => _config?.maintenanceMode.isActive ?? false;
  String? get maintenanceMessage => _config?.maintenanceMode.message;
  bool get forceUpdate => _config?.versionControl.forceUpdate ?? false;
  String get updateUrl => _config?.versionControl.updateUrl ?? 'https://shop.victoriousmarket.com.ng/download';

  AppConfigProvider({required this.apiClient});

  Future<void> fetchConfig() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.get(ApiEndpoints.appConfig);
      if (res.data['status'] == true && res.data['data'] != null) {
        _config = AppConfigModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      _errorMessage = 'Failed to load remote configuration.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch legal & compliance policy by slug
  Future<LegalDocumentModel?> fetchLegalDocument(String slug) async {
    try {
      final res = await apiClient.get('${ApiEndpoints.legalDocumentSlug}$slug');
      if (res.data['success'] == true && res.data['data'] != null) {
        final doc = LegalDocumentModel.fromJson(res.data['data'] as Map<String, dynamic>);
        _cachedLegalDocs[slug] = doc;
        notifyListeners();
        return doc;
      }
    } catch (_) {}
    return null;
  }
}
