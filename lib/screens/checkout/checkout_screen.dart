import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  String _paymentMethod = 'COD';

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Dia chi nhan hang',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Phuong thuc thanh toan'),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(value: 'COD', label: Text('COD')),
              ButtonSegment<String>(value: 'Momo', label: Text('Momo')),
            ],
            selected: <String>{_paymentMethod},
            onSelectionChanged: (selection) {
              setState(() => _paymentMethod = selection.first);
            },
          ),
          const SizedBox(height: 16),
          Text('Tong thanh toan: \$${cart.selectedTotal.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: cart.selectedItems.isEmpty ? null : _placeOrder,
            child: const Text('Dat hang'),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long nhap dia chi')),
      );
      return;
    }

    await orderProvider.placeOrder(
      items: cart.selectedItems,
      address: _addressController.text.trim(),
      paymentMethod: _paymentMethod,
    );
    await cart.removeSelectedItems();

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thanh cong'),
        content: const Text('Don hang da duoc tao.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
  }
}
