import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order_status.dart';
import '../../providers/order_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    final orderProvider = context.read<OrderProvider>();
    Future.microtask(() async {
      await orderProvider.initIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn hàng'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đang giao'),
              Tab(text: 'Đã giao'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OrdersByStatus(status: OrderStatus.pending),
            _OrdersByStatus(status: OrderStatus.delivering),
            _OrdersByStatus(status: OrderStatus.delivered),
            _OrdersByStatus(status: OrderStatus.cancelled),
          ],
        ),
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
    final currency = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );

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
