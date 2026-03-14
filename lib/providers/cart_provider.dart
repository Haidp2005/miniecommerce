import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/local_storage_service.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({required LocalStorageService storageService})
      : _storageService = storageService;

  final LocalStorageService _storageService;
  final List<CartItem> _items = [];
  bool _initialized = false;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get itemTypeCount => _items.length;
  bool get isAllSelected => _items.isNotEmpty && _items.every((item) => item.isSelected);

  List<CartItem> get selectedItems =>
      _items.where((item) => item.isSelected).toList(growable: false);

  double get selectedTotal =>
      selectedItems.fold(0, (sum, item) => sum + item.subtotal);

  Future<void> initIfNeeded() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    final persisted = await _storageService.loadCart();
    _items
      ..clear()
      ..addAll(persisted);
    notifyListeners();
  }

  Future<void> addItem({
    required Product product,
    String size = 'M',
    String color = 'Default',
    int quantity = 1,
  }) async {
    final id = _buildItemId(product.id, size, color);
    final index = _items.indexWhere((item) => item.id == id);

    if (index == -1) {
      _items.add(
        CartItem(
          id: id,
          product: product,
          size: size,
          color: color,
          quantity: quantity,
          isSelected: true,
        ),
      );
    } else {
      final existing = _items[index];
      _items[index] = existing.copyWith(quantity: existing.quantity + quantity);
    }

    await _persist();
  }

  Future<void> removeItem(String cartItemId) async {
    _items.removeWhere((item) => item.id == cartItemId);
    await _persist();
  }

  Future<void> toggleItemSelection(String cartItemId, bool isSelected) async {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index == -1) {
      return;
    }
    _items[index] = _items[index].copyWith(isSelected: isSelected);
    await _persist();
  }

  Future<void> toggleSelectAll(bool value) async {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isSelected: value);
    }
    await _persist();
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index == -1) {
      return;
    }

    if (newQuantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
    }

    await _persist();
  }

  Future<void> removeSelectedItems() async {
    _items.removeWhere((item) => item.isSelected);
    await _persist();
  }

  String _buildItemId(int productId, String size, String color) {
    return '$productId-$size-$color';
  }

  Future<void> _persist() async {
    await _storageService.saveCart(_items);
    notifyListeners();
  }
}
