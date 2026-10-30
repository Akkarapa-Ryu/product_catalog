
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:product_catalog/app.dart';
import 'package:product_catalog/providers/product_provider.dart';
import 'package:product_catalog/data/models/product_model.dart';
import 'package:product_catalog/data/models/product_response.dart';

void main() {
  testWidgets('Product Catalog app smoke test', (
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
        ),
      ],
      total: 1,
      skip: 0,
      limit: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productListProvider.overrideWith(
            (ref) async => mockResponse,
          ),
        ],
        child: const MyApp(),
      ),
    );

    // Wait for FutureProvider
    await tester.pumpAndSettle();

    // Check AppBar
    expect(
      find.text('Product Catalog'),
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
  });
}
