import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_catalog/features/products/pages/product_detail_page.dart';

import '../../../providers/product_provider.dart';
import '../widgets/product_grid.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/product_grid.dart';
import '../widgets/category_selector.dart';

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

  @override
  Widget build(BuildContext context) {
    final productsAsync = searchQuery.isNotEmpty
        ? ref.watch(productSearchProvider(searchQuery))
        : selectedCategory != null
            ? ref.watch(productCategoryProvider(selectedCategory!))
            : ref.watch(productListProvider);

    final categoriesAsync = ref.watch(productCategoriesProvider);
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
                  child: Icon(
                    Icons.storefront_outlined,
                    color: Colors.white,
                  ),
                  color: Colors.lightBlueAccent,
                  padding: EdgeInsets.all(7),
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
                IconButton(
                    onPressed: null, icon: Icon(Icons.shopping_bag_outlined)),
                IconButton(onPressed: null, icon: Icon(Icons.person))
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
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
                        onPressed: null, icon: Icon(Icons.mic_none_outlined)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          IconButton(onPressed: null, icon: Icon(Icons.filter_list)),
          categoriesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) => const SizedBox.shrink(),
            data: (categories) {
              return CategorySelector(
                categories: categories,
                selectedCategory: selectedCategory,
                onSelected: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                  debugPrint('Selected Ccategory: $category');
                },
              );
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (searchQuery.isEmpty) {
                  await ref.refresh(productListProvider.future);
                } else if (selectedCategory != Null) {
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
                  );
                  // return const Text('Product');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
