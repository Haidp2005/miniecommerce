import 'package:flutter/foundation.dart';

import '../models/app_order.dart';
import '../models/cart_item.dart';
import '../models/order_status.dart';
import '../services/local_storage_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({required LocalStorageService storageService})
      : _storageService = storageService;

  final LocalStorageService _storageService;
  final List<AppOrder> _orders = [];
  bool _initialized = false;

  List<AppOrder> get orders => List.unmodifiable(_orders);

  Future<void> initIfNeeded() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    final persisted = await _storageService.loadOrders();
    _orders
      ..clear()
      ..addAll(persisted);
    notifyListeners();
  }

  Future<AppOrder> placeOrder({
    required List<CartItem> items,
    required String address,
    required String paymentMethod,
  }) async {
    final order = AppOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: items,
      address: address,
      paymentMethod: paymentMethod,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    _orders.insert(0, order);
    await _storageService.saveOrders(_orders);
    notifyListeners();

    return order;
  }

  List<AppOrder> byStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList(growable: false);
  }
}
