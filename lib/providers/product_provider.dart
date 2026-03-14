import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  final List<Product> _products = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  String? _error;
  int _page = 1;
  bool _hasMore = true;

  List<Product> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> initIfNeeded() async {
    if (_products.isNotEmpty || _isLoading) {
      return;
    }
    await fetchProducts(refresh: true);
  }

  Future<void> fetchProducts({bool refresh = false}) async {
    if (_isLoading || _isLoadingMore || _isRefreshing) {
      return;
    }

    if (refresh) {
      _isRefreshing = true;
      _page = 1;
      _hasMore = true;
    } else if (_products.isEmpty) {
      _isLoading = true;
    } else {
      if (!_hasMore) {
        return;
      }
      _isLoadingMore = true;
    }

    _error = null;
    notifyListeners();

    try {
      final allProducts = await _apiService.fetchProducts();
      final start = (_page - 1) * AppConstants.pageSize;

      if (start >= allProducts.length) {
        _hasMore = false;
      } else {
        final end = (start + AppConstants.pageSize).clamp(0, allProducts.length);
        final pageItems = allProducts.sublist(start, end);

        if (refresh) {
          _products
            ..clear()
            ..addAll(pageItems);
        } else {
          _products.addAll(pageItems);
        }

        _page++;
        _hasMore = end < allProducts.length;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
