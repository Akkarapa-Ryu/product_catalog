import 'package:product_catalog/data/models/dimensions_model.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double rating;
  final int stock;
  final String thumbnail;
  final List<String> images;
  final double discountPercentage;
  final String? brand;
  final String? sku;
  final List<String>? colors;
  final String shippingInformation;
  final double weight;
  final Dimensions dimensions;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    required this.images,
    required this.discountPercentage,
    this.brand,
    this.sku,
    this.colors,
    required this.shippingInformation,
    required this.weight,
    required this.dimensions,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      stock: json['stock'] as int,
      thumbnail: json['thumbnail'] as String,
      images: (json['images'] as List<dynamic>)
          .map((image) => image.toString())
          .toList(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      brand: json['brand'] as String?,
      sku: json['sku'] as String?,
      colors: json['colors'] != null ? List<String>.from(json['colors']) : null,
      shippingInformation: json['shippingInformation'] as String,
      weight: (json['weight'] as num).toDouble(),
      dimensions: Dimensions.fromJson(
        json['dimensions'] as Map<String, dynamic>,
      ),
    );
  }
}
