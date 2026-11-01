import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/product_detail_page.dart';
import '../pages/search_filter_page.dart';
import '../widgets/empty_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/product_pagination_provider.dart';
import '../widgets/product_grid.dart';
import '../widgets/category_selector.dart';
import '../../../data/models/product_model.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  String searchQuery = '';
  String? selectedCategory;
  int _selectedNavIndex = 0;

  final List<String> _navigationLabels = [
    'Catalog',
    'Categories',
    'Wishlist',
    'Profile',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () {
        if (!mounted) return;

        setState(() {
          searchQuery = value.trim();
        });
      },
    );
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();

    setState(() {
      searchQuery = '';
    });
  }

  void _onCategorySelected(String? category) {
    _debounce?.cancel();

    _searchController.clear();

    setState(() {
      searchQuery = '';
      selectedCategory = category;
    });

    debugPrint('Selected Category: $category');
  }

  void _addToCart(Product product) {
    ref.read(cartProvider.notifier).update((cart) {
      return {
        ...cart,
        product.id: (cart[product.id] ?? 0) + 1,
      };
    });
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue.shade800,
      unselectedItemColor: Colors.blueGrey,
      onTap: (index) {
        setState(() {
          _selectedNavIndex = index;
        });

        if (index != 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_navigationLabels[index]} '
                'ยังไม่ได้พัฒนา',
              ),
            ),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Catalog',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildCartButton(int cartCount) {
    return IconButton(
      onPressed: () {
        // TODO: เปิดหน้า Cart
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 26,
          ),
          if (cartCount > 0)
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth: 19,
                  minHeight: 19,
                ),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  cartCount > 99 ? '99+' : '$cartCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openSearchFilter() async {
    _debounce?.cancel();

    final result = await Navigator.push<SearchFilterResult>(
      context,
      MaterialPageRoute(
        builder: (context) => SearchFilterPage(
          initialSearch: searchQuery,
          initialCategory: selectedCategory,
        ),
      ),
    );

    if (!mounted || result == null) return;

    _searchController.text = result.searchQuery;

    setState(() {
      searchQuery = result.searchQuery;
      selectedCategory = result.category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productQuery = searchQuery.isNotEmpty
        ? ProductQuery.search(searchQuery)
        : selectedCategory != null
            ? ProductQuery.category(selectedCategory!)
            : ProductQuery.all();

    final productsAsync = ref.watch(
      productPaginationProvider(productQuery),
    );

    final categoriesAsync = ref.watch(productCategoriesProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    debugPrint('Search Query: $searchQuery');
    debugPrint('Selected Category: $selectedCategory');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: Colors.white,
                  ),
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'CatalogX',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(onPressed: null, icon: Icon(Icons.search)),
                _buildCartButton(cartCount),
                IconButton(
                    onPressed: null,
                    icon: CircleAvatar(
                        backgroundColor: Colors.blue.shade800,
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.white,
                        ))),
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                      color: Colors.blueGrey[50],
                      borderRadius: BorderRadius.circular(25)),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'ค้นหาสินค้า เช่น iPhone, Perfume...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : const IconButton(
                              onPressed: null,
                              icon: Icon(Icons.mic_none_outlined)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 6,
              ),
              Container(
                width: 54,
                height: 54,
                child: IconButton(
                  icon: Icon(Icons.tune),
                  onPressed: _openSearchFilter,
                ),
              ),
            ],
          ),
          categoriesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) => const SizedBox.shrink(),
            data: (categories) {
              return CategorySelector(
                categories: categories,
                selectedCategory: selectedCategory,
                onSelected: _onCategorySelected,
              );
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(
                      productPaginationProvider(productQuery).notifier,
                    )
                    .refresh();
              },
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.axis == Axis.vertical &&
                      notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 300) {
                    unawaited(
                      ref
                          .read(
                            productPaginationProvider(productQuery).notifier,
                          )
                          .loadMore(),
                    );
                  }

                  return false;
                },
                child: productsAsync.when(
                  // Initial Loading
                  loading: () => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 350,
                        child: LoadingWidget(),
                      ),
                    ],
                  ),

                  // Initial Error
                  error: (error, stackTrace) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 350,
                        child: ErrorWidgetView(
                          message: 'Unable to load products.',
                          onRetry: () {
                            unawaited(
                              ref
                                  .read(
                                    productPaginationProvider(productQuery)
                                        .notifier,
                                  )
                                  .refresh(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // Data
                  data: (pagination) {
                    if (pagination.products.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(
                            height: 350,
                            child: EmptyWidget(
                              message: 'Try searching for another product.',
                            ),
                          ),
                        ],
                      );
                    }

                    return Stack(
                      children: [
                        ProductGrid(
                          products: pagination.products,
                          onProductTap: (product) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailPage(
                                  productId: product.id,
                                ),
                              ),
                            );
                          },
                          onAddToCart: _addToCart,
                        ),

                        // Load More Loading / Error
                        if (pagination.isLoadingMore)
                          const Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: LinearProgressIndicator(),
                          ),

                        if (pagination.loadMoreError != null)
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Unable to load more products.',
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        unawaited(
                                          ref
                                              .read(
                                                productPaginationProvider(
                                                        productQuery)
                                                    .notifier,
                                              )
                                              .retryLoadMore(),
                                        );
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openSearchFilter,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
        child: Icon(Icons.filter_alt_outlined),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
