import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _size = 'M';
  String _color = 'Black';
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Hero(
            tag: 'product-image-${product.id}',
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(product.image, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 16),
          Text(product.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('\$${product.price.toStringAsFixed(2)}',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.red)),
          const SizedBox(height: 12),
          Text(product.description),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _openVariantSheet,
            icon: const Icon(Icons.tune),
            label: const Text('Chon phan loai'),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _openVariantSheet,
                  child: const Text('Them vao gio'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    _addToCart(context);
                    Navigator.pushNamed(context, AppRoutes.cart);
                  },
                  child: const Text('Mua ngay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openVariantSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('Size:'),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _size,
                        items: const ['S', 'M', 'L']
                            .map((size) => DropdownMenuItem(
                                  value: size,
                                  child: Text(size),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() => _size = value);
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Mau:'),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _color,
                        items: const ['Black', 'Blue', 'Red']
                            .map((color) => DropdownMenuItem(
                                  value: color,
                                  child: Text(color),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() => _color = value);
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('So luong:'),
                      IconButton(
                        onPressed: () {
                          if (_quantity > 1) {
                            setModalState(() => _quantity--);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$_quantity'),
                      IconButton(
                        onPressed: () => setModalState(() => _quantity++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        _addToCart(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Xac nhan'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addToCart(BuildContext context) async {
    await context.read<CartProvider>().addItem(
          product: widget.product,
          size: _size,
          color: _color,
          quantity: _quantity,
        );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Them thanh cong')),
    );
  }
}
