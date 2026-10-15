import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/customer_address_model.dart';
import '../models/geography_models.dart';

class AddressProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<CustomerAddressModel> _addresses = [];
  List<CountryModel> _countries = [];
  List<StateModel> _states = [];
  List<LgaModel> _lgas = [];

  CustomerAddressModel? _selectedAddress;
  bool _isLoading = false;
  String? _errorMessage;

  List<CustomerAddressModel> get addresses => _addresses;
  List<CountryModel> get countries => _countries;
  List<StateModel> get states => _states;
  List<LgaModel> get lgas => _lgas;
  CustomerAddressModel? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AddressProvider({required this.apiClient});

  Future<void> fetchAddresses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await apiClient.get(ApiEndpoints.addressList);
      if (res.data['status'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        _addresses = list.map((e) => CustomerAddressModel.fromJson(e)).toList();

        if (_addresses.isNotEmpty) {
          // Select default or first
          _selectedAddress = _addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => _addresses.first,
          );
        }
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCountries() async {
    try {
      final res = await apiClient.get(ApiEndpoints.countries);
      if (res.data['status'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        _countries = list.map((e) => CountryModel.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchStates(int countryId) async {
    try {
      final res = await apiClient.get('${ApiEndpoints.states}$countryId');
      if (res.data['status'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        _states = list.map((e) => StateModel.fromJson(e)).toList();
        _lgas = [];
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> fetchLgas(int stateId) async {
    try {
      final res = await apiClient.get('${ApiEndpoints.lgas}$stateId');
      if (res.data['status'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        _lgas = list.map((e) => LgaModel.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> addAddress({
    required String contactName,
    required String phone,
    required String addressLine,
    String? landmark,
    required int countryId,
    required int stateId,
    required int lgaId,
    bool isDefault = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(ApiEndpoints.addressAdd, data: {
        'contact_name': contactName.trim(),
        'phone': phone.trim(),
        'address_line': addressLine.trim(),
        'landmark': landmark?.trim(),
        'country_id': countryId,
        'state_id': stateId,
        'lga_id': lgaId,
        'is_default': isDefault,
      });

      if (res.data['status'] == true && res.data['data'] != null) {
        final newAddr = CustomerAddressModel.fromJson(res.data['data']);
        _addresses.insert(0, newAddr);
        _selectedAddress = newAddr;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to save address.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void selectAddress(CustomerAddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }
}
