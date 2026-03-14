import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Gio hang trong'))
          : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => cart.removeItem(item.id),
                  child: CheckboxListTile(
                    value: item.isSelected,
                    onChanged: (value) {
                      if (value == null) return;
                      cart.toggleItemSelection(item.id, value);
                    },
                    title: Text(item.product.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${item.size} / ${item.color} - \$${item.product.price.toStringAsFixed(2)}'),
                    secondary: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => cart.updateQuantity(item.id, item.quantity - 1),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          onPressed: () => cart.updateQuantity(item.id, item.quantity + 1),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFDDDDDD))),
          ),
          child: Row(
            children: [
              Checkbox(
                value: cart.isAllSelected,
                onChanged: (value) {
                  if (value == null) return;
                  cart.toggleSelectAll(value);
                },
              ),
              const Text('Chon tat ca'),
              const Spacer(),
              Text('Tong: \$${cart.selectedTotal.toStringAsFixed(2)}'),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: cart.selectedItems.isEmpty
                    ? null
                    : () => Navigator.pushNamed(context, AppRoutes.checkout),
                child: const Text('Thanh toan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
