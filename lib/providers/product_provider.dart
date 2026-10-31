import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_client.dart';
import '../data/models/product_model.dart';
import '../data/models/product_response.dart';
import '../data/repositories/product_repository.dart';

// Repository Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(DioClient.dio);
});

// Product List Provider
final productListProvider = FutureProvider<ProductResponse>((ref) async {
  final repository = ref.watch(productRepositoryProvider);

  return repository.getProducts();
});

// Product Detail Provider
final productDetailProvider =
    FutureProvider.family<Product, int>((ref, id) async {
  final repository = ref.watch(productRepositoryProvider);

  return repository.getProductById(id);
});

final productSearchProvider = FutureProvider.family<ProductResponse, String>((ref, query) async {
  final responsitory = ref.watch(productRepositoryProvider);
  return responsitory.searchProducts(query: query);
});

// Get categories
final productCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final responsitory = ref.watch(productRepositoryProvider);
  return responsitory.getCategories();
});

// Get products by category
final productCategoryProvider =
    FutureProvider.family<ProductResponse, String>(
  (ref, category) async {
    final repository = ref.watch(productRepositoryProvider);

    return repository.getProductsByCategory(
      category: category,
    );
  },
);
