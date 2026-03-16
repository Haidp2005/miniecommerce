import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({required ApiService apiService}) : _apiService = apiService;

  static const List<String> _demoCategories = [
    'Flash Sale',
    'Best Sellers',
    'New Arrivals',
    'Home & Living',
    'Beauty',
    'Sports',
    'Toys',
    'Books',
    'Health',
    'Pet Supplies',
    'Office',
    'Accessories',
  ];

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
      for (final category in _demoCategories) {
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
      final allProducts = await _apiService.fetchProducts();
      final normalizedSelectedCategory = _selectedCategory?.trim().toLowerCase();
      final filteredProducts = normalizedSelectedCategory == null
          ? allProducts
          : allProducts
              .where(
                (product) => product.category.trim().toLowerCase() == normalizedSelectedCategory,
              )
              .toList();
      final start = (_page - 1) * AppConstants.pageSize;

      if (start >= filteredProducts.length) {
        _hasMore = false;
      } else {
        final end = (start + AppConstants.pageSize).clamp(0, filteredProducts.length);
        final pageItems = filteredProducts.sublist(start, end);

        if (refresh) {
          _products
            ..clear()
            ..addAll(pageItems);
        } else {
          _products.addAll(pageItems);
        }

        _page++;
        _hasMore = end < filteredProducts.length;
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
