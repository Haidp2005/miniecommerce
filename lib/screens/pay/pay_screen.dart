import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

enum _PaymentMethod { cod, momo }

class PayScreen extends StatefulWidget {
  const PayScreen({super.key});

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  final TextEditingController _addressController = TextEditingController();
  _PaymentMethod _paymentMethod = _PaymentMethod.cod;

  @override
  void initState() {
    super.initState();
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    Future.microtask(() async {
      await cartProvider.initIfNeeded();
      await orderProvider.initIfNeeded();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  String get _paymentLabel {
    switch (_paymentMethod) {
      case _PaymentMethod.cod:
        return 'COD';
      case _PaymentMethod.momo:
        return 'Momo';
    }
  }

  Future<void> _placeOrder() async {
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final selectedItems = cartProvider.selectedItems;

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ nhận hàng.')),
      );
      return;
    }

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 sản phẩm.')),
      );
      return;
    }

    await orderProvider.placeOrder(
      items: selectedItems,
      address: _addressController.text.trim(),
      paymentMethod: _paymentLabel,
    );

    await cartProvider.removeSelectedItems();

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đặt hàng thành công'),
        content: const Text('Đơn hàng của bạn đã được tạo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = context.watch<CartProvider>();
    final selectedItems = cartProvider.selectedItems;
    final total = cartProvider.selectedTotal;
    final currency = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Địa chỉ nhận hàng',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            hintText: 'Nhập địa chỉ nhận hàng',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phương thức thanh toán',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<_PaymentMethod>(
                          segments: const [
                            ButtonSegment<_PaymentMethod>(
                              value: _PaymentMethod.cod,
                              label: Text('COD'),
                            ),
                            ButtonSegment<_PaymentMethod>(
                              value: _PaymentMethod.momo,
                              label: Text('Momo'),
                            ),
                          ],
                          selected: <_PaymentMethod>{_paymentMethod},
                          onSelectionChanged: (selection) {
                            setState(() {
                              _paymentMethod = selection.first;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sản phẩm đã chọn',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (selectedItems.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('Chưa có sản phẩm được chọn.'),
                          )
                        else
                          ...selectedItems.map(
                            (item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.product.title),
                              subtitle: Text(
                                'SL: ${item.quantity} • ${item.size} • ${item.color}',
                              ),
                              trailing: Text(
                                currency.format(item.subtotal),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tổng: ${currency.format(total)}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  FilledButton(
                    onPressed: selectedItems.isEmpty ? null : _placeOrder,
                    child: const Text('Đặt hàng'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
