import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/product_model.dart';
import '../models/product_response.dart';

class ProductRepository {
    final Dio _dio;

    ProductRepository(this._dio);

    // Get all products
    Future<ProductResponse> getProducts() async {
        final response = await _dio.get(
        ApiConstants.products,
        );

        return ProductResponse.fromJson(response.data);
    }

    // Get product detail
    Future<Product> getProductById(int id) async {
        final response = await _dio.get(
        ApiConstants.productDetail(id),
        );

        return Product.fromJson(response.data);
    }

    Future<ProductResponse> searchProducts({
      required String query,
      int limit = 20,
      int skip = 0,
    }) async {
      final response = await _dio.get(
        '/products/search',
      queryParameters: {
        'q': query,
        'limit': limit,
        'skip': skip,
      }
      );
      return ProductResponse.fromJson(response.data);
    }

    // Get all product categories
    Future<List<String>> getCategories() async {
      final response = await _dio.get(
        '/products/category-list',);
      return List<String>.from(response.data);
    }

    // Get products by category
    Future <ProductResponse> getProductsByCategory({
      required String category,
      int limit = 10,
      int skip = 0,
    }) async {
      final response = await _dio.get(
        '/products/category/$category',
        queryParameters: {'limit': limit, 'skip': skip,},
      );
      return ProductResponse.fromJson(response.data);
    }
}
