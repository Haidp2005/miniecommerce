import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/cart_badge_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final cartProvider = context.read<CartProvider>();
    final productProvider = context.read<ProductProvider>();
    Future.microtask(() {
      cartProvider.initIfNeeded();
      productProvider.initIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appBarTitle),
        actions: [
          CartBadgeIcon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.cart);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ProductProvider>().fetchProducts(refresh: true),
        child: Builder(
          builder: (context) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null && provider.products.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 180),
                  Center(child: Text('Loi tai du lieu: ${provider.error}')),
                  const SizedBox(height: 16),
                  Center(
                    child: FilledButton(
                      onPressed: () => context
                          .read<ProductProvider>()
                          .fetchProducts(refresh: true),
                      child: const Text('Thu lai'),
                    ),
                  ),
                ],
              );
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                final nearBottom =
                    notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200;
                if (nearBottom && provider.hasMore && !provider.isLoadingMore) {
                  context.read<ProductProvider>().fetchProducts();
                }
                return false;
              },
              child: ListView.builder(
                itemCount: provider.products.length + (provider.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= provider.products.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final product = provider.products[index];
                  return _ProductListTile(product: product);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.orders),
        icon: const Icon(Icons.receipt_long_outlined),
        label: const Text('Orders'),
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  const _ProductListTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Hero(
        tag: 'product-image-${product.id}',
        child: Image.network(
          product.image,
          width: 46,
          height: 46,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported_outlined),
        ),
      ),
      title: Text(
        product.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: product,
        );
      },
    );
  }
}
