import 'product.dart';
import 'stock_movement.dart';

class CategorySales {
  const CategorySales({required this.categoryName, required this.amount});

  final String categoryName;
  final double amount;
}

class ProductSales {
  const ProductSales({required this.productName, required this.quantity});

  final String productName;
  final int quantity;
}

class DashboardStats {
  const DashboardStats({
    required this.stockValue,
    required this.salesAmount,
    required this.salesByCategory,
    required this.topProducts,
    required this.lowStockProducts,
  });

  final double stockValue;
  final double salesAmount;
  final List<CategorySales> salesByCategory;
  final List<ProductSales> topProducts;
  final List<Product> lowStockProducts;

  factory DashboardStats.fromData({
    required List<Product> products,
    required List<StockMovement> movements,
    required DateTime start,
    required DateTime end,
  }) {
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
    final sales = movements.where((movement) {
      final inRange =
          !movement.createdAt.isBefore(startOfDay) &&
          !movement.createdAt.isAfter(endOfDay);
      return movement.type == MovementType.sale && inRange;
    });

    final byCategory = <String, double>{};
    final byProduct = <String, int>{};
    var salesAmount = 0.0;

    for (final sale in sales) {
      salesAmount += sale.total;
      byCategory.update(
        sale.categoryName,
        (value) => value + sale.total,
        ifAbsent: () => sale.total,
      );
      byProduct.update(
        sale.productName,
        (value) => value + sale.quantity,
        ifAbsent: () => sale.quantity,
      );
    }

    final topProducts =
        byProduct.entries
            .map(
              (entry) =>
                  ProductSales(productName: entry.key, quantity: entry.value),
            )
            .toList()
          ..sort((a, b) => b.quantity.compareTo(a.quantity));

    return DashboardStats(
      stockValue: products.fold<double>(
        0,
        (sum, product) => sum + product.quantity * product.unitPrice,
      ),
      salesAmount: salesAmount,
      salesByCategory:
          byCategory.entries
              .map(
                (entry) =>
                    CategorySales(categoryName: entry.key, amount: entry.value),
              )
              .toList()
            ..sort((a, b) => b.amount.compareTo(a.amount)),
      topProducts: topProducts.take(5).toList(),
      lowStockProducts: products
          .where((product) => product.isBelowThreshold)
          .toList(),
    );
  }
}
