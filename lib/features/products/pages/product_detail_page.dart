
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/product_provider.dart';
import '../../../../data/models/product_model.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailPage> createState() =>
      _ProductDetailPageState();
}

class _ProductDetailPageState
    extends ConsumerState<ProductDetailPage> {
  int selectedImageIndex = 0;
  int quantity = 1;

  bool isFavorite = false;
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final productAsync =
        ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FC),
        elevation: 0,
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share feature is not connected yet.'),
                ),
              );
            },
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),

      body: productAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 45,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              const Text('Unable to load product details'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(
                    productDetailProvider(widget.productId),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),

        data: (product) {
          final imageUrls = product.images.isNotEmpty
              ? product.images
              : [product.thumbnail];

          final safeIndex =
              selectedImageIndex < imageUrls.length
                  ? selectedImageIndex
                  : 0;

          final hasDiscount =
              product.discountPercentage > 0 &&
              product.discountPercentage < 100;

          final originalPrice = hasDiscount
              ? product.price /
                  (1 - product.discountPercentage / 100)
              : product.price;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= 700;

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 1100,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // Product Category
                              _buildProductHeader(product),

                              const SizedBox(height: 12),

                              // Product Gallery + Summary
                              if (isTablet)
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: _buildGallery(
                                        product,
                                        imageUrls,
                                        safeIndex,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 4,
                                      child: _buildSummary(
                                        product,
                                        hasDiscount,
                                        originalPrice,
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                _buildGallery(
                                  product,
                                  imageUrls,
                                  safeIndex,
                                ),
                                const SizedBox(height: 12),
                                _buildSummary(
                                  product,
                                  hasDiscount,
                                  originalPrice,
                                ),
                              ],

                              const SizedBox(height: 12),

                              // Quantity Selector
                              _buildQuantity(product),

                              const SizedBox(height: 12),

                              // Product Information
                              _buildProductInformation(product),

                              const SizedBox(height: 12),

                              // Service Information
                              _buildServiceInformation(),

                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Action Bar
                  _buildBottomActions(product),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Product Category Header
  Widget _buildProductHeader(Product product) {
    return Row(
      children: [
        const Icon(
          Icons.storefront_outlined,
          size: 17,
        ),
        const SizedBox(width: 7),

        Expanded(
          child: Text(
            '${product.brand != null && product.brand!.isNotEmpty ? '${product.brand} • ' : ''} ${product.category}  •  ID: ${product.id}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey.shade600,
            ),
          ),
        ),

        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () {
            setState(() {
              isFavorite = !isFavorite;
            });
          },
          icon: Icon(
            isFavorite
                ? Icons.favorite
                : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.black87,
          ),
        ),
      ],
    );
  }

  // Product Image Gallery
  Widget _buildGallery(
    Product product,
    List<String> imageUrls,
    int safeIndex,
  ) {
    final hasDiscount =
        product.discountPercentage > 0 &&
        product.discountPercentage < 100;

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrls[safeIndex],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported_outlined,
                        size: 60,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),

              if (hasDiscount)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ลด ${product.discountPercentage.round()}%',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${safeIndex + 1} / ${imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Thumbnail List
        SizedBox(
          height: 65,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = safeIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedImageIndex = index;
                  });
                },
                child: Container(
                  width: 65,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? Colors.blue
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Product Summary
  Widget _buildSummary(
    Product product,
    bool hasDiscount,
    double originalPrice,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // Rating
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.orange,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Product Rating',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Price
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (hasDiscount)
                Text(
                  '\$${originalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),

          if (hasDiscount)
            Text(
              'You save \$${(originalPrice - product.price).toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),

          const SizedBox(height: 12),

          // Stock Status
          Row(
            children: [
              Icon(
                product.stock > 0
                    ? Icons.check_circle
                    : Icons.cancel,
                size: 15,
                color: product.stock > 0
                    ? Colors.green
                    : Colors.red,
              ),
              const SizedBox(width: 5),
              Text(
                product.stock > 0
                    ? 'Available: ${product.stock} items'
                    : 'Out of stock',
                style: TextStyle(
                  color: product.stock > 0
                      ? Colors.green
                      : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Quantity Selector
  Widget _buildQuantity(Product product) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Quantity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          _quantityButton(
            icon: Icons.remove,
            enabled: quantity > 1,
            onTap: () {
              setState(() {
                quantity--;
              });
            },
          ),

          SizedBox(
            width: 42,
            child: Center(
              child: Text(
                '$quantity',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          _quantityButton(
            icon: Icons.add,
            enabled: quantity < product.stock,
            onTap: () {
              setState(() {
                quantity++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFFF0F0FA),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
      icon: Icon(icon, size: 18),
    );
  }

  // Product Information Tabs
  Widget _buildProductInformation(Product product) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _tabButton('Details', 0),
                _tabButton('Shipping', 1),
              ],
            ),
          ),

          const SizedBox(height: 14),

          if (selectedTab == 0) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                product.description,
                style: TextStyle(
                  color: Colors.blueGrey.shade600,
                  height: 1.6,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _infoBox(
                    'Category',
                    product.category,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _infoBox(
                    'Product ID',
                    '#${product.id}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _infoBox(
                    'Stock',
                    '${product.stock} items',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _infoBox(
                    'Rating',
                    '${product.rating.toStringAsFixed(1)} / 5',
                  ),
                ),
              ],
            ),
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Shipping information will be provided '
                'during checkout.',
                style: TextStyle(
                  color: Colors.blueGrey,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tabButton(String title, int index) {
    final selected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected
                    ? Colors.blue.shade800
                    : Colors.blueGrey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Service Information
  Widget _buildServiceInformation() {
    return Row(
      children: [
        _serviceCard(
          Icons.verified_user_outlined,
          'Secure',
          'Product information',
        ),
        const SizedBox(width: 8),
        _serviceCard(
          Icons.credit_card_outlined,
          'Payment',
          'Checkout options',
        ),
        const SizedBox(width: 8),
        _serviceCard(
          Icons.local_shipping_outlined,
          'Delivery',
          'Shipping details',
        ),
      ],
    );
  }

  Widget _serviceCard(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.blue.shade700,
              size: 23,
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Action Bar
  Widget _buildBottomActions(Product product) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chat feature is not connected yet.'),
                  ),
                );
              },
              icon: const Icon(Icons.chat_outlined),
            ),

            const SizedBox(width: 5),

            Expanded(
              child: OutlinedButton.icon(
                onPressed: product.stock > 0
                    ? () => _showActionMessage('Add to Cart')
                    : null,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Add to Cart'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  foregroundColor: Colors.blue.shade800,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: ElevatedButton.icon(
                onPressed: product.stock > 0
                    ? () => _showActionMessage('Buy Now')
                    : null,
                icon: const Icon(Icons.flash_on),
                label: const Text('Buy Now'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionMessage(String action) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$action: ${quantity} item(s) selected.',
          ),
        ),
      );
  }
}