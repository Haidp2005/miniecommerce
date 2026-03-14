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
    Future.microtask(() {
      orderProvider.initIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order History'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Cho xac nhan'),
              Tab(text: 'Dang giao'),
              Tab(text: 'Da giao'),
              Tab(text: 'Da huy'),
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
    final provider = context.watch<OrderProvider>();
    final orders = provider.byStatus(status);

    if (orders.isEmpty) {
      return const Center(child: Text('Khong co don hang'));
    }

    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return ListView.separated(
      itemBuilder: (context, index) {
        final order = orders[index];
        return ListTile(
          title: Text('Don #${order.id}'),
          subtitle: Text('${order.items.length} san pham - ${order.paymentMethod}'),
          trailing: Text(currencyFormat.format(order.total)),
        );
      },
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemCount: orders.length,
    );
  }
}
