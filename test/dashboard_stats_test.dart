import 'package:flutter_test/flutter_test.dart';
import 'package:stock_flutter/domain/models/dashboard_stats.dart';
import 'package:stock_flutter/domain/models/product.dart';
import 'package:stock_flutter/domain/models/stock_movement.dart';

void main() {
  test('compte les ventes effectuees pendant toute la journee de fin', () {
    final product = Product(
      id: 'p1',
      name: 'Stylo',
      categoryId: 'c1',
      categoryName: 'Fourniture',
      quantity: 17,
      threshold: 5,
      unitPrice: 10,
      createdAt: DateTime(2026, 6, 4),
    );

    final stats = DashboardStats.fromData(
      products: [product],
      movements: [
        StockMovement(
          id: 'm1',
          productId: product.id,
          productName: product.name,
          categoryId: product.categoryId,
          categoryName: product.categoryName,
          type: MovementType.sale,
          quantity: 3,
          unitPrice: 10,
          createdAt: DateTime(2026, 6, 4, 18, 30),
        ),
      ],
      start: DateTime(2026, 6, 1),
      end: DateTime(2026, 6, 4),
    );

    expect(stats.salesAmount, 30);
    expect(stats.topProducts.single.quantity, 3);
    expect(stats.salesByCategory.single.amount, 30);
  });
}
