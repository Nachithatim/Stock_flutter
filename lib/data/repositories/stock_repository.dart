import '../../domain/models/category.dart';
import '../../domain/models/product.dart';
import '../../domain/models/stock_movement.dart';
import '../services/firestore_stock_service.dart';

class StockRepository {
  StockRepository(this._service);

  final FirestoreStockService _service;

  Stream<List<Category>> watchCategories(String clientId) {
    return _service.watchCategories(clientId);
  }

  Stream<List<Product>> watchProducts(String clientId) {
    return _service.watchProducts(clientId);
  }

  Stream<List<StockMovement>> watchMovements(String clientId) {
    return _service.watchMovements(clientId);
  }

  Future<void> createProduct({
    required String clientId,
    required String name,
    required String categoryName,
    required int threshold,
    required double unitPrice,
  }) {
    return _service.createProduct(
      clientId: clientId,
      name: name,
      categoryName: categoryName,
      threshold: threshold,
      unitPrice: unitPrice,
    );
  }

  Future<void> addMovement({
    required String clientId,
    required Product product,
    required MovementType type,
    required int quantity,
  }) {
    return _service.addMovement(
      clientId: clientId,
      product: product,
      type: type,
      quantity: quantity,
    );
  }
}
