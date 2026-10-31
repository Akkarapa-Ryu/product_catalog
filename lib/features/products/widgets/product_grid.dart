
import 'package:flutter/material.dart';

import '../../../data/models/product_model.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductTap;
  final Function(Product) onAddToCart;

  const ProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;

        if (constraints.maxWidth >= 900) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.50,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];

            return ProductCard(
              product: product,
              onTap: () => onProductTap(product),
              onAddToCart: () => onAddToCart(product),
            );
          },
        );
      },
    );
  }
}
