import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/cart_badge_icon.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _size = 'M';
  String _color = 'Đen';
  int _quantity = 1;
  bool _isDescriptionExpanded = false;
  int _currentImageIndex = 0;

  late final List<String> _images;

  @override
  void initState() {
    super.initState();
    // Simulate multiple angles by duplicating the image
    _images = [
      widget.product.image,
      widget.product.image,
      widget.product.image,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final originalPrice = product.price * 1.25; // fake original price

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        actions: [
          CartBadgeIcon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        children: [
          // Image Slider
          SizedBox(
            height: 350,
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: _images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final img = _images[index];
                    // Apply heroic animation to the first item (which matches the tapped item from Home)
                    if (index == 0) {
                      return Hero(
                        tag: 'product-image-${product.id}',
                        child: _buildImage(img),
                      );
                    }
                    return _buildImage(img);
                  },
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_images.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withOpacity(0.5),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price block
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${originalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Ratings / Sales
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${product.rating}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 12, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Text('Đã bán ${product.ratingCount}k'), // Mock k
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),

          // Variants Picker (Summary block)
          GestureDetector(
            onTap: _openVariantSheet,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  const Text('Chọn phân loại', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Size $_size, Màu $_color',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Description block
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mô tả sản phẩm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  product.description,
                  maxLines: _isDescriptionExpanded ? null : 5,
                  overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isDescriptionExpanded = !_isDescriptionExpanded;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_isDescriptionExpanded ? 'Thu gọn' : 'Xem thêm'),
                        Icon(_isDescriptionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        surfaceTintColor: Colors.white,
        color: Colors.white,
        height: 56,
        child: Row(
          children: [
            // Left Half: Chat + Cart
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng Chat đang phát triển')),
                      );
                    },
                    icon: const Icon(Icons.chat_outlined),
                    tooltip: 'Chat',
                  ),
                  Container(width: 1, height: 32, color: Colors.grey[300]),
                  CartBadgeIcon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
                  ),
                ],
              ),
            ),
            // Right Half: Add to Cart + Buy Now
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _openVariantSheet,
                child: Container(
                  color: Colors.teal[50], // Slightly colored background
                  alignment: Alignment.center,
                  child: const Text(
                    'Thêm vào giỏ',
                    style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  _openVariantSheet(isBuyNow: true);
                },
                child: Container(
                  color: Colors.red,
                  alignment: Alignment.center,
                  child: const Text(
                    'Mua ngay',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imgUrl) {
    return AspectRatio(
      aspectRatio: 1,
      child: Image.network(
        imgUrl, 
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> _openVariantSheet({bool isBuyNow = false}) async {
    final product = widget.product;
    
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(product.image, width: 80, height: 80, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text('Kho: 999', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    
                    // Size Picker
                    const Text('Kích cỡ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['S', 'M', 'L'].map((size) {
                        final isSelected = _size == size;
                        return ChoiceChip(
                          label: Text(size),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => _size = size);
                              setState(() => _size = size);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Color Picker
                    const Text('Màu sắc', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Đen', 'Xanh', 'Đỏ'].map((color) {
                        final isSelected = _color == color;
                        return ChoiceChip(
                          label: Text(color),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => _color = color);
                              setState(() => _color = color);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Quantity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Số lượng', style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_quantity > 1) {
                                  setModalState(() => _quantity--);
                                  setState(() => _quantity = _quantity);
                                }
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              onPressed: () {
                                setModalState(() => _quantity++);
                                setState(() => _quantity = _quantity);
                              },
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          _addToCart(context);
                          Navigator.pop(context);
                          if (isBuyNow) {
                            Navigator.pushNamed(context, AppRoutes.cart);
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(isBuyNow ? 'Mua ngay' : 'Thêm vào giỏ hàng', style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addToCart(BuildContext context) async {
    await context.read<CartProvider>().addItem(
          product: widget.product,
          size: _size,
          color: _color,
          quantity: _quantity,
        );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thêm thành công'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
