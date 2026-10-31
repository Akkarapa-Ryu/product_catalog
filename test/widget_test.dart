import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:product_catalog/app.dart';
import 'package:product_catalog/data/models/dimensions_model.dart';
import 'package:product_catalog/providers/product_provider.dart';
import 'package:product_catalog/data/models/product_model.dart';
import 'package:product_catalog/data/models/product_response.dart';

void main() {
  testWidgets('CatalogX app smoke test', (
    WidgetTester tester,
  ) async {
    // Mock Product Data
    final mockResponse = ProductResponse(
      products: [
        Product(
          id: 1,
          title: 'Test Product',
          description: 'Test Description',
          category: 'Test Category',
          price: 99.99,
          rating: 4.5,
          stock: 10,
          thumbnail: 'https://example.com/image.jpg',
          images: [],
          discountPercentage: 10.0,
          brand: 'Test Brand',
          sku: 'Test SKU',
          colors: ['Test Color'],
          shippingInformation: 'Test ShippingInformation',
          weight: 4.0,
          dimensions: const Dimensions(
            width: 15.14,
            height: 13.08,
            depth: 22.99,
          ),
        ),
      ],
      total: 1,
      skip: 0,
      limit: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Mock Product List
          productListProvider.overrideWith(
            (ref) async => mockResponse,
          ),

          // Mock Product Categories
          productCategoriesProvider.overrideWith(
            (ref) async => [
              'beauty',
              'fragrances',
              'furniture',
            ],
          ),
        ],
        child: const MyApp(),
      ),
    );

    // Wait for FutureProvider
    await tester.pumpAndSettle();

    // Check AppBar
    expect(
      find.text('CatalogX'),
      findsOneWidget,
    );

    // Check Product Data
    expect(
      find.text('Test Product'),
      findsOneWidget,
    );

    expect(
      find.text('\$99.99'),
      findsOneWidget,
    );

    expect(find.text('Test Brand'), findsOneWidget);
    expect(find.text('Test Colors'), findsOneWidget);
    expect(find.text('Test ShippingInformation'), findsOneWidget);
    expect(find.text('15.14'), findsOneWidget);
    expect(find.text('13.08'), findsOneWidget);
    expect(find.text('22.99'), findsOneWidget);
  });
}
