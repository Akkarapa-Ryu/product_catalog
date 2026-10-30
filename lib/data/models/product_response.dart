import 'product_model.dart';

class ProductResponse {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const ProductResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductResponse(
      products: (json['products'] as List<dynamic>)
          .map(
            (item) => Product.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      total: json['total'] as int,
      skip: json['skip'] as int,
      limit: json['limit'] as int,
    );
  }
}