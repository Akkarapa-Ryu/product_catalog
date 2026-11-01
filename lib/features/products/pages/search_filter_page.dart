
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/product_provider.dart';

// ผลลัพธ์ที่ส่งกลับไปยัง ProductListPage
class SearchFilterResult {
  final String searchQuery;
  final String? category;

  const SearchFilterResult({
    required this.searchQuery,
    required this.category,
  });
}

class SearchFilterPage extends ConsumerStatefulWidget {
  final String initialSearch;
  final String? initialCategory;

  const SearchFilterPage({
    super.key,
    this.initialSearch = '',
    this.initialCategory,
  });

  @override
  ConsumerState<SearchFilterPage> createState() =>
      _SearchFilterPageState();
}

class _SearchFilterPageState
    extends ConsumerState<SearchFilterPage> {
  late final TextEditingController _searchController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(
      text: widget.initialSearch,
    );

    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
    });
  }

  void _applyFilters() {
    final result = SearchFilterResult(
      searchQuery: _searchController.text.trim(),
      category: _selectedCategory,
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(productCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Search
                  const Text(
                    'Search Product',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _selectedCategory = null;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.trim().isNotEmpty &&
                          _selectedCategory != null) {
                        setState(() {
                          _selectedCategory = null;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Category
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  categoriesAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stackTrace) => const Text(
                      'Unable to load categories.',
                    ),
                    data: (categories) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: _selectedCategory == null,
                            onSelected: (_) => _selectCategory(null),
                          ),
                          ...categories.map((category) {
                            return ChoiceChip(
                              label: Text(
                                category.replaceAll('-', ' '),
                              ),
                              selected:
                                  _selectedCategory == category,
                              onSelected: (_) =>
                                  _selectCategory(category),
                            );
                          }),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  const Divider(),

                  const SizedBox(height: 8),

                  const Text(
                    'Search and Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'You can search by product name or select '
                    'a category. Selecting a category clears '
                    'the search field.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Apply button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
