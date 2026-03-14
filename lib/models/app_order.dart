import 'cart_item.dart';
import 'order_status.dart';

class AppOrder {
  final String id;
  final List<CartItem> items;
  final String address;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;

  const AppOrder({
    required this.id,
    required this.items,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((e) => e.toJson()).toList(),
      'address': address,
      'paymentMethod': paymentMethod,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppOrder.fromJson(Map<String, dynamic> json) {
    return AppOrder(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      address: json['address'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? 'COD',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? OrderStatus.pending.name),
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
