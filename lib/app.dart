import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'services/api_service.dart';
import 'services/local_storage_service.dart';

class MiniEcommerceApp extends StatelessWidget {
  const MiniEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<LocalStorageService>(create: (_) => LocalStorageService()),
        ChangeNotifierProxyProvider2<ApiService, LocalStorageService, ProductProvider>(
          create: (context) => ProductProvider(
            apiService: context.read<ApiService>(),
          ),
          update: (context, apiService, storageService, previous) =>
              previous ?? ProductProvider(apiService: apiService),
        ),
        ChangeNotifierProxyProvider<LocalStorageService, CartProvider>(
          create: (context) => CartProvider(
            storageService: context.read<LocalStorageService>(),
          ),
          update: (context, storageService, previous) =>
              previous ?? CartProvider(storageService: storageService),
        ),
        ChangeNotifierProxyProvider<LocalStorageService, OrderProvider>(
          create: (context) => OrderProvider(
            storageService: context.read<LocalStorageService>(),
          ),
          update: (context, storageService, previous) =>
              previous ?? OrderProvider(storageService: storageService),
        ),
      ],
      child: MaterialApp(
        title: 'Mini E-Commerce',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
