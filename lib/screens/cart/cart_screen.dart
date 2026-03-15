import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'VND ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Gio hang')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Gio hang trong'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) async {
                    await cart.removeItem(item.id);
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Da xoa ${item.product.title} khoi gio hang')),
                    );
                  },
                  child: _CartItemTile(
                    item: item,
                    onSelectionChanged: (value) async {
                      await cart.toggleItemSelection(item.id, value);
                    },
                    onIncrease: () async {
                      await cart.updateQuantity(item.id, item.quantity + 1);
                    },
                    onDecrease: () async {
                      if (item.quantity == 1) {
                        final shouldDelete = await _showDeleteConfirmDialog(context);
                        if (shouldDelete != true) {
                          return;
                        }
                        await cart.removeItem(item.id);
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Da xoa ${item.product.title} khoi gio hang')),
                        );
                        return;
                      }
                      await cart.updateQuantity(item.id, item.quantity - 1);
                    },
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
                onChanged: (value) async {
                  if (value == null) return;
                  await cart.toggleSelectAll(value);
                },
              ),
              const Text('Chon tat ca'),
              const Spacer(),
              Text(
                'Tong: ${_currencyFormatter.format(cart.selectedTotal)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: cart.hasSelectedItems
                    ? () => Navigator.pushNamed(context, AppRoutes.checkout)
                    : null,
                child: const Text('Thanh toan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xoa san pham?'),
        content: const Text('So luong dang la 1. Ban co muon xoa san pham khoi gio hang khong?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Khong'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.onSelectionChanged,
    required this.onIncrease,
    required this.onDecrease,
  });

  final CartItem item;
  final ValueChanged<bool> onSelectionChanged;
  final Future<void> Function() onIncrease;
  final Future<void> Function() onDecrease;

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'VND ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item.isSelected,
            onChanged: (value) {
              if (value == null) {
                return;
              }
              onSelectionChanged(value);
            },
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.product.image,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 72,
                  height: 72,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Phan loai: ${item.size} / ${item.color}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _currencyFormatter.format(item.product.price),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    _QtyButton(icon: Icons.remove, onPressed: onDecrease),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    _QtyButton(icon: Icons.add, onPressed: onIncrease),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onPressed});

  final IconData icon;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: OutlinedButton(
        onPressed: () async {
          await onPressed();
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
