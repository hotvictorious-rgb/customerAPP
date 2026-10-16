import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final StorageService storageService;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider({required this.apiClient, required this.storageService});

  Future<void> checkAuthStatus() async {
    final token = await storageService.getToken();
    final cachedUser = storageService.getUser();
    if (token != null && cachedUser != null) {
      _user = cachedUser;
      notifyListeners();

      // Refresh from server
      try {
        final res = await apiClient.get(ApiEndpoints.me);
        if (res.data['status'] == true && res.data['data'] != null) {
          _user = UserModel.fromJson(res.data['data']);
          await storageService.saveUser(_user!);
          notifyListeners();
        }
      } catch (_) {
        // Silently keep cached session if offline
      }
    }
  }

  Future<bool> login(String login, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(ApiEndpoints.login, data: {
        'login': login.trim(),
        'password': password,
      });

      if (res.data['status'] == true) {
        final token = res.data['token'] as String;
        final userData = UserModel.fromJson(res.data['user']);

        // ZERO-KNOWLEDGE CUSTOMER ROLE INVARIANT:
        if (userData.userType != 'customer') {
          await storageService.clearAll();
          _errorMessage = 'Invalid credentials or unauthorized account.';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        await storageService.saveToken(token);
        await storageService.saveUser(userData);
        _user = userData;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid credentials or unauthorized account.';
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        _errorMessage = 'Invalid credentials or unauthorized account.';
      } else {
        _errorMessage = e.message;
      }
    } catch (_) {
      _errorMessage = 'Unable to connect to service. Please check network connection.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(ApiEndpoints.register, data: {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
        'user_type': 'customer',
      });

      if (res.data['status'] == true) {
        final token = res.data['token'] as String;
        final userData = UserModel.fromJson(res.data['user']);
        await storageService.saveToken(token);
        await storageService.saveUser(userData);
        _user = userData;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.data['message'] ?? 'Registration failed.';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during registration.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await storageService.clearAll();
    _user = null;
    notifyListeners();
  }
}
