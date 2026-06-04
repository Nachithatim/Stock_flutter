import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/category.dart';
import '../../domain/models/product.dart';
import '../../domain/models/stock_movement.dart';

class FirestoreStockService {
  FirestoreStockService(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _tenantCollection(
    String clientId,
    String collection,
  ) {
    return _db.collection('tenants').doc(clientId).collection(collection);
  }

  Stream<List<Category>> watchCategories(String clientId) {
    return _tenantCollection(clientId, 'categories')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Category.fromFirestore).toList());
  }

  Stream<List<Product>> watchProducts(String clientId) {
    return _tenantCollection(clientId, 'products')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Product.fromFirestore).toList());
  }

  Stream<List<StockMovement>> watchMovements(String clientId) {
    return _tenantCollection(clientId, 'movements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(StockMovement.fromFirestore).toList(),
        );
  }

  Future<Category> createCategory(String clientId, String name) async {
    final category = Category(id: '', name: name, createdAt: DateTime.now());
    final doc = await _tenantCollection(
      clientId,
      'categories',
    ).add(category.toFirestore());
    return Category(id: doc.id, name: name, createdAt: category.createdAt);
  }

  Future<Category> getOrCreateCategory(String clientId, String name) async {
    final normalized = name.trim().toLowerCase();
    final existing = await _tenantCollection(
      clientId,
      'categories',
    ).where('normalizedName', isEqualTo: normalized).limit(1).get();

    if (existing.docs.isNotEmpty) {
      return Category.fromFirestore(existing.docs.first);
    }

    final now = DateTime.now();
    final doc = await _tenantCollection(clientId, 'categories').add({
      'name': name.trim(),
      'normalizedName': normalized,
      'createdAt': Timestamp.fromDate(now),
    });
    return Category(id: doc.id, name: name.trim(), createdAt: now);
  }

  Future<void> createProduct({
    required String clientId,
    required String name,
    required String categoryName,
    required int threshold,
    required double unitPrice,
  }) async {
    final category = await getOrCreateCategory(clientId, categoryName);
    final product = Product(
      id: '',
      name: name,
      categoryId: category.id,
      categoryName: category.name,
      quantity: 0,
      threshold: threshold,
      unitPrice: unitPrice,
      createdAt: DateTime.now(),
    );
    await _tenantCollection(clientId, 'products').add(product.toFirestore());
  }

  Future<void> addMovement({
    required String clientId,
    required Product product,
    required MovementType type,
    required int quantity,
  }) async {
    final productRef = _tenantCollection(clientId, 'products').doc(product.id);
    final movementRef = _tenantCollection(clientId, 'movements').doc();

    await _db.runTransaction((transaction) async {
      final fresh = await transaction.get(productRef);
      final freshProduct = Product.fromFirestore(fresh);
      final delta = type == MovementType.entry ? quantity : -quantity;
      final nextQuantity = freshProduct.quantity + delta;

      if (nextQuantity < 0) {
        throw StateError('Stock insuffisant pour cette vente.');
      }

      transaction.update(productRef, {'quantity': nextQuantity});
      transaction.set(
        movementRef,
        StockMovement(
          id: movementRef.id,
          productId: product.id,
          productName: product.name,
          categoryId: product.categoryId,
          categoryName: product.categoryName,
          type: type,
          quantity: quantity,
          unitPrice: product.unitPrice,
          createdAt: DateTime.now(),
        ).toFirestore(),
      );
    });
  }
}
