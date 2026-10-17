import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<ReviewModel> _productReviews = [];
  List<ReviewModel> _myReviews = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _averageRating = 0.0;
  int _reviewsCount = 0;

  List<ReviewModel> get productReviews => _productReviews;
  List<ReviewModel> get myReviews => _myReviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get averageRating => _averageRating;
  int get reviewsCount => _reviewsCount;

  ReviewProvider({required this.apiClient});

  /// Fetch public verified reviews for a specific product
  Future<void> fetchProductReviews(int productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.get('${ApiEndpoints.productReviews}$productId/reviews');
      if (res.data['success'] == true && res.data['data'] != null) {
        final data = res.data['data'];
        _averageRating = (data['average_rating'] as num?)?.toDouble() ?? 0.0;
        _reviewsCount = data['reviews_count'] as int? ?? 0;

        final rawReviews = data['reviews'];
        if (rawReviews != null && rawReviews['data'] is List) {
          final list = rawReviews['data'] as List;
          _productReviews = list.map((e) => ReviewModel.fromJson(e)).toList();
        } else if (rawReviews is List) {
          _productReviews = rawReviews.map((e) => ReviewModel.fromJson(e)).toList();
        } else {
          _productReviews = [];
        }
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load product reviews.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Submit a verified review for a delivered purchase
  Future<bool> submitReview({
    required int orderId,
    String? orderNumber,
    required int productId,
    required int rating,
    String? headline,
    required String comment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(
        ApiEndpoints.submitReview,
        data: {
          'order_id': orderId,
          if (orderNumber != null && orderNumber.isNotEmpty) 'order_number': orderNumber,
          'product_id': productId,
          'rating': rating,
          'headline': headline,
          'comment': comment,
        },
      );

      if (res.data['success'] == true) {
        // Refresh product reviews if currently viewing this product
        await fetchProductReviews(productId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res.data['message']?.toString() ?? 'Failed to submit review.';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'An error occurred while submitting your review.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Fetch reviews written by authenticated customer
  Future<void> fetchMyReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.get(ApiEndpoints.myReviews);
      if (res.data['success'] == true && res.data['data'] != null) {
        final rawData = res.data['data'];
        if (rawData['data'] is List) {
          final list = rawData['data'] as List;
          _myReviews = list.map((e) => ReviewModel.fromJson(e)).toList();
        } else if (rawData is List) {
          _myReviews = rawData.map((e) => ReviewModel.fromJson(e)).toList();
        }
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load your reviews.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
