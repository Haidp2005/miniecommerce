import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  final List<Product> _products = [];
  final List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  String? _error;
  int _page = 1;
  bool _hasMore = true;

  List<Product> get products => List.unmodifiable(_products);
  List<String> get categories => List.unmodifiable(_categories);
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> initIfNeeded() async {
    if (_products.isNotEmpty || _isLoading) {
      return;
    }
    await Future.wait([
      fetchCategories(),
      fetchProducts(refresh: true),
    ]);
  }

  Future<void> fetchCategories() async {
    try {
      final cats = await _apiService.fetchCategories();
      final mergedCategories = <String>[];
      final seen = <String>{};

      void addCategory(String category) {
        final normalized = category.trim();
        if (normalized.isEmpty) {
          return;
        }
        final key = normalized.toLowerCase();
        if (seen.add(key)) {
          mergedCategories.add(normalized);
        }
      }

      for (final category in cats) {
        addCategory(category);
      }

      _categories.clear();
      _categories.addAll(['All', ...mergedCategories]);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  void selectCategory(String? category) {
    if (_selectedCategory == category) return;
    _selectedCategory = (category == 'All') ? null : category;
    fetchProducts(refresh: true);
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
      final response = await _apiService.fetchProducts(
        page: _page,
        limit: AppConstants.pageSize,
        category: _selectedCategory,
      );

      if (refresh) {
        _products
          ..clear()
          ..addAll(response.products);
      } else {
        _products.addAll(response.products);
      }

      _page++;
      _hasMore = response.hasMore && response.products.isNotEmpty;
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
