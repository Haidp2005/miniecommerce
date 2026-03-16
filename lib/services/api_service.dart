import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class PaginatedProductsResponse {
  const PaginatedProductsResponse({
    required this.products,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<Product> products;
  final int total;
  final int page;
  final int limit;

  bool get hasMore => page * limit < total;
}

class ApiService {
  static const String _productsBaseUrl = 'https://dummyjson.com';

  Future<PaginatedProductsResponse> fetchProducts({
    required int page,
    required int limit,
    String? category,
  }) async {
    final normalizedCategory = category?.trim();
    final skip = (page - 1) * limit;

    final path = (normalizedCategory == null || normalizedCategory.isEmpty)
        ? '/products'
        : '/products/category/${Uri.encodeComponent(normalizedCategory)}';

    final uri = Uri.parse('$_productsBaseUrl$path').replace(
      queryParameters: {
        'limit': '$limit',
        'skip': '$skip',
      },
    );
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load products: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final productList = (decoded['products'] as List<dynamic>? ?? const [])
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    return PaginatedProductsResponse(
      products: productList,
      total: (decoded['total'] as num?)?.toInt() ?? productList.length,
      page: page,
      limit: (decoded['limit'] as num?)?.toInt() ?? limit,
    );
  }

  Future<List<String>> fetchCategories() async {
    final uri = Uri.parse('$_productsBaseUrl/products/category-list');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded.map((e) => e.toString()).toList();
  }
}
