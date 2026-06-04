import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/category.dart';
import '../../domain/models/product.dart';
import '../../domain/models/stock_movement.dart';

class DemoStockStorage {
  static const _categoriesKey = 'demo_categories';
  static const _productsKey = 'demo_products';
  static const _movementsKey = 'demo_movements';

  static List<Category> loadCategories(SharedPreferences? prefs) {
    final raw = prefs?.getString(_categoriesKey);
    if (raw == null) {
      return const <Category>[];
    }
    final items = jsonDecode(raw) as List<dynamic>;
    return items.map((item) {
      final map = item as Map<String, dynamic>;
      return Category(
        id: map['id'] as String,
        name: map['name'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
    }).toList();
  }

  static List<Product> loadProducts(SharedPreferences? prefs) {
    final raw = prefs?.getString(_productsKey);
    if (raw == null) {
      return const <Product>[];
    }
    final items = jsonDecode(raw) as List<dynamic>;
    return items.map((item) {
      final map = item as Map<String, dynamic>;
      return Product(
        id: map['id'] as String,
        name: map['name'] as String,
        categoryId: map['categoryId'] as String,
        categoryName: map['categoryName'] as String,
        quantity: map['quantity'] as int,
        threshold: map['threshold'] as int,
        unitPrice: (map['unitPrice'] as num).toDouble(),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
    }).toList();
  }

  static List<StockMovement> loadMovements(SharedPreferences? prefs) {
    final raw = prefs?.getString(_movementsKey);
    if (raw == null) {
      return const <StockMovement>[];
    }
    final items = jsonDecode(raw) as List<dynamic>;
    return items.map((item) {
      final map = item as Map<String, dynamic>;
      return StockMovement(
        id: map['id'] as String,
        productId: map['productId'] as String,
        productName: map['productName'] as String,
        categoryId: map['categoryId'] as String,
        categoryName: map['categoryName'] as String,
        type: map['type'] == 'sale' ? MovementType.sale : MovementType.entry,
        quantity: map['quantity'] as int,
        unitPrice: (map['unitPrice'] as num).toDouble(),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
    }).toList();
  }

  static Future<void> saveCategories(
    SharedPreferences? prefs,
    List<Category> categories,
  ) async {
    await prefs?.setString(
      _categoriesKey,
      jsonEncode(
        categories
            .map(
              (category) => {
                'id': category.id,
                'name': category.name,
                'createdAt': category.createdAt.toIso8601String(),
              },
            )
            .toList(),
      ),
    );
  }

  static Future<void> saveProducts(
    SharedPreferences? prefs,
    List<Product> products,
  ) async {
    await prefs?.setString(
      _productsKey,
      jsonEncode(
        products
            .map(
              (product) => {
                'id': product.id,
                'name': product.name,
                'categoryId': product.categoryId,
                'categoryName': product.categoryName,
                'quantity': product.quantity,
                'threshold': product.threshold,
                'unitPrice': product.unitPrice,
                'createdAt': product.createdAt.toIso8601String(),
              },
            )
            .toList(),
      ),
    );
  }

  static Future<void> saveMovements(
    SharedPreferences? prefs,
    List<StockMovement> movements,
  ) async {
    await prefs?.setString(
      _movementsKey,
      jsonEncode(
        movements
            .map(
              (movement) => {
                'id': movement.id,
                'productId': movement.productId,
                'productName': movement.productName,
                'categoryId': movement.categoryId,
                'categoryName': movement.categoryName,
                'type': movement.type == MovementType.sale ? 'sale' : 'entry',
                'quantity': movement.quantity,
                'unitPrice': movement.unitPrice,
                'createdAt': movement.createdAt.toIso8601String(),
              },
            )
            .toList(),
      ),
    );
  }
}
