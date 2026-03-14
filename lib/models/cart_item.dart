import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  final String size;
  final String color;
  final int quantity;
  final bool isSelected;

  const CartItem({
    required this.id,
    required this.product,
    required this.size,
    required this.color,
    required this.quantity,
    required this.isSelected,
  });

  CartItem copyWith({
    String? id,
    Product? product,
    String? size,
    String? color,
    int? quantity,
    bool? isSelected,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      size: size ?? this.size,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  double get subtotal => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'size': size,
      'color': color,
      'quantity': quantity,
      'isSelected': isSelected,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      size: json['size'] as String? ?? 'M',
      color: json['color'] as String? ?? 'Default',
      quantity: json['quantity'] as int? ?? 1,
      isSelected: json['isSelected'] as bool? ?? true,
    );
  }
}
