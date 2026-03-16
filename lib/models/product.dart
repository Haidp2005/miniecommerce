class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
    required this.ratingCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawRating = json['rating'];
    final ratingJson = rawRating is Map<String, dynamic> ? rawRating : const <String, dynamic>{};
    final resolvedRating = rawRating is num
        ? rawRating.toDouble()
        : (ratingJson['rate'] as num?)?.toDouble() ?? 0;
    final resolvedRatingCount = (ratingJson['count'] as num?)?.toInt() ??
        (json['ratingCount'] as num?)?.toInt() ??
        (json['stock'] as num?)?.toInt() ??
        0;
    final images = (json['images'] as List<dynamic>?) ?? const [];
    final firstImage = images.isNotEmpty ? images.first.toString() : '';
    final image = (json['image'] as String?) ?? (json['thumbnail'] as String?) ?? firstImage;

    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      image: image,
      rating: resolvedRating,
      ratingCount: resolvedRatingCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': {
        'rate': rating,
        'count': ratingCount,
      },
    };
  }
}
