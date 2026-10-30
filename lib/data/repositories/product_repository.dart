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
}
