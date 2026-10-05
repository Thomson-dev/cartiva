import 'dart:convert';

enum ProductCategory { tshirts, jeans, shoes }

class Product {
  final String id;
  final String name;
  final double price;
  final String? discount;
  final String imageUrl;
  final bool isFavourite;
  final ProductCategory category;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.discount,
    this.isFavourite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      discount: json['discount'] as String?,
      imageUrl: json['image_url'] as String,
      category: ProductCategory.values.byName(json['category'] as String),
    );
  }
}
