import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_catalog/features/products/pages/product_detail_page.dart';
import 'package:product_catalog/providers/cart_provider.dart';

import '../../../providers/product_provider.dart';
import '../widgets/product_grid.dart';
import '../widgets/category_selector.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/product_response.dart';
import '../../../providers/cart_provider.dart';

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
  static const int _pageSize = 20;
  final List<Product> _moreProducts = [];
  bool _isLoadingMore = false;
  String? _loadMoreError;
  int _selectedNavIndex = 0;

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
          _moreProducts.clear();
          _loadMoreError = null;
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
      _moreProducts.clear();
      _loadMoreError = null;
    });

    debugPrint('Selected Category: $category');
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'เลือกประเภทสินค้าจาก Category Selector '
                'ด้านบนของหน้า Catalog',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  final List<String> _navigationLabels = [
    'Catalog',
    'Categories',
    'Wishlist',
    'Profile',
  ];

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



  @override
  Widget build(BuildContext context) {
    final productsAsync = searchQuery.isNotEmpty
        ? ref.watch(productSearchProvider(searchQuery))
        : selectedCategory != null
            ? ref.watch(productCategoryProvider(selectedCategory!))
            : ref.watch(productListProvider);

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
                IconButton(onPressed: null, icon: Icon(Icons.person)),
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
                      color: Colors.lightBlue[50],
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
                  onPressed: null,
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
                if (searchQuery.isEmpty) {
                  await ref.refresh(productListProvider.future);
                } else if (selectedCategory != null) {
                  await ref.refresh(
                    productSearchProvider(searchQuery).future,
                  );
                } else {
                  await ref.refresh(productListProvider.future);
                }
              },
              child: productsAsync.when(
                loading: () => Text("Loading..."),
                error: (error, stackTrace) {
                  return Text('Error');
                },
                data: (response) {
                  // if (response.products.isEmpty) {
                  //   return const EmptyWidget();
                  // }

                  return ProductGrid(
                    products: response.products,
                    onProductTap: (product) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailPage(productId: product.id)));
                    },
                    onAddToCart: (product) {
                        _addToCart(product);
                    },
                  );
                  // return const Text('Product');
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openFilter,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
        child: Icon(Icons.filter_alt_outlined),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
