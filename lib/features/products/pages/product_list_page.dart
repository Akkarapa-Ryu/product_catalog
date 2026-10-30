import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/product_provider.dart';
import 'product_detail_page.dart';

class ProductListPage extends ConsumerWidget {
    const ProductListPage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final productsAsync = ref.watch(productListProvider);

        return Scaffold(
        appBar: AppBar(
            title: const Row(children: [
                Icon(
                    Icons.storefront,
                ),
                Text('CatalogX'),
                Icon(
                    Icons.search,
                ),
                Icon(
                    Icons.shopping_bag_outlined
                ),
                Icon(
                    Icons.person_outline,
                ),],),
        ),
        body: productsAsync.when(
            // Loading
            loading: () => const Center(
            child: CircularProgressIndicator(),
            ),

            // Error
            error: (error, stackTrace) => Center(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Text('Error: $error'),
                const SizedBox(height: 12),
                ElevatedButton(
                    onPressed: () {
                    ref.invalidate(productListProvider);
                    },
                    child: const Text('Retry'),
                ),
                ],
            ),
            ),

            // Success
            data: (response) {
            return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
                ),
                itemCount: response.products.length,
                itemBuilder: (context, index) {
                final product = response.products[index];

                return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                    onTap: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProductDetailPage(
                            productId: product.id,
                            ),
                        ),
                        );
                    },
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Expanded(
                            child: Image.network(
                            product.thumbnail,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Center(
                                child: Icon(Icons.image_not_supported),
                            ),
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                                Text(
                                product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                ),
                                ),
                                const SizedBox(height: 4),
                                Text('Rating: ${product.rating}'),
                            ],
                            ),
                        ),
                        ],
                    ),
                    ),
                );
                },
            );
            },
        ),
        );
    }
}