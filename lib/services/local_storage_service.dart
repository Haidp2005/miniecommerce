import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_order.dart';
import '../models/cart_item.dart';

class LocalStorageService {
  static const String _cartKey = 'cart_items';
  static const String _ordersKey = 'orders';

  Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_cartKey, raw);
  }

  Future<List<CartItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartKey);

    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveOrders(List<AppOrder> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(orders.map((e) => e.toJson()).toList());
    await prefs.setString(_ordersKey, raw);
  }

  Future<List<AppOrder>> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ordersKey);

    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => AppOrder.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
