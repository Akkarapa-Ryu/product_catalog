import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/product_model.dart';
import '../data/models/product_response.dart';
import '../data/repositories/product_repository.dart';
import 'product_provider.dart';

// --------------------------------------------------
// 1. Product Query
// --------------------------------------------------

enum ProductQueryType {
  all,
  search,
  category,
}

class ProductQuery {
  final ProductQueryType type;
  final String value;

  const ProductQuery.all()
      : type = ProductQueryType.all,
        value = '';

  const ProductQuery.search(String query)
      : type = ProductQueryType.search,
        value = query;

  const ProductQuery.category(String category)
      : type = ProductQueryType.category,
        value = category;

  @override
  bool operator ==(Object other) {
    return other is ProductQuery && other.type == type && other.value == value;
  }

  @override
  int get hashCode => Object.hash(type, value);
}

// --------------------------------------------------
// 2. Product Pagination State
// --------------------------------------------------

class ProductPaginationState {
  final List<Product> products;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;
  final String? loadMoreError;

  const ProductPaginationState({
    required this.products,
    required this.total,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  ProductPaginationState copyWith({
    List<Product>? products,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return ProductPaginationState(
      products: products ?? this.products,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError:
          clearLoadMoreError ? null : loadMoreError ?? this.loadMoreError,
    );
  }
}

// --------------------------------------------------
// 3. Product Pagination Notifier
// --------------------------------------------------

final productPaginationProvider = AsyncNotifierProvider.family<
    ProductPaginationNotifier, ProductPaginationState, ProductQuery>(
  ProductPaginationNotifier.new,
);

class ProductPaginationNotifier
    extends FamilyAsyncNotifier<ProductPaginationState, ProductQuery> {
  static const int pageSize = 20;

  late ProductRepository _repository;
  late ProductQuery _query;

  bool _isRequestingMore = false;

  int _requestGeneration = 0;

  @override
  Future<ProductPaginationState> build(ProductQuery arg) async {
    _query = arg;
    _repository = ref.watch(productRepositoryProvider);

    final response = await _fetchProducts(skip: 0);

    return _createInitialState(response);
  }

  // Fetch according to query type
  Future<ProductResponse> _fetchProducts({
    required int skip,
  }) {
    switch (_query.type) {
      case ProductQueryType.all:
        return _repository.getProducts(
          limit: pageSize,
          skip: skip,
        );

      case ProductQueryType.search:
        return _repository.searchProducts(
          query: _query.value,
          limit: pageSize,
          skip: skip,
        );

      case ProductQueryType.category:
        return _repository.getProductsByCategory(
          category: _query.value,
          limit: pageSize,
          skip: skip,
        );
    }
  }

  ProductPaginationState _createInitialState(
    ProductResponse response,
  ) {
    return ProductPaginationState(
      products: response.products,
      total: response.total,
      hasMore: response.products.length < response.total,
    );
  }

  // Load next page
  Future<void> loadMore() async {
    final current = state.asData?.value;

    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        _isRequestingMore) {
      return;
    }

    _isRequestingMore = true;

    state = AsyncData(
      current.copyWith(
        isLoadingMore: true,
        clearLoadMoreError: true,
      ),
    );

    final requestGeneration = _requestGeneration;

    try {
      final response = await _fetchProducts(
        skip: current.products.length,
      );

// ป้องกัน Request เก่าเขียนทับข้อมูลหลัง Refresh
      if (requestGeneration != _requestGeneration) return;

      final updatedProducts = [
        ...current.products,
        ...response.products,
      ];

      state = AsyncData(
        current.copyWith(
          products: updatedProducts,
          total: response.total,
          hasMore: updatedProducts.length < response.total,
          isLoadingMore: false,
          clearLoadMoreError: true,
        ),
      );
    } catch (error) {
      if (requestGeneration != _requestGeneration) return;
      state = AsyncData(
        current.copyWith(
          isLoadingMore: false,
          loadMoreError: error.toString(),
        ),
      );
    } finally {
      if (requestGeneration == _requestGeneration) {
        _isRequestingMore = false;
      }
    }
  }

  // Refresh first page
  Future<void> refresh() async {
    _requestGeneration++;
    final requestGeneration = _requestGeneration;

    _isRequestingMore = false;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final response = await _fetchProducts(skip: 0);
      return _createInitialState(response);
    });

    // ป้องกัน Refresh Request เก่าเขียนทับ Request ใหม่
    if (requestGeneration != _requestGeneration) return;

    state = result;
  }

  // Retry loading next page
  Future<void> retryLoadMore() {
    return loadMore();
  }
}
