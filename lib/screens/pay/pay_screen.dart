import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../models/order_status.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

enum _PaymentMethod { cod, momo }

class PayScreen extends StatefulWidget {
  const PayScreen({super.key, this.initialTab = 0});

  final int initialTab;

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
    final currency = NumberFormat.currency(symbol: '₫', decimalDigits: 0);

    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thanh toán'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Checkout'),
              Tab(text: 'Đơn hàng'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
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
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
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
            const _OrderHistorySection(),
          ],
        ),
      ),
    );
  }
}

class _OrderHistorySection extends StatelessWidget {
  const _OrderHistorySection();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đang giao'),
              Tab(text: 'Đã giao'),
              Tab(text: 'Đã hủy'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _OrdersByStatus(status: OrderStatus.pending),
                _OrdersByStatus(status: OrderStatus.delivering),
                _OrdersByStatus(status: OrderStatus.delivered),
                _OrdersByStatus(status: OrderStatus.cancelled),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersByStatus extends StatelessWidget {
  const _OrdersByStatus({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<OrderProvider>();
    final orders = provider.byStatus(status);
    final currency = NumberFormat.currency(symbol: '₫', decimalDigits: 0);

    if (orders.isEmpty) {
      return const Center(child: Text('Không có đơn hàng'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đơn #${order.id}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Địa chỉ: ${order.address}'),
                Text('Thanh toán: ${order.paymentMethod}'),
                Text('Số sản phẩm: ${order.items.length}'),
                Text(
                  'Tổng: ${currency.format(order.total)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: orders.length,
    );
  }
}
