import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/cart_badge_icon.dart';
import '../../widgets/common/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isPinned = false;

  @override
  void initState() {
    super.initState();
    final cartProvider = context.read<CartProvider>();
    final productProvider = context.read<ProductProvider>();
    Future.microtask(() {
      cartProvider.initIfNeeded();
      productProvider.initIfNeeded();
    });

    _scrollController.addListener(() {
      // Logic for sticky search bar color change
      setState(() {
        _isPinned = _scrollController.hasClients &&
            _scrollController.offset > (200 - kToolbarHeight);
      });

      // Infinite scroll logic
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<ProductProvider>();
        if (provider.hasMore && !provider.isLoadingMore) {
          provider.fetchProducts();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<ProductProvider>().fetchProducts(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // SliverAppBar with sticky search bar
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              backgroundColor: _isPinned ? Theme.of(context).primaryColor : Colors.white,
              elevation: _isPinned ? 2 : 0,
              title: Text(
                AppConstants.appBarTitle,
                style: TextStyle(
                  color: _isPinned ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                CartBadgeIcon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SearchBar(
                    hintText: 'Tìm kiếm trên Mini E-Commerce...',
                    leading: const Icon(Icons.search),
                    elevation: WidgetStateProperty.all(2),
                    backgroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                ),
              ),
            ),

            // Banner Carousel
            SliverToBoxAdapter(
              child: _BannerCarousel(),
            ),

            // Categories
            SliverToBoxAdapter(
              child: _CategoriesSection(
                categories: provider.categories,
                selectedCategory: provider.selectedCategory,
                onSelected: (cat) => provider.selectCategory(cat),
              ),
            ),

            // Daily Discover Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.flash_on, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Gợi Ý Hôm Nay',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product Grid
            if (provider.isLoading && provider.products.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.error != null && provider.products.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lỗi: ${provider.error}'),
                      ElevatedButton(
                        onPressed: () => provider.fetchProducts(refresh: true),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < provider.products.length) {
                        final product = provider.products[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.productDetail,
                              arguments: product,
                            );
                          },
                        );
                      }
                      return null;
                    },
                    childCount: provider.products.length,
                  ),
                ),
              ),

            // Loading More Indicator
            if (provider.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

            // Bottom Spacing
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.orders),
        child: const Icon(Icons.history),
      ),
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Using a simpler approach for the demo: PageController + Timer
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      int nextPage = (_currentPage + 1) % 3;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _startTimer();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 180,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildBannerItem(Colors.blue, 'Sale 50%', 'https://picsum.photos/id/1/600/300'),
              _buildBannerItem(Colors.green, 'Free Shipping', 'https://picsum.photos/id/2/600/300'),
              _buildBannerItem(Colors.orange, 'New Arrivals', 'https://picsum.photos/id/3/600/300'),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBannerItem(Color color, String text, String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            color.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2))],
        ),
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selectedCategory;
  final Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Danh mục',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 220, // Enough for 2 rows
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = (selectedCategory == null && cat == 'All') ||
                  (selectedCategory == cat);

              return GestureDetector(
                onTap: () => onSelected(cat),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
                      child: Icon(
                        _getIconForCategory(cat),
                        color: isSelected ? Colors.white : Colors.black54,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.devices;
      case 'jewelery':
        return Icons.watch;
      case "men's clothing":
        return Icons.man;
      case "women's clothing":
        return Icons.woman;
      default:
        return Icons.category;
    }
  }
}
