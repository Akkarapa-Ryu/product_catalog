import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/product_provider.dart';

class ProductDetailPage extends ConsumerWidget {
  final int productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(
      productDetailProvider(productId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
      ),
      body: productAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
        data: (product) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  product.thumbnail,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  product.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Category: ${product.category}'),
                Text('Rating: ${product.rating}'),
                Text('Stock: ${product.stock}'),
                const Divider(height: 32),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(product.description),
              ],
            ),
          );
        },
      ),
    );
  }
}